//
//  MusicDownloadService.h
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "ASIHTTPRequestDelegate.h"
#import "MusicItem.h"

#define DOWNLOAD_DIR                @"/download/incoming/"
#define DOWNLOAD_TEMP_DIR           @"/download/temp/"

@interface MusicDownloadService : CommonService <ASIHTTPRequestDelegate>

@property (nonatomic, retain) NSOperationQueue* queue;
@property (nonatomic, retain) NSString* downloadDir;
@property (nonatomic, retain) NSString* downloadTempDir;

- (NSArray*) findAllItems;
- (void)saveItem:(MusicItem*)item;

+ (MusicDownloadService*)defaultService;

- (BOOL)downloadFile:(NSString*)urlString;
- (void)resumeAllDownloadItem;
@end
