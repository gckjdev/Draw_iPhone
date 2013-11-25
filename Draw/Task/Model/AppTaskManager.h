//
//  AppTaskManager.h
//  Draw
//
//  Created by qqn_pipi on 13-11-25.
//
//

#import <Foundation/Foundation.h>

@class PPSmartUpdateData;
@class AppTask;

@interface AppTaskManager : NSObject

@property (nonatomic, retain) PPSmartUpdateData* smartData;
@property (nonatomic, retain) NSMutableArray* taskList;

+ (AppTaskManager*)defaultManager;
- (void)autoUpdate;

@end
