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
#import "ZJHImageManager.h"
#import "ZJHUserPosInfo.h"
#import "ZJHGameController.h"

@class ZJHGameController;

#define TWO_BUTTONS_HOLDER_VIEW_WIDTH ([DeviceDetection isIPAD] ? 214 : 107)
#define TWO_BUTTONS_HOLDER_VIEW_HEIGHT ([DeviceDetection isIPAD] ? 94 : 47)

#define ONE_BUTTON_HOLDER_VIEW_WIDTH ([DeviceDetection isIPAD] ? 214 : 107)
#define ONE_BUTTON_HOLDER_VIEW_HEIGHT ([DeviceDetection isIPAD] ? 94 : 47)

#define BUTTON_WIDTH ([DeviceDetection isIPAD] ? 75 : 37)
#define BUTTON_HEIGHT ([DeviceDetection isIPAD] ? 39 : 19)

//#define SHOW_CARD_BUTTON_TAG 200
//#define CHANGE_CARD_BUTTON_TAG 201

#define SHOW_CARD_BUTTON_X_OFFSET ([DeviceDetection isIPAD] ? 20 : 10)
#define SHOW_CARD_BUTTON_Y_OFFSET ([DeviceDetection isIPAD] ? 20 : 10)

#define CHANGE_CARD_BUTTON_X_OFFSET ([DeviceDetection isIPAD] ? 120 : 60)
#define CHANGE_CARD_BUTTON_Y_OFFSET ([DeviceDetection isIPAD] ? 20 : 10)




#define TEXT_COLOR_ENABLED [UIColor colorWithRed:199.0/255.0 green:252.0/255.0 blue:254.0/255.0 alpha:1]
#define TEXT_COLOR_DISENABLED [UIColor colorWithRed:68.0/255.0 green:109.0/255.0 blue:110.0/255.0 alpha:1]

@interface ZJHRuleConfig : NSObject

// methods may be need to be replaced in sub class.
- (NSString *)getRoomName;
- (NSString *)getRoomListTitle;
- (BOOL)isCoinsEnough;
- (int)coinsNeedToJoinGame;
- (NSArray *)chipValues;
- (int)maxPlayerNum;
- (UIImage *)gameBgImage;
- (NSDictionary *)initAllAvatar:(ZJHGameController *)controller;
- (UserPosition)positionBySeatIndex:(int)index;

- (UIView *)createButtons:(PokerView *)pokerView;
- (ZJHMyAvatarView *)bigAvatarWithFrame:(CGRect)frame;
- (ZJHAvatarView *)avatarWithFrame:(CGRect)frame;

- (void)getAccount:(NSArray *)userList;
- (int)maxTotal;

@end
