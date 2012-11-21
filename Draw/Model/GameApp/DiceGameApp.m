//
//  DiceGameApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceGameApp.h"
#import "MobClickUtils.h"

@implementation DiceGameApp

- (NSString*)appId
{
    return DICE_APP_ID;
}

- (NSString*)gameId
{
    return DICE_GAME_ID;    
}

- (NSString*)umengId
{
    return DICE_UMENG_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)background
{
    return DICE_BACKGROUND;
}

- (NSString*)lmwallId
{
    return DICE_LM_WALL_ID;
}

- (NSString*)lmAdPublisherId
{
    return DICE_LM_AD_ID;
}

- (NSString*)aderAdPublisherId
{
    return DICE_ADER_AD_ID;
}

- (NSString*)mangoAdPublisherId
{
    return DICE_MANGO_AD_ID;
}

- (NSString*)defaultBroadImage
{
    return @"dice_default_board.jpg";
}

- (NSString *)defaultAdBoardImage
{
    return @"dice_default_board_ad.jpg";
}

- (NSString*)sinaAppKey
{
//    return @"562852192";
    return @"3163067274";
}

- (NSString*)sinaAppSecret
{
//    return @"6271c4259ae38213ddf6f8b1b6ba7766";
    return @"d677917b0c2855d36674c1d0339326bd";
}

- (NSString*)sinaAppRedirectURI
{
    return @"http://www.drawlively.com";
}


- (NSString*)qqAppKey
{
    return @"801229596";    
}

- (NSString*)qqAppSecret
{
    return @"967bcfd366aa27e542f00db52ef5981d";    
}

- (NSString*)qqAppRedirectURI
{
    return @"http://www.drawlively.com/dice/";
}

- (NSString*)facebookAppKey
{
    return @"451387761588871";    
}

- (NSString*)facebookAppSecret
{
    return @"46326b19b15b3d3ab095035079a92b92";
}

- (NSString*)wanpuAdPublisherId
{
    return @"56355897c0bb3c956585f2e7ab2950af";
}

- (NSString*)removeAdProductId
{
    return [MobClickUtils getStringValueByKey:@"AD_IAP_ID" defaultValue:@"com.orange.dice.removead"];    
}

- (NSString*)askFollowTitle
{
    return @"关注官方微博";    
}

- (NSString*)askFollowMessage
{
    return @"关注和收听欢乐大话骰官方微博，第一时间可以接收最新的消息";
}

- (NSString*)sinaWeiboId
{
    return @"欢乐大话骰";
}

- (NSString*)qqWeiboId
{
    return @"liardice";
}


@end
