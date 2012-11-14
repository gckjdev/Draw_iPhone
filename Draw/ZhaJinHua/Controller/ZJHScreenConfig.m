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
#define LEFT_MESSAGE_VIEW_POSITION CGPointMake(64, 231)
#define RIGHT_MESSAGE_VIEW_POSITION CGPointMake(221, 231)

#define LEFT_TOP_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(64, 144)
#define RIGHT_TOP_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(221, 144)
#define LEFT_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(64, 281)
#define RIGHT_MESSAGE_VIEW_POSITION_IPHONE5 CGPointMake(221, 281)

#define LEFT_TOP_MESSAGE_VIEW_POSITION_IPAD CGPointMake(64, 182)
#define RIGHT_TOP_MESSAGE_VIEW_POSITION_IPAD CGPointMake(221, 182)
#define LEFT_MESSAGE_VIEW_POSITION_IPAD CGPointMake(64, 318)
#define RIGHT_MESSAGE_VIEW_POSITION_IPAD CGPointMake(221, 318)

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

@end
