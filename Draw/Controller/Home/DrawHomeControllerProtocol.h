//
//  DrawHomeControllerProtocol.h
//  Draw
//
//  Created by Kira on 13-5-15.
//
//

#import <Foundation/Foundation.h>
#import "NotificationManager.h"

@protocol DrawHomeControllerProtocol <NSObject>

- (BOOL)isRegistered;
- (BOOL)toRegister;
- (void)updateAllBadge;
@property (nonatomic, assign) NotificationType notificationType; 
@end
