//
//  FeedDownloadService.m
//  Draw
//
//  Created by qqn_pipi on 13-3-5.
//
//

#import "FeedDownloadService.h"
#import "SynthesizeSingleton.h"
#import "ASIHTTPRequest.h"
#import "FileUtil.h"
#import "SSZipArchive.h"

@implementation FeedDownloadService

SYNTHESIZE_SINGLETON_FOR_CLASS(FeedDownloadService)

#define FEED_DOWNLOAD_DATA_DIR  @"feedDrawCache"
#define FEED_DATA_NAME_IN_ZIP   @"data"          // IMPORTANT, YOU MUST ALIGN THIS WITH SERVER

- (void)initPaths
{
    [FileUtil createDir:[FeedDownloadService getDownloadTopPath]];
    [FileUtil createDir:[FeedDownloadService getDownloadTempTopPath]];
    [FileUtil createDir:[FeedDownloadService getDownloadZipTopPath]];
}

- (id)init
{
    self = [super init];
    [self initPaths];
    return self;
}

+ (NSString*)getDownloadTopPath
{
    NSString* dir = [[FileUtil getAppCacheDir] stringByAppendingPathComponent:FEED_DOWNLOAD_DATA_DIR];
    return dir;
}

+ (NSString*)getDownloadTempTopPath
{
    NSString* dir = [[[FileUtil getAppCacheDir]
                      stringByAppendingPathComponent:FEED_DOWNLOAD_DATA_DIR]
                     stringByAppendingPathComponent:@"/download_temp/"];
    return dir;
}

+ (NSString*)getDownloadZipTopPath
{
    NSString* dir = [[[FileUtil getAppCacheDir]
                      stringByAppendingPathComponent:FEED_DOWNLOAD_DATA_DIR]
                     stringByAppendingPathComponent:@"/zip/"];
    return dir;
}

+ (NSString*)getFileUpdateDownloadZipPath:(NSString*)name
{
    return [[FeedDownloadService getDownloadZipTopPath] stringByAppendingPathComponent:name];
}

+ (NSString*)getFileUpdateDownloadPath:(NSString*)name
{
    return [[FeedDownloadService getDownloadTopPath]
            stringByAppendingPathComponent:[name stringByAppendingString:@"_zip"]];
}

+ (NSString*)getFileFinalPath:(NSString*)name
{
    return [[FeedDownloadService getDownloadTopPath]
            stringByAppendingPathComponent:name];
}

+ (NSString*)getFileUpdateDownloadTempPath:(NSString*)name
{
    return [[FeedDownloadService getDownloadTempTopPath] stringByAppendingPathComponent:name];
}

- (NSData*)unzipFile:(NSString *)zipFilePath unzipFilePath:(NSString*)unzipFilePath // moveToFilePath:(NSString*)moveToFilePath
{
    PPDebug(@"<unzipFile> start unzip %@", zipFilePath);
    if ([SSZipArchive unzipFileAtPath:zipFilePath
                        toDestination:unzipFilePath
                            overwrite:YES
                             password:nil
                                error:nil]) {
        PPDebug(@"<unzipFile> unzip %@ successfully", [zipFilePath lastPathComponent]);
    } else {
        PPDebug(@"<unzipFile> unzip %@ fail", [zipFilePath lastPathComponent]);
        return nil;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // delete files after it's unzip
        [FileUtil removeFile:zipFilePath];
    });
    
    NSString* dataFile = [unzipFilePath stringByAppendingPathComponent:FEED_DATA_NAME_IN_ZIP];
    NSData* data = [NSData dataWithContentsOfFile:dataFile];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // delete file after it's read
        [FileUtil removeFile:dataFile];
        
        // delete unzip file folder
        [FileUtil removeFile:unzipFilePath];
    });
    
    return data;
    
    /*
     NSFileManager* fileManager = [[NSFileManager alloc] init];
     
     // remove file before move
     if ([fileManager fileExistsAtPath:moveToFilePath]){
     [fileManager removeItemAtPath:moveToFilePath error:nil];
     }
     
     // move file
     NSString* fileToBeMoved = [unzipFilePath stringByAppendingPathComponent:FEED_DATA_NAME_IN_ZIP];
     NSError* error = nil;
     BOOL result = [fileManager moveItemAtPath:fileToBeMoved toPath:moveToFilePath error:&error];
     if (result){
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     // delete files after it's unzip
     [FileUtil removeFile:unzipFilePath];
     });
     }
     
     [fileManager release];
     */
}

// call this method to download data
- (NSData*)downloadDrawDataFile:(NSString*)fileURL fileName:(NSString*)fileName
{
    if (fileURL == nil)
        return nil;
    
    NSURL* url = [NSURL URLWithString:fileURL];
    if (url == nil)
        return nil;
    
    NSString* zipFileName = [fileName stringByAppendingPathExtension:@"zip"];
    
    ASIHTTPRequest* downloadHttpRequest = [ASIHTTPRequest requestWithURL:url];
    
    downloadHttpRequest.delegate = self;
    [downloadHttpRequest setAllowCompressedResponse:YES];
    //    [downloadHttpRequest setUsername:DEFAULT_HTTP_USER_NAME];
    //    [downloadHttpRequest setPassword:DEFAULT_HTTP_PASSWORD];
    
    NSString* destPath = [FeedDownloadService getFileUpdateDownloadZipPath:zipFileName];
    [downloadHttpRequest setDownloadDestinationPath:destPath];
    
    NSString* tempPath = [FeedDownloadService getFileUpdateDownloadTempPath:zipFileName];
    [downloadHttpRequest setTemporaryFileDownloadPath:tempPath];
    
    [downloadHttpRequest setDownloadProgressDelegate:nil];
    [downloadHttpRequest setAllowResumeForFileDownloads:YES];
    
    PPDebug(@"<downloadDrawDataFile> URL=%@, Local Temp=%@, Store At=%@",
            url.absoluteString, tempPath, destPath);
    
    [downloadHttpRequest startSynchronous];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath] == NO){
        PPDebug(@"<downloadDrawDataFile> failure, file not downloaded");
        return nil;
    }
    
    // unzip file
    NSString* unzipFilePath = [FeedDownloadService getFileUpdateDownloadPath:fileName];
    return [self unzipFile:destPath unzipFilePath:unzipFilePath]; //moveToFilePath:finalFilePath];
}


@end
