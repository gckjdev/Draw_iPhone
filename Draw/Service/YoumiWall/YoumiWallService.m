//
//  YoumiWallService.m
//  Draw
//
//  Created by  on 12-6-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YoumiWallService.h"
#import "DrawConstants.h"
#import "UserManager.h"
#import "PPDebug.h"
#import "AccountService.h"

@implementation YoumiWallService

static YoumiWallService *_defaultService = nil;

+ (YoumiWallService *)defaultService
{
    if (_defaultService == nil) {
        _defaultService = [[YoumiWallService alloc] init];
    }
    return _defaultService;
}

- (id)init
{
    self = [super init];
    if (self) {
        [YouMiWall setShouldGetLocation:NO];
        _wall = [[YouMiWall alloc] initWithAppID:YOUMI_APP_ID withAppSecret:YOUMI_APP_KEY];
//        _wall.userID = [[UserManager defaultManager] userId];                // 设置你用户的账户名称        

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(requestPointSuccess:) 
                                                     name:YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION 
                                                   object:nil];    
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION 
                                                  object:nil];
    
    PPRelease(_wall);    
    [super dealloc];
}



#define YOUMI_WALL_ORDER_LIST @"YOUMI_WALL_ORDER_LIST"

- (BOOL)isPointEarned:(NSString*)orderId
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *orderList = [userDefault objectForKey:YOUMI_WALL_ORDER_LIST];
    if (orderList == nil){
        return NO;
    }
    
    for (NSString* oid in orderList){
        if ([oid isEqualToString:orderId]){
            return YES;
        }
    }
    
    return NO;
}

- (void)updateOrder:(NSDictionary*)order
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    // read old data
    NSArray *oldOrderList = [userDefault objectForKey:YOUMI_WALL_ORDER_LIST];
    NSMutableArray *newOrderList = [[NSMutableArray alloc] init];
    if (oldOrderList != nil){
        [newOrderList addObjectsFromArray:oldOrderList];
    }
    
    // add new order
    NSString* orderId = [order objectForKey:kOneAccountRecordOrderIDOpenKey];
    [newOrderList addObject:orderId];    

    // save
    [userDefault setObject:newOrderList forKey:YOUMI_WALL_ORDER_LIST];
    [userDefault synchronize];                            
    
    [newOrderList release];
}

- (void)requestPointSuccess:(NSNotification *)note {
    
    PPDebug(@"<requestPointSuccess> result=%@", [note description]);
    
    NSDictionary *info = [note userInfo];
    NSArray *records = [info valueForKey:YOUMI_WALL_NOTIFICATION_USER_INFO_EARNED_POINTS_KEY];    
    for (NSDictionary *oneRecord in records) {
        NSString *orderID = [oneRecord objectForKey:kOneAccountRecordOrderIDOpenKey];
//        NSString *userID = [oneRecord objectForKey:kOneAccountRecordUserIDOpenKey];
        NSString *name = [oneRecord objectForKey:kOneAccountRecordNameOpenKey];
        NSInteger earnedPoint = [(NSNumber *)[oneRecord objectForKey:kOneAccountRecordPoinstsOpenKey] integerValue];

        if ([self isPointEarned:orderID] == NO){
            PPDebug(@"<YoumiWallService> add conins (%d) for order (%@)", earnedPoint, orderID);
            
            // charge account
            [[AccountService defaultService] chargeAccount:earnedPoint source:YoumiAppReward];
            
            // update point earning order
            [self updateOrder:[note userInfo]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"已经成功新增%d金币",earnedPoint] message:[NSString stringWithFormat:@"来源于安装了应用[%@]", name] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            
            [alert show];
            [alert release];
        }
        else{
            PPDebug(@"<YoumiWallService> order (%@) already added coins (%d)", orderID, earnedPoint);            
        }
        
    }        
}

- (void)queryPoints {
    PPDebug(@"YoumiWallService, query points");
    [_wall requestEarnedPoints];
}


@end
