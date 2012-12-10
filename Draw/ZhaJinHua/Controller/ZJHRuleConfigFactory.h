//
//  ZJHRuleConfigFactory.h
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//



#import <Foundation/Foundation.h>
#import "ZJHruleConfig.h"
#import "ZhaJinHua.pb.h"

@interface ZJHRuleConfigFactory : NSObject

+ (ZJHRuleConfig *)createRuleConfig;

@end
