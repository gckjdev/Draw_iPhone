//
//  ZJHNormalRuleConfig.m
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//

#import "ZJHNormalRuleConfig.h"
#import "ZJHImageManager.h"
#import "ZJHGameController.h"


@implementation ZJHNormalRuleConfig

- (NSString *)getRoomListTitle
{
    return NSLS(@"kHomeMenuTypeZJHNormalSite");
}

- (NSArray *)chipValues
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:10], [NSNumber numberWithInt:25], [NSNumber numberWithInt:50], nil];
}

- (int)maxPlayerNum
{
    return 5;
}

- (UIImage *)gameBgImage
{
    return [[ZJHImageManager defaultManager] gameBgImage];
}

- (int)maxTotal
{
    return [ConfigManager maxTotalBetWithNormalRule];
}

@end
