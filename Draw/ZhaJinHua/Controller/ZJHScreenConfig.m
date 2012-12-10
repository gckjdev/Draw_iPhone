//
//  ZJHScreenConfig.m
//  Draw
//
//  Created by 王 小涛 on 12-11-14.
//
//

#import "ZJHScreenConfig.h"

#define LEFT_TOP_MESSAGE_VIEW_POSITION CGPointMake(64, 106)
#define RIGHT_TOP_MESSAGE_VIEW_POSITION CGPointMake(221, 106)
#define LEFT_MESSAGE_VIEW_POSITION CGPointMake(64, 230)
#define RIGHT_MESSAGE_VIEW_POSITION CGPointMake(221, 230)
#define CENTER_UP_MESSAGE_VIEW_POSITION CGPointMake(214, 130)


#define LEFT_TOP_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(64, 144)
#define RIGHT_TOP_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(221, 144)
#define LEFT_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(64, 281)
#define RIGHT_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(221, 281)
#define CENTER_UP_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(214, 145)

#define LEFT_TOP_MESSAGE_VIEW_POSITION_IPAD CGPointMake(174, 260)
#define RIGHT_TOP_MESSAGE_VIEW_POSITION_IPAD CGPointMake(523, 260)
#define LEFT_MESSAGE_VIEW_POSITION_IPAD CGPointMake(174, 508)
#define RIGHT_MESSAGE_VIEW_POSITION_IPAD CGPointMake(523, 508)
#define CENTER_UP_MESSAGE_VIEW_POSITION_IPAD CGPointMake(214, 145)

@implementation ZJHScreenConfig


+ (CGPoint)getMessageViewOriginByPosition:(UserPosition)position
{
    switch (position) {
        case UserPositionLeftTop:
            return [ZJHScreenConfig getLeftTopMessageViewOrigin];
            break;
            
        case UserPositionLeft:
            return [ZJHScreenConfig getLeftMessageViewOrigin];
            break;
            
        case UserPositionRightTop:
            return [ZJHScreenConfig getRightTopMessageViewOrigin];
            break;
            
        case UserPositionRight:
            return [ZJHScreenConfig getRightMessageViewOrigin];
            break;
            
        case UserPositionCenterUp:
            return [ZJHScreenConfig getCenterUpMessageViewOrigin];
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getLeftTopMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return LEFT_TOP_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return LEFT_TOP_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return LEFT_TOP_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getLeftMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return LEFT_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return LEFT_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return LEFT_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}


+ (CGPoint)getRightTopMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return RIGHT_TOP_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return RIGHT_TOP_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return RIGHT_TOP_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}


+ (CGPoint)getRightMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return RIGHT_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return RIGHT_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return RIGHT_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

+ (CGPoint)getCenterUpMessageViewOrigin
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return CENTER_UP_MESSAGE_VIEW_POSITION_IPAD;
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return CENTER_UP_MESSAGE_VIEW_POSITION_IPHONE5;
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return CENTER_UP_MESSAGE_VIEW_POSITION;
            break;
            
        default:
            return CGPointMake(0, 0);
            break;
    }
}

@end
