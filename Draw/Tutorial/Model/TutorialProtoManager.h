//
//  TutorialProtoManager.h
//  Draw
//
//  Created by ChaoSo on 14-9-11.
//
//

#import <Foundation/Foundation.h>
#import "StorageManager.h"
@class PPSmartUpdateData;
@class TutorialProtoModel;
@interface TutorialProtoManager : NSObject
@property (nonatomic, retain) PPSmartUpdateData* smartData;
@property (nonatomic, retain) StorageManager* imageManager;
@property (nonatomic, retain) NSMutableArray* tutorialList;

+ (TutorialProtoManager*)defaultManager;
//- (void)autoUpdate:(dispatch_block_t)block;
- (UIImage*)getImage:(TutorialProtoModel*)bb;

@end
