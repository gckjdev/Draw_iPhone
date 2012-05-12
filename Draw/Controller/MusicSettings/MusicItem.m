//
//  MusicItem.m
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicItem.h"

@implementation MusicItem

@synthesize musicName;
@synthesize downloadProgress;
@synthesize downloadSize;
@synthesize request;
@synthesize deleteFlag;
@synthesize url;
@synthesize tempPath;
@synthesize localPath;

#define DOWNLOAD_KEY @"DOWNLOAD_KEY"

-(id)initWithUrl:(NSString*)url 
        fileName:(NSString*)fileName
        filePath:(NSString*)filePath
        tempPath:(NSString*)tempPath
{
    self = [super init];
    
    self.downloadSize = [NSNumber numberWithInt:0];
    self.musicName = fileName;
    self.url = url;
    self.localPath = localPath;
    self.tempPath = tempPath;
    
    return self;
}

- (NSDictionary*)dictionaryForRequest
{
    return [NSDictionary dictionaryWithObject:self forKey:DOWNLOAD_KEY];
}

@end
