//
//  MusicItem.h
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIProgressDelegate.h"
#import "ASIHTTPRequestDelegate.h"

#define KEY_ITEM_URL @"KEY_ITEM_URL"
#define KEY_ITEM_DOWNLOAD_PROGRESS @"KEY_ITEM_DOWNLOAD_PROGRESS"
#define KEY_ITEM_FILENAME @"KEY_ITEM_FILENAME"

enum DOWNLOAD_STATUS {
    DOWNLOAD_STATUS_NOT_STARTED = 0,
    DOWNLOAD_STATUS_STARTED,
    DOWNLOAD_STATUS_PAUSE,
    DOWNLOAD_STATUS_FAIL,
    DOWNLOAD_STATUS_FINISH = 18,
};

@interface MusicItem : NSObject<ASIProgressDelegate, ASIHTTPRequestDelegate>

@property (nonatomic, retain) NSNumber * downloadSize;
@property (nonatomic, retain) NSNumber * fileSize;
@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString * localPath;
@property (nonatomic, copy) NSString * tempPath;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, retain) NSNumber * deleteFlag;
@property (nonatomic, retain) NSNumber * downloadProgress;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, assign) ASIHTTPRequest * request;

-(id)initWithUrl:(NSString*)url 
          fileName:(NSString*)fileName
          filePath:(NSString*)filePath
          tempPath:(NSString*)tempPath;

- (NSDictionary*)dictionaryForRequest;

+ (MusicItem*)fromDictionary:(NSDictionary*)dict;
@end
