//
//  DreamAvatarApp.m
//  Draw
//
//  Created by haodong on 13-5-3.
//
//

#import "DreamAvatarApp.h"
#import "LearnDrawManager.h"
#import "IAPProductService.h"

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

- (NSString *)alipayCallBackScheme
{
    return @"alipaydreamavatar.gckj";
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

- (NSString*)domodWallId
{
    return @"96ZJ2j3gze+vLwTA1n";
}

- (NSString*)iapResourceFileName
{
    return [self gameId];
}

- (void)createIAPTestDataFile
{
    [IAPProductService createDreamAvatarIngotTestDataFile];
}
@end
