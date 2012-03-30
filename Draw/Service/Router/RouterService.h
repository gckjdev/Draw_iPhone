//
//  RouterService.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

@class TrafficServer;

@protocol RouterServiceDelegate <NSObject>

- (void)didServerListFetched:(int)result;

@end

@interface RouterService : CommonService

@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, retain) NSMutableArray *failureServerList;

+ (RouterService*)defaultService;

- (void)fetchServerList:(id<RouterServiceDelegate>)delegate;
- (void)fetchServerListAtBackground;
- (void)tryFetchServerList:(id<RouterServiceDelegate>)delegate;

- (void)startUpdateTimer;
- (void)stopUpdateTimer;

- (TrafficServer*)assignTrafficServer;

- (void)putServerInFailureList:(NSString*)serverAddress port:(int)port;

@end
