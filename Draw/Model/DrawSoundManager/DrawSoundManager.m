//
//  DrawSoundManager.m
//  Draw
//
//  Created by Kira on 12-12-13.
//
//

#import "DrawSoundManager.h"
#import "SynthesizeSingleton.h"

@implementation DrawSoundManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawSoundManager)

+ (DrawSoundManager*)defaultManager
{
    return [DrawSoundManager sharedDrawSoundManager];
}

- (NSString*)clickWordSound
{
    return @"ding.m4a";
}

- (NSString*)someoneEnterRoomSound
{
    return @"dingding.mp3";
}

- (NSString*)guessWrongSound
{
    return @"oowrong.mp3";
}

- (NSString*)guessCorrectSound
{
    return @"correct.mp3";
}

- (NSString*)congratulationsSound
{
    return @"congratulations.mp3";
}

@end
