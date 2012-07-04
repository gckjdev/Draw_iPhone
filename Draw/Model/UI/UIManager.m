//
//  UIManager.m
//  Draw
//
//  Created by Orange on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIManager.h"
#import "DeviceDetection.h"

@implementation UIManager
+ (UIFont*) roomTitleFont
{
    return [UIFont systemFontOfSize:15];
}
+ (UIColor*)cellTextColor
{
    return [UIColor colorWithRed:79/255.0 green:62/255.0 blue:32/255.0 alpha:1.0];
}

@end
