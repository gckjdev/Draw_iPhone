//
//  CallTrackApp.m
//  Draw
//
//  Created by haodong on 13-5-22.
//
//

#import "CallTrackApp.h"
#import "SecureSmsHomeController.h"


@implementation CallTrackApp

- (NSString*)appId
{
    return CALL_TRACK_APP_ID;
}

- (NSString*)gameId
{
    return CALL_TRACK_GAME_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)umengId
{
    return @"51aed32d56240b1b94001a1f";
}

- (BOOL)hasBGOffscreen{
    return YES;
}

- (BOOL)canSubmitDraw
{
    return YES;
}

- (PPViewController *)homeController
{
    return [[[SecureSmsHomeController alloc] initWithType:PureChatTypeCallTrack] autorelease];
}

- (NSString *)alipayCallBackScheme
{
    return @"alipaycalltrack.gckj";
}

- (NSString*)iapResourceFileName
{
    return [self gameId];
}

- (BOOL)showLocateButton
{
    return YES;
}

- (int)photoUsage
{
    return PBPhotoUsageForPs;
}
- (NSString*)keywordSmartDataCn
{
    return @"keywords.txt";
}
- (NSString*)keywordSmartDataEn
{
    return @"keywords_en.txt";
}
- (NSString*)photoTagsCn
{
    return @"photo_tags.txt";
}
- (NSString*)photoTagsEn
{
    return @"photo_tags_en.txt";
}

@end
