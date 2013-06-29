//
//  OpusGuessRecorder.h
//  Draw
//
//  Created by 王 小涛 on 13-6-29.
//
//

#import <Foundation/Foundation.h>

@interface OpusGuessRecorder : NSObject

+ (void)setOpusAsGuessed:(NSString *)opusId;
+ (BOOL)isOpusGuessed:(NSString *)opusId;

@end
