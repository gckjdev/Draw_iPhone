//
//  DiceSoundManager.m
//  Draw
//
//  Created by Orange on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceSoundManager.h"
#import "AudioManager.h"
#import "LocaleUtils.h"

#define CALL_DICE_BASE_NAME     @"callDice"
#define MESSAGE_BASE_NAME       @"message"
#define SOUND_SUFFIX            @"m4a"
#define LANGUAGE_ENGLISH        @"_EN"
#define LANGUAGE_CHINESE        @""

#define FEMALE                  @"F"
#define MALE                    @"M"

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
    return [NSString stringWithFormat:@"%@_%d_%d_%@%@.%@",CALL_DICE_BASE_NAME, number, dice, gender?MALE:FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH, SOUND_SUFFIX];
}

- (NSArray*)diceSoundNameArray
{
    NSMutableArray* soundNames = [[[NSMutableArray alloc] init] autorelease];

//    for (int i = 1; i <= 6; i ++) {
//        for (int j = 1; j <= 30; j ++) {
//            [soundNames addObject:[self creatCallDiceName:j 
//                                                     dice:i 
//                                                   gender:YES]];
//            [soundNames addObject:[self creatCallDiceName:j 
//                                                     dice:i 
//                                                   gender:NO]];
//        }
//    }
//    for (int i = 1; i <= 9; i ++) {
//        [soundNames addObject:[NSString stringWithFormat:@"%@_%d_%@%@.m4a", MESSAGE_BASE_NAME, i , MALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//        [soundNames addObject:[NSString stringWithFormat:@"%@_%d_F%@%@.m4a", MESSAGE_BASE_NAME, i ,FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//    }
//    [soundNames addObject:[NSString stringWithFormat:@"openDice_%@%@.m4a", MALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//    [soundNames addObject:[NSString stringWithFormat:@"openDice_%@%@.m4a", FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//    [soundNames addObject:[NSString stringWithFormat:@"scrambleToOpenDice_%@%@.m4a", MALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//    [soundNames addObject:[NSString stringWithFormat:@"scrambleToOpenDice_%@%@.m4a", FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//    
//    [soundNames addObject:[NSString stringWithFormat:@"cutDice_%@%@.m4a", MALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//    [soundNames addObject:[NSString stringWithFormat:@"cutDice_%@%@.m4a", FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//    
//    [soundNames addObject:[NSString stringWithFormat:@"plusOne_%@%@.m4a", MALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
//    [soundNames addObject:[NSString stringWithFormat:@"plusOne_%@%@.m4a", FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];


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
    [[AudioManager defaultManager] playSoundByName:[NSString stringWithFormat:@"openDice_%@%@.m4a", gender?MALE:FEMALE,[LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];

}
- (void)scrambleOpen:(BOOL)gender
{
    [[AudioManager defaultManager] playSoundByName:[NSString stringWithFormat:@"scrambleToOpenDice_%@%@.m4a", gender?MALE:FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
}

- (void)cutDice:(BOOL)gender
{
    [[AudioManager defaultManager] playSoundByName:[NSString stringWithFormat:@"cutDice_%@%@.m4a", gender?MALE:FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
  
}

- (void)plusOne:(BOOL)gender
{
    [[AudioManager defaultManager] playSoundByName:[NSString stringWithFormat:@"pluseOne_%@%@.m4a", gender?MALE:FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];

}

- (NSString*)getMessageSoundNameById:(int)messageId
{
    return [NSString stringWithFormat:[NSString stringWithFormat:@"%@_%d%@",MESSAGE_BASE_NAME, messageId, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
}

- (void)playVoiceById:(int)messageId 
               gender:(BOOL)gender
{
    NSString* name = [self getMessageSoundNameById:messageId];
    [[AudioManager defaultManager] playSoundByName:[NSString stringWithFormat:@"%@_%@%@.m4a", name, gender?MALE:FEMALE, [LocaleUtils isChinese]?LANGUAGE_CHINESE:LANGUAGE_ENGLISH]];
}

@end
