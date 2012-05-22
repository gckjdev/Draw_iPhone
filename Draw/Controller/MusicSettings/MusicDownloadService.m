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
#import "LogUtil.h"
#import "MusicItemManager.h"

MusicDownloadService* globalDownloadService;
NSMutableArray *list;

@implementation MusicDownloadService

@synthesize queue;
@synthesize downloadDir;
@synthesize downloadTempDir;

+ (MusicDownloadService*)defaultService
{
    if (globalDownloadService == nil){
        globalDownloadService = [[MusicDownloadService alloc] init];
        list = [[NSMutableArray alloc] init];
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
    [self.queue setMaxConcurrentOperationCount:10];
    
    // create directory if not exist
    [FileUtil createDir:self.downloadTempDir];
    [FileUtil createDir:self.downloadDir]; 
    
    return self;
}

- (void)saveItem:(MusicItem*)item
{
    [list addObject:item];
}

- (NSArray*) findAllItems
{
    return list;
}

- (NSString*)getFilePath:(NSString*)fileName
{
    return [self.downloadDir stringByAppendingString:fileName];
}

- (NSString*)getTempFilePath:(NSString*)fileName
{
    return [self.downloadTempDir stringByAppendingString:fileName];
}

- (void)requestDone:(ASIHTTPRequest *)request
{
    MusicItem *item = [MusicItem fromDictionary:request.userInfo];
    [[MusicItemManager defaultManager] downloadFinish:item];
    [self moveFile:item];
    PPDebug(@"item (%@) download done", [item url]);
    
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    MusicItem *item = [MusicItem fromDictionary:request.userInfo];
    [[MusicItemManager defaultManager] downloadFailure:item];
    PPDebug(@"item (%@) download failure, response done = %@", [item url], [error description]);
    
}

- (BOOL)startDownload:(MusicItem*)item
{
    NSURL* url = [NSURL URLWithString:[item url]];
    if (url == nil)
        return NO;
    
    // start to download
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [[MusicItemManager defaultManager] downloadStart:item request:request];

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
    [request setTimeOutSeconds:30.0];
    
    PPDebug(@"download file, URL=%@, save to %@, temp path %@", [item url], [item localPath], [item tempPath]);
    
    [[self queue] addOperation:request];
    return YES;
}

- (BOOL)downloadFile:(NSString*)urlString
{
    NSURL* url = [NSURL URLWithString:urlString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url] == NO){
        PPDebug(@"downloadFile but cannot open URL = %@", urlString);
        return NO;
    }
    
    NSString* fileName = [NSString GetUUID]; 
    NSString* filePath = [self getFilePath:fileName];
    NSString* tempFilePath = [self getTempFilePath:fileName];
    
    MusicItem *item = [[[MusicItem alloc] initWithUrl:urlString fileName:fileName filePath:filePath tempPath:tempFilePath] autorelease];
    
    [self startDownload:item];    
    return YES;

}

- (NSString *)replaceUnicode:(NSString *)yourString {  
    
    int i = 0;
    int len = [yourString length];    
    char* charArray = malloc(sizeof(char)*(len+1));
    for (i=0; i<len; i++){
        unichar ch = [yourString characterAtIndex:i];
        charArray[i] = ch;
        //        PPDebug(@"char = %02x, %d, %c", ch, ch, ch);
    }
    charArray[i] = '\0';
    
    NSString* str = [[[NSString alloc] initWithUTF8String:charArray] autorelease];    
    if (str == nil){
        // if UTF8 conversion fails, then use GB_18030
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        str = [NSString stringWithCString:charArray encoding:enc];
        PPDebug(@"UTF8String = %s", [str UTF8String]);
    }    
    return str;
}

- (NSString*)getFileNameFromContentDisposition:(NSString*)data
{
    if (data == nil)
        return nil;
    
    NSString* retStr = [self replaceUnicode:data];    
    retStr = [retStr stringByReplacingOccurrencesOfString:@"attachment;" withString:@""];    
    retStr = [retStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    retStr = [retStr stringByReplacingOccurrencesOfString:@"filename=" withString:@""];
    retStr = [retStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
    
    PPDebug(@"Content Disposition = %@, %@", data, retStr);        
    return retStr;
}


- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    MusicItem *item = [MusicItem fromDictionary:request.userInfo];        
    
    // rename item here
    NSString* fileName1 = [self getFileNameFromContentDisposition:[responseHeaders valueForKey:@"Content-Disposition"]];
    NSString* fileName2 = [responseHeaders objectForKey:@"Content-Location"];
    
    PPDebug(@"item (%@) didReceiveResponseHeaders Content-Disposition = %@, Content-Location = %@", [item url], fileName1, fileName2);    
    
    NSString* fileName = nil;
    if (fileName1 != nil){
        fileName = [fileName1 lastPathComponent];    
    }
    else if (fileName2 != nil){
        fileName = [fileName2 lastPathComponent];
    }
    else{
        fileName = [[request url] lastPathComponent];
    }
    
    // TODO
    if (fileName == nil){
        PPDebug(@"<didReceiveResponseHeaders> Cannot create file name for download request (%@)", [request description]);
        [request clearDelegatesAndCancel];
        [self requestWentWrong:request];
        return;
    }
        
    long fileSize = [[responseHeaders valueForKey:@"Content-Length"] intValue];
    
    // set right file name here
    MusicItemManager *manager = [MusicItemManager defaultManager];
    [manager setFileInfo:item newFileName:fileName fileSize:fileSize];
    
}

- (void)moveFile:(MusicItem*)item
{
    NSString* finalFilePath = [self getFilePath:item.fileName];
    NSError* error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:item.localPath toPath:finalFilePath error:&error];
    if (error != nil){
        PPDebug(@"fail to rename file from %@ to %@", item.localPath, finalFilePath);
    }
    else{
        [item setLocalPath:finalFilePath];
    }
}


- (void)requestStarted:(ASIHTTPRequest *)request
{
    MusicItem *item = [MusicItem fromDictionary:request.userInfo]; 
    NSLog(@"item requestStarted, url = %@", [item.url description]);  

    [[MusicItemManager defaultManager] saveItem:item];
}

- (void)resumeDownloadItem:(MusicItem*)item
{
    [self startDownload:item];
}

- (void)resumeAllDownloadItemByStatus:(int)status
{
    NSArray* list = [[MusicItemManager defaultManager] findAllItemsByStatus:status];
    for (MusicItem* item in list){
        [self resumeDownloadItem:item];
    }
}

- (void)resumeAllDownloadItem
{
//    [self resumeAllDownloadItemByStatus:DOWNLOAD_STATUS_FAIL];
    [self resumeAllDownloadItemByStatus:DOWNLOAD_STATUS_NOT_STARTED];
    [self resumeAllDownloadItemByStatus:DOWNLOAD_STATUS_STARTED];

}

@end
