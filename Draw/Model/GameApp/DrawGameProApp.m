//
//  DrawGameProApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameProApp.h"
#import "MobClickUtils.h"

@implementation DrawGameProApp

- (NSString*)appId
{
    return DRAW_PRO_APP_ID;
}

- (BOOL)disableAd
{
    return YES;
}

- (NSString*)removeAdProductId
{
    return [MobClickUtils getStringValueByKey:@"AD_IAP_ID" defaultValue:@"com.orange.drawpro.removead"];
}

- (NSString *)alipayCallBackScheme
{
    return @"alipaycchhpro.gckj";
}

- (BOOL)hasAllColorGroups
{
    return NO;
}

- (UIColor *)homeMenuColor
{
    return [UIColor colorWithRed:61.0/255.0 green:43.0/255.0 blue:23.0/255.0 alpha:1];
}

@end
