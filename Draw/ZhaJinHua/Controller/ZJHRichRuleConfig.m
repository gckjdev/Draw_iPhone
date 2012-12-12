//
//  ZJHNormalRuleConfig.m
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//

#import "ZJHRichRuleConfig.h"
#import "ZJHImageManager.h"
#import "ZJHGameController.h"


@implementation ZJHRichRuleConfig

- (NSArray *)chipValues
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:25], [NSNumber numberWithInt:50], [NSNumber numberWithInt:100], [NSNumber numberWithInt:250], nil];
}

- (int)maxPlayerNum
{
    return 5;
}

- (UIImage *)gameBgImage
{
    return [[ZJHImageManager defaultManager] gameBgImage];
}

@end
