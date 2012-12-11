//
//  ZJHScreenConfig.m
//  Draw
//
//  Created by 王 小涛 on 12-11-14.
//
//

#import "ZJHScreenConfig.h"

#define LEFT_TOP_ACTION_MESSAGE_VIEW_POSITION CGPointMake(64, 106)
#define RIGHT_TOP_ACTION_MESSAGE_VIEW_POSITION CGPointMake(221, 106)
#define LEFT_ACTION_MESSAGE_VIEW_POSITION CGPointMake(64, 230)
#define RIGHT_ACTION_MESSAGE_VIEW_POSITION CGPointMake(221, 230)
#define CENTER_UP_ACTION_MESSAGE_VIEW_POSITION CGPointMake(214, 130)

#define CENTER_UP_CHAT_MESSAGE_VIEW_POSITION CGPointMake(106, 110)
#define CENTER_CHAT_MESSAGE_VIEW_POSITION CGPointMake(106, 355)
#define RIGHT_CHAT_MESSAGE_VIEW_POSITION CGPointMake(258, 230)
#define RIGHT_TOP_CHAT_MESSAGE_VIEW_POSITION CGPointMake(258, 106)



#define LEFT_TOP_ACTION_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(64, 144)
#define RIGHT_TOP_ACTION_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(221, 144)
#define LEFT_ACTION_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(64, 281)
#define RIGHT_ACTION_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(221, 281)
#define CENTER_UP_ACTION_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(214, 145)

#define CENTER_UP_CHAT_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(106, 122)
#define CENTER_CHAT_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(106, 430)
#define RIGHT_CHAT_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(258, 281)
#define RIGHT_TOP_CHAT_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(258, 144)



#define LEFT_TOP_ACTION_MESSAGE_VIEW_POSITION_IPAD CGPointMake(174, 266)
#define RIGHT_TOP_ACTION_MESSAGE_VIEW_POSITION_IPAD CGPointMake(523, 266)
#define LEFT_ACTION_MESSAGE_VIEW_POSITION_IPAD CGPointMake(174, 514)
#define RIGHT_ACTION_MESSAGE_VIEW_POSITION_IPAD CGPointMake(523, 514)
#define CENTER_UP_ACTION_MESSAGE_VIEW_POSITION_IPAD CGPointMake(500, 310)

#define CENTER_UP_CHAT_MESSAGE_VIEW_POSITION_IPAD CGPointMake(276, 270)
#define CENTER_CHAT_MESSAGE_VIEW_POSITION_IPAD CGPointMake(276, 780)
#define RIGHT_CHAT_MESSAGE_VIEW_POSITION_IPAD CGPointMake(600, 514)
#define RIGHT_TOP_CHAT_MESSAGE_VIEW_POSITION_IPAD CGPointMake(600, 266)


@implementation ZJHScreenConfig


+ (CGPoint)getActionMessageViewOriginByPosition:(UserPosition)position
{
    switch (position) {
        case UserPositionLeftTop:
            return [ZJHScreenConfig getLeftTopActionMessageViewOrigin];
            break;
            
        case UserPositionLeft:
            return [ZJHScreenConfig getLeftActionMessageViewOrigin];
            break;
            
        case UserPositionRightTop:
            return [ZJHScreenConfig getRightTopActionMessageViewOrigin];
            break;
            
        case UserPositionRight:
            return [ZJHScreenConfig getRightActionMessageViewOrigin];
            break;
            
        case UserPositionCenterUp:
            return [ZJHScreenConfig getCenterUpActionMessageViewOrigin];
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getLeftTopActionMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return LEFT_TOP_ACTION_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return LEFT_TOP_ACTION_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return LEFT_TOP_ACTION_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getLeftActionMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return LEFT_ACTION_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return LEFT_ACTION_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return LEFT_ACTION_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}


+ (CGPoint)getRightTopActionMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return RIGHT_TOP_ACTION_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return RIGHT_TOP_ACTION_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return RIGHT_TOP_ACTION_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}


+ (CGPoint)getRightActionMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return RIGHT_ACTION_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return RIGHT_ACTION_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return RIGHT_ACTION_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getCenterUpActionMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return CENTER_UP_ACTION_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return CENTER_UP_ACTION_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return CENTER_UP_ACTION_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getCenterUpChatMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return CENTER_UP_CHAT_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return CENTER_UP_CHAT_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return CENTER_UP_CHAT_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getCenterChatMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return CENTER_CHAT_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return CENTER_CHAT_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return CENTER_CHAT_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getRightTopChatMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return RIGHT_TOP_CHAT_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return RIGHT_TOP_CHAT_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return RIGHT_TOP_CHAT_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}


+ (CGPoint)getRightChatMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return RIGHT_CHAT_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return RIGHT_CHAT_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return RIGHT_CHAT_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getChatMessageViewOriginByPosition:(UserPosition)position
{
    switch (position) {
        case UserPositionLeftTop:
            return [ZJHScreenConfig getLeftTopActionMessageViewOrigin];
            break;
            
        case UserPositionLeft:
            return [ZJHScreenConfig getLeftActionMessageViewOrigin];
            break;
            
        case UserPositionRightTop:
            return [ZJHScreenConfig getRightTopChatMessageViewOrigin];
            break;
            
        case UserPositionRight:
            return [ZJHScreenConfig getRightChatMessageViewOrigin];
            break;
            
        case UserPositionCenterUp:
            return [ZJHScreenConfig getCenterUpChatMessageViewOrigin];
            break;
            
        case UserPositionCenter:
            return [ZJHScreenConfig getCenterChatMessageViewOrigin];
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}


@end
