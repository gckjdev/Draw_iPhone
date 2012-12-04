//
//  ZJHRuleConfig.h
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//

#import <Foundation/Foundation.h>
#import "ZJHGameService.h"
#import "PokerView.h"

#define TWO_BUTTONS_HOLDER_VIEW_WIDTH ([DeviceDetection isIPAD] ? 214 : 107)
#define TWO_BUTTONS_HOLDER_VIEW_HEIGHT ([DeviceDetection isIPAD] ? 94 : 47)

#define BUTTON_WIDTH ([DeviceDetection isIPAD] ? 75 : 37)
#define BUTTON_HEIGHT ([DeviceDetection isIPAD] ? 39 : 19)

#define SHOW_CARD_BUTTON_TAG 200
#define CHANGE_CARD_BUTTON_TAG 201

#define SHOW_CARD_BUTTON_X_OFFSET ([DeviceDetection isIPAD] ? 20 : 10)
#define SHOW_CARD_BUTTON_Y_OFFSET ([DeviceDetection isIPAD] ? 20 : 10)

#define CHANGE_CARD_BUTTON_X_OFFSET ([DeviceDetection isIPAD] ? 120 : 60)
#define CHANGE_CARD_BUTTON_Y_OFFSET ([DeviceDetection isIPAD] ? 20 : 10)

#define BUTTON_FONT ([DeviceDetection isIPAD] ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:12])

@protocol ZJHRuleProtocol <NSObject>

@required
- (NSArray *)chipValues;
- (NSString *)getServerListString;
- (UIView *)createButtons:(PokerView *)pokerView;

@end

@interface ZJHRuleConfig : NSObject 

@end
