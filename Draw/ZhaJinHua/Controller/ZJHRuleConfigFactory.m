//
//  ZJHRuleConfigFactory.m
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//

#import "ZJHRuleConfigFactory.h"
#import "ZJHNormalRuleConfig.h"
#import "ZJHDualRuleConfig.h"
#import "ZJHRichRuleConfig.h"

@implementation ZJHRuleConfigFactory

+ (ZJHRuleConfig *)createRuleConfig
{
    switch ([[ZJHGameService defaultService] rule]) {
        case PBZJHRuleTypeNormal:
            return [[[ZJHNormalRuleConfig alloc] init] autorelease];
            break;
            
        case PBZJHRuleTypeDual:
            return [[[ZJHDualRuleConfig alloc] init] autorelease];
            break;
            
        case PBZJHRuleTypeRich:
            return [[[ZJHRichRuleConfig alloc] init] autorelease];
            break;
            
        default:
            break;
    }
    
    return nil;
}

@end
