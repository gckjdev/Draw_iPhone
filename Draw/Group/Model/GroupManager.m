//
//  GroupManager.m
//  Draw
//
//  Created by Gamy on 13-11-9.
//
//

#import "GroupManager.h"

@implementation GroupManager

+ (NSInteger)capacityForLevel:(NSInteger)level
{
    return level * 10;
}
+ (NSInteger)monthlyFeeForLevel:(NSInteger)level
{
    level * 100;
}

@end
