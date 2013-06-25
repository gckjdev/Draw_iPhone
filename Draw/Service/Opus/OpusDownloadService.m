//
//  OpusDownloadService.m
//  Draw
//
//  Created by 王 小涛 on 13-6-24.
//
//

#import "OpusDownloadService.h"
#import "ASIHTTPRequest.h"
#import "SynthesizeSingleton.h"
#import "FileUtil.h"

@interface OpusDownloadService()

@property (copy, nonatomic) NSString *tempDir;

@end

@implementation OpusDownloadService

SYNTHESIZE_SINGLETON_FOR_CLASS(OpusDownloadService);

- (void)dealloc{
    [_tempDir release];
    [super dealloc];
}

- (id)init{
    
    if (self = [super init]) {
        self.tempDir = [[FileUtil getAppTempDir] stringByAppendingPathComponent:@"download/"];
        [FileUtil createDir:_tempDir];
    }
    
    return self;
}

// call this method to download data
- (NSString *)downloadFileSynchronous:(NSString *)fileUrl
                        destDir:(NSString*)destDir
               progressDelegate:(id)progressDelegate
{
    if (fileUrl == nil || destDir == nil) return nil;
    
    NSURL* url = [NSURL URLWithString:fileUrl];
    if (url == nil) return nil;
    
    [FileUtil createDir:destDir];
    
    NSString *fileName = [fileUrl lastPathComponent];
    NSString *destPath = [destDir stringByAppendingPathComponent:fileName];
    NSString *tempPath = [_tempDir stringByAppendingPathComponent:fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        return destPath;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;

    // The full file will be moved here if and when the request completes successfully
    [request setDownloadDestinationPath:destPath];
    
    // This file has part of the download in it already
    [request setTemporaryFileDownloadPath:tempPath];
    [request setAllowResumeForFileDownloads:YES];
    [request setDownloadProgressDelegate:progressDelegate];
    [request startSynchronous];
    
    PPDebug(@"<%s> URL=%@, Local Temp=%@, Store At=%@",
            __FUNCTION__ , url.absoluteString, tempPath, destPath);

    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath] == NO){
        PPDebug(@"<%s> failure, file not downloaded", __FUNCTION__);
        return nil;
    }
    
    return destPath;
}

@end
