//
//  PBTutorial+Extend.h
//  Draw
//
//  Created by qqn_pipi on 14-6-28.
//
//

#import "Tutorial.pb.h"

@interface PBTutorial (Extend)

- (NSString*)name;
- (NSString*)desc;

- (NSString*)categoryName;
- (PBStage*)getStageByIndex:(NSUInteger)index;
- (PBStage*)nextStage:(NSUInteger)index;

@end


@interface PBStage (Extend2)

-(NSString *) name;
-(NSString *) desc;

@end

@interface PBUserTutorial (Extend3)

- (BOOL)isStageLock:(int)stageIndex;
- (int)progress;

@end

@interface PBUserStage (Extend4)

- (NSString*)getCurrentChapterOpusId;

@end

@interface PBUserStage_Builder (Extend5)

- (NSString*)getCurrentChapterOpusId;

@end