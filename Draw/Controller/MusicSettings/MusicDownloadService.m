//
//  MusicDownloadService.m
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicDownloadService.h"
#import "StringUtil.h"
#import "FileUtil.h"
#import "MusicItem.h"
#import "ASIHTTPRequest.h"

MusicDownloadService* globalDownloadService;

@implementation MusicDownloadService

@synthesize queue;
@synthesize downloadDir;
@synthesize downloadTempDir;

+ (MusicDownloadService*)defaultService
{
    if (globalDownloadService == nil){
        globalDownloadService = [[MusicDownloadService alloc] init];
        
    }
    
    return globalDownloadService;
}

- (void)dealloc
{
    [queue release];
    [downloadDir release];
    [downloadTempDir release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    self.downloadDir = [[FileUtil getAppHomeDir] stringByAppendingFormat:DOWNLOAD_DIR];
    self.downloadTempDir = [[FileUtil getAppHomeDir] stringByAppendingFormat:DOWNLOAD_TEMP_DIR];  
    
    // create queue
    [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    [self.queue setMaxConcurrentOperationCount:20];
    
    // create directory if not exist
    [FileUtil createDir:self.downloadTempDir];
    [FileUtil createDir:self.downloadDir]; 
    
    return self;
}

+ (NSArray*) findAllItems
{
    return nil;
}

- (NSString*)getFilePath:(NSString*)fileName
{
    return [self.downloadDir stringByAppendingString:fileName];
}

- (NSString*)getTempFilePath:(NSString*)fileName
{
    return [self.downloadTempDir stringByAppendingString:fileName];
}

- (BOOL)startDownload:(MusicItem*)item
{
    NSURL* url = [NSURL URLWithString:[item url]];
    
    // start to download
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setDownloadDestinationPath:[item localPath]];    
    [request setAllowResumeForFileDownloads:YES];
    [request setTemporaryFileDownloadPath:[item tempPath]];    
    [request setUserInfo:[item dictionaryForRequest]];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:item];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    NSLog(@"download file, URL=%@, save to %@, temp path %@", [item url], [item localPath], [item tempPath]);
    
    [[self queue] addOperation:request];
    return YES;
}

- (BOOL)downloadFile:(NSString*)urlString
{
    NSURL* url = [NSURL URLWithString:urlString];
    
//    if ([[UIApplication sharedApplication] canOpenURL:url] == NO){
//        PPDebug(@"downloadFile but cannot open URL = %@", urlString);
//        return NO;
//    }
    
    NSString* fileName = [NSString GetUUID]; 
    NSString* filePath = [self getFilePath:fileName];
    NSString* tempFilePath = [self getTempFilePath:fileName];
    
    MusicItem *item = [[MusicItem alloc] initWithUrl:urlString fileName:fileName filePath:filePath tempPath:tempFilePath];
    
    [self startDownload:item];    
    return YES;

}

@end
