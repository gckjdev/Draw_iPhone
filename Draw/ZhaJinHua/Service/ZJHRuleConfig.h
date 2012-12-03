//
//  ZJHRuleConfig.h
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    ZJHRuleBeginer = 0,
    ZJHRuleNormal = 1,
    ZJHRuleRich = 2,
    ZJHRulePair = 3
}ZJHRule;

@protocol ZJHRuleProtocol <NSObject>

@required
- (NSArray *)chipValues;
- (NSString *)getServerListString;

@end

@interface ZJHRuleConfig : NSObject 

@end
