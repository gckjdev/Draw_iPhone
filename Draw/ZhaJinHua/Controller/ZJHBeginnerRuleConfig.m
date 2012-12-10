//
//  ZJHBeginnerRuleConfig.m
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//

#import "ZJHBeginnerRuleConfig.h"
#import "ZJHImageManager.h"
#import "ZJHGameController.h"


@implementation ZJHBeginnerRuleConfig

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

@end
