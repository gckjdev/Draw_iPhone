//
//  NotificationManager.m
//  Draw
//
//  Created by  on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager

#define PUSH_TYPE (@"PT")

+ (NotificationType) typeForUserInfo:(NSDictionary *)userInfo
{
    NSNumber *type = [userInfo objectForKey:PUSH_TYPE];
    if (type) {
        return type.integerValue;
    }
    return NotificationTypeNone;
}

@end
