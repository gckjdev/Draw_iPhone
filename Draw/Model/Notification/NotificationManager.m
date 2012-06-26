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

#define FAN_BADGE  @"FAB"
#define MESSAGE_BADGE  @"MB"
#define FEED_BADGE  @"FEB"
#define ROOM_BADGE  @"RB"

+ (int)intValueOfUserInfo:(NSDictionary *)userInfo forKey:(NSString *)key
{
    if (key == nil || userInfo == nil) {
        return 0;
    }
    NSNumber *value = [userInfo objectForKey:key];
    if (value) {
        return value.intValue;
    }
    return 0;    
}

+ (NotificationType) typeForUserInfo:(NSDictionary *)userInfo
{
    NSNumber *type = [userInfo objectForKey:PUSH_TYPE];
    if (type) {
        return type.integerValue;
    }
    return NotificationTypeNone;
}

+ (int)feedBadge:(NSDictionary *)userInfo
{
    return [NotificationManager intValueOfUserInfo:userInfo forKey:FEED_BADGE];
}
+ (int)fanBadge:(NSDictionary *)userInfo
{
    return [NotificationManager intValueOfUserInfo:userInfo forKey:FAN_BADGE];    
}
+ (int)roomBadge:(NSDictionary *)userInfo
{
    return [NotificationManager intValueOfUserInfo:userInfo forKey:ROOM_BADGE];
}
+ (int)messageBadge:(NSDictionary *)userInfo
{
    return [NotificationManager intValueOfUserInfo:userInfo forKey:MESSAGE_BADGE];
}


@end
