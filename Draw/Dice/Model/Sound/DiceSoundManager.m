//
//  DiceSoundManager.m
//  Draw
//
//  Created by Orange on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceSoundManager.h"
#import "AudioManager.h"

#define CALL_DICE_BASE_NAME     @"callDice"
#define SOUND_SUFFIX            @"m4a"

static DiceSoundManager* shareManager;

@implementation DiceSoundManager


+ (DiceSoundManager*)defaultManager
{
    if (shareManager == nil) {
        shareManager = [[DiceSoundManager alloc] init];
    }
    return shareManager;
}

- (NSString*)creatCallDiceName:(int)number 
                          dice:(int)dice 
                        gender:(BOOL)gender
{
    return [NSString stringWithFormat:@"%@_%d_%d_%@.%@",CALL_DICE_BASE_NAME, number, dice, gender?@"M":@"F", SOUND_SUFFIX];
}

- (NSArray*)diceSoundNameArray
{
    NSMutableArray* soundNames = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 1; i <= 6; i ++) {
        for (int j = 1; j <= 30; j ++) {
            [soundNames addObject:[self creatCallDiceName:j 
                                                     dice:i 
                                                   gender:YES]];
            [soundNames addObject:[self creatCallDiceName:j 
                                                     dice:i 
                                                   gender:NO]];
        }
    }
    [soundNames addObject:@"openDice_M.m4a"];
    [soundNames addObject:@"openDice_F.m4a"];
    [soundNames addObject:@"scrambleToOpenDice_M.m4a"];
    [soundNames addObject:@"scrambleToOpenDice_F.m4a"];

    return soundNames;
}
- (void)callNumber:(int)number 
              dice:(int)dice 
            gender:(BOOL)gender
{
    [[AudioManager defaultManager] playSoundByName:[self creatCallDiceName:number dice:dice gender:gender]];
}

- (void)openDice:(BOOL)gender
{
    if (gender) {
        [[AudioManager defaultManager] playSoundByName:@"openDice_M.m4a"];
    } else {
        [[AudioManager defaultManager] playSoundByName:@"openDice_F.m4a"];
    }
    
}
- (void)scrambleOpen:(BOOL)gender
{
    if (gender) {
        [[AudioManager defaultManager] playSoundByName:@"scrambleToOpenDice_M.m4a"];
    } else {
        [[AudioManager defaultManager] playSoundByName:@"scrambleToOpenDice_F.m4a"];
    }
}

@end
