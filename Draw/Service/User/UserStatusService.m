//
//  UserStatusService.m
//  Draw
//
//  Created by  on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserStatusService.h"
#import "UserManager.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"
#import "PPDebug.h"

#define REPORT_STATUS_TIMER_INTERVAL       (20*60)     // 20 minutes

@implementation UserStatusService

@synthesize timer = _timer;

UserStatusService* _defaultService;

+ (UserStatusService*)defaultService
{
    if (_defaultService == nil)
        _defaultService = [[UserStatusService alloc] init];
    
    return _defaultService;
}

- (id)init
{
    self = [super init];

    return self;
}

- (void)dealloc
{
    PPRelease(_timer);
    [super dealloc];
}

- (void)reportStatus:(int)status
{
    NSString* userId = [[UserManager defaultManager] userId];
    if ([userId length] == 0)
        return;
    
    PPDebug(@"<reportStatus> status=%d", status);
    dispatch_async(workingQueue, ^{
        [GameNetworkRequest reportStatus:SERVER_URL 
                                   appId:[ConfigManager appId] 
                                  userId:userId
                                  status:status];        
    });
    
}

- (void)reportStatusOnline
{
    [self reportStatus:USER_STATUS_ONLINE];
}

- (void)reportStatusOffline
{
    [self reportStatus:USER_STATUS_OFFLINE];    
}

- (void)handleReportStatusTimer:(NSTimer*)timer
{
    [self reportStatus:USER_STATUS_ONLINE];
}

- (void)start
{
    if (self.timer != nil){
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self reportStatus:USER_STATUS_ONLINE];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:REPORT_STATUS_TIMER_INTERVAL target:self selector:@selector(handleReportStatusTimer:) userInfo:nil repeats:YES]; 
}

- (void)stop
{
    if (self.timer != nil){
        [self.timer invalidate];
        self.timer = nil;
    }    
    
    [self reportStatusOffline];
}

@end
