//
//  MusicItem.m
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicItem.h"
#import "LogUtil.h"

@implementation MusicItem

@synthesize fileName;
@synthesize downloadProgress;
@synthesize downloadSize;
@synthesize fileSize;
@synthesize request;
@synthesize deleteFlag;
@synthesize url;
@synthesize tempPath;
@synthesize localPath;
@synthesize status;

#define DOWNLOAD_KEY @"DOWNLOAD_KEY"

-(id)initWithUrl:(NSString*)url 
        fileName:(NSString*)fileName
        filePath:(NSString*)filePath
        tempPath:(NSString*)tempPath
{
    self = [super init];
    
    self.downloadSize = [NSNumber numberWithInt:0];
    self.status = [NSNumber numberWithInt:0];
    self.downloadProgress = [NSNumber numberWithFloat:0.0f];
    self.fileName = fileName;
    self.url = url;
    self.localPath = filePath;
    self.tempPath = tempPath;
    
    return self;
}

- (NSDictionary*)dictionaryForRequest
{
    return [NSDictionary dictionaryWithObject:self forKey:DOWNLOAD_KEY];
}

+ (MusicItem*)fromDictionary:(NSDictionary*)dict
{
    return [dict objectForKey:DOWNLOAD_KEY];
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.url forKey:KEY_ITEM_URL];
//    [aCoder encodeObject:self.downloadProgress forKey:KEY_ITEM_DOWNLOAD_PROGRESS];
//    [aCoder encodeObject:self.fileName forKey:KEY_ITEM_FILENAME];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    if (self = [super init]) {
//        self.url = [aDecoder decodeObjectForKey:KEY_ITEM_URL];
//        self.downloadProgress = [aDecoder decodeObjectForKey:KEY_ITEM_DOWNLOAD_PROGRESS];
//        self.fileName = [aDecoder decodeObjectForKey:KEY_ITEM_FILENAME];
//    }
//    
//    return self;
//}

#pragma Progress Delegate
- (void)setProgress:(float)newProgress
{
    self.downloadProgress = [NSNumber numberWithFloat:newProgress];
    if (self.fileSize != nil) {
        self.downloadSize = [NSNumber numberWithLongLong:[self.fileSize longLongValue]*newProgress];
    }
//    PPDebug(@"item (%@) download progress = %f", [self fileName], newProgress);
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength
{
    self.fileSize = [NSNumber numberWithLongLong:newLength];

}

@end
