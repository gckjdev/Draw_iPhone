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
}NotificationType;

@interface NotificationManager : NSObject
{
    
}

+ (NotificationType) typeForUserInfo:(NSDictionary *)notification;
@end
