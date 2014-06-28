//
//  UserTutorialManager.h
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import <Foundation/Foundation.h>
#import "Tutorial.pb.h"

@interface UserTutorialManager : NSObject

+ (UserTutorialManager*)defaultManager;

// 用户添加/开始学习某个教程
- (PBUserTutorial*)addTutorial:(PBTutorial*)tutorial;

- (void)syncUserTutorial:(NSString*)utLocalId syncStatus:(BOOL)syncStatus;

@end
