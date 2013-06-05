//
//  OpusManager.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>
#import "Opus.h"



@interface OpusManager : NSObject

+ (id)defaultManager;

- (Opus*)opusWithOpusId:(NSString *)opusId;

- (void)saveOpus:(Opus*)opus;
- (void)deleteOpus:(NSString*)opusId;

// TODO compare with MyPaintManager

@end
