//
//  DreamAvatarApp.m
//  Draw
//
//  Created by haodong on 13-5-3.
//
//

#import "DreamAvatarApp.h"
#import "LearnDrawManager.h"

@implementation DreamAvatarApp

- (NSString*)appId
{
    return DREAM_AVATAR_APP_ID;
}

- (NSString*)gameId
{
    return DREAM_AVATAR_GAME_ID;
}

- (BOOL)disableAd
{
    return YES;
}

- (NSString*)umengId
{
    return DREAM_AVATAR_UMENG_ID;
}

- (BOOL)hasBGOffscreen{
    return YES;
}

//ContentGameAppProtocol
- (int)sellContentType
{
    return SellContentTypeDreamAvatar;
}

- (NSArray *)homeTabIDList
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:LearnDrawTypeAll],
            [NSNumber numberWithInt:LearnDrawTypeCartoon],
            [NSNumber numberWithInt:LearnDrawTypeCharater],
            [NSNumber numberWithInt:LearnDrawTypeAnimal],
            [NSNumber numberWithInt:LearnDrawTypeOther],nil];
}

- (NSArray *)homeTabTitleList
{
    return [NSArray arrayWithObjects:NSLS(@"kLearnDrawAll"),
            NSLS(@"kLearnDrawCartoon"),
            NSLS(@"kLearnDrawCharater"),
            NSLS(@"kLearnDrawAnimal"),
            NSLS(@"kLearnDrawOther"), nil];
}

@end
