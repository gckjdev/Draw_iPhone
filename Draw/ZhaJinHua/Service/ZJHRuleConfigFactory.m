//
//  ZJHRuleConfigFactory.m
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//

#import "ZJHRuleConfigFactory.h"
#import "ZJHBeginnerRuleConfig.h"

@implementation ZJHRuleConfigFactory

+ (ZJHRuleConfig *)createRuleConfig
{
    switch ([[ZJHGameService defaultService] rule]) {
        case PBZJHRuleTypeBeginer:
            return [[[ZJHBeginnerRuleConfig alloc] init] autorelease];
            break;
            
        default:
            break;
    }
    
    return nil;
}

@end
