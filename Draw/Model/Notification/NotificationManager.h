//
//  NotificationManager.h
//  Draw
//
//  Created by  on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    NotificationTypeNone = 0,
    NotificationTypeRoom = 1,
    NotificationTypeMessage,
    NotificationTypeFeed,
    NotificationTypeFan,
    NotificationTypeComment,
    NotificationTypeDrawToMe
}NotificationType;



@interface NotificationManager : NSObject
{

}

+ (NotificationManager *)defaultManager;
- (void)showNotification:(NSDictionary *)notification;
- (void)hideNotification;
- (void)hideNotificationForType:(NotificationType)type;
+ (int)badgeForType:(NotificationType)type withNotification:(NSDictionary *)notification;

+ (NotificationType) typeForUserInfo:(NSDictionary *)notification;

- (void)saveStatistic:(NSDictionary *)notification;

@end
