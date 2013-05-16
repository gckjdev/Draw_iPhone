//
//  LittleGeeDrawApp.m
//  Draw
//
//  Created by Kira on 13-5-7.
//
//

#import "LittleGeeDrawApp.h"
#import "LittleGeeHomeController.h"

@implementation LittleGeeDrawApp

- (PPViewController*)homeController
{
    return [[[LittleGeeHomeController alloc] init] autorelease];
}

- (NSString*)appId
{
    return LITTLE_GEE_APP_ID;
}

- (NSString*)gameId
{
    return LITTLE_GEE_GAME_ID;
}


- (BOOL)disableAd
{
    return YES;
}


- (NSString*)umengId
{
    return LITTLE_GEE_UMENG_ID;
}

- (NSString*)sinaAppKey
{
    //    return @"2831348933";
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_SINA_APP_KEY" defaultValue:@"138708649"];
}

- (NSString*)sinaAppSecret
{
    //    return @"ff89c2f5667b0199ee7a8bad6c44b265";
    //    return @"7a88336d7290279aef4112fda83708fd";
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_SINA_APP_SECRET" defaultValue:@"10aa2c8c0f9ce7c02d6f8f782029afee"];
}

- (NSString*)sinaAppRedirectURI
{
    //    return @"http://www.drawlively.com/draw";
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_SINA_APP_REDIRECT_URI" defaultValue:@"http://www.drawlively.com/draw"];
}

- (NSString*)qqAppKey
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_QQ_APP_KEY" defaultValue:@"801357429"];
    //    return @"801123669";
}

- (NSString*)qqAppSecret
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_QQ_APP_SECRET" defaultValue:@"143204e7e6b048a046ac418436a7a4e5"];
    //    return @"30169d80923b984109ee24ade9914a5c";
}

- (NSString*)qqAppRedirectURI
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_QQ_REDIRECT_URI" defaultValue:@"http://caicaihuahua.me"];
    //    return @"http://caicaihuahua.me";
}

- (NSString*)facebookAppKey
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_FACEBOOK_APP_SECRET" defaultValue:@"507044062701075"];
    //    return @"352182988165711";
}

- (NSString*)facebookAppSecret
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_FACEBOOK_APP_SECRET" defaultValue:@"9126fc25a537461eab1738b7cbfa3afd"];
    //    return @"51c65d7fbef9858a5d8bc60014d33ce2";
}

@end
