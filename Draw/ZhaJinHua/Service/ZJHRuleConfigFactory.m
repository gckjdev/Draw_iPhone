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

+ (ZJHRuleConfig *)createRuleConfigWithRule:(ZJHRule)rule
{
    switch (rule) {
        case ZJHRuleBeginer:
            return [[[ZJHBeginnerRuleConfig alloc] init] autorelease];
            break;
            
        default:
            break;
    }
}

@end
