//
//  GameTask.h
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    
    TASK_STATUS_WAIT_FOR_START = -1,     // 等待开始
    TASK_STATUS_CAN_TAKE = 0,            // 可以领取
    TASK_STATUS_TAKEN,                   // 已经领取
    TASK_STATUS_EXPIRED                  // 已经过期
    
} GameTaskStatus;

@interface GameTask : NSObject

@property (nonatomic, retain) NSString* displayName;
@property (nonatomic, retain) NSString* desc;
@property (nonatomic, assign) int badgeCount;
@property (nonatomic, assign) GameTaskStatus status;

@end
