//
//  OpusClassInfoManager.h
//  Draw
//
//  Created by qqn_pipi on 14-6-5.
//
//

#import <Foundation/Foundation.h>

@class PPSmartUpdateData;
@class OpusClassInfo;

@interface OpusClassInfoManager : NSObject

@property (nonatomic, retain) PPSmartUpdateData* smartData;
@property (nonatomic, retain) NSMutableArray* opusClassList;
@property (nonatomic, retain) NSMutableArray* homeDisplayClassList;
@property (nonatomic, retain) NSMutableArray* userDisplayClassList;

+ (OpusClassInfoManager*)defaultManager;
- (void)autoUpdate;

- (void)saveUserDisplayList:(NSArray*)opusInfoClassList;
- (OpusClassInfo*)findOpusClassInfo:(NSString*)opusClassId;

//- (NSArray*)defaultSelectedClass;

@end
