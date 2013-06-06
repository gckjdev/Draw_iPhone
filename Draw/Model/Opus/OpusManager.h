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

- (id)opusWithOpusKey:(NSString *)opusKey;

- (void)saveOpus:(Opus*)opus;
- (void)deleteOpus:(NSString *)opusKey;

// TODO compare with MyPaintManager

@end
