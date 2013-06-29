//
//  OpusGuessRecorder.m
//  Draw
//
//  Created by 王 小涛 on 13-6-29.
//
//

#import "OpusGuessRecorder.h"

@implementation OpusGuessRecorder

+ (void)setOpusAsGuessed:(NSString *)opusId{
    
    NSString *opusKey = [self opusKeyWithOpusId:opusId];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:opusKey];
}

+ (BOOL)isOpusGuessed:(NSString *)opusId{
    
    NSString *opusKey = [self opusKeyWithOpusId:opusId];
    NSNumber *guessed = [[NSUserDefaults standardUserDefaults] objectForKey:opusKey];
    return guessed.boolValue;
}

+ (NSString *)opusKeyWithOpusId:(NSString *)opusId{
    
    return [NSString stringWithFormat:@"guessed_opusId_%@", opusId];
}

@end
