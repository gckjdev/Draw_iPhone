//
//  OpusClassInfoManager.h
//  Draw
//
//  Created by qqn_pipi on 14-6-5.
//
//

#import <Foundation/Foundation.h>

@class PPSmartUpdateData;

@interface OpusClassInfoManager : NSObject

@property (nonatomic, retain) PPSmartUpdateData* smartData;
@property (nonatomic, retain) NSMutableArray* opusClassList;

+ (OpusClassInfoManager*)defaultManager;
- (void)autoUpdate;

//- (NSArray*)defaultSelectedClass;

@end
