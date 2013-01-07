//
//  PenView.m
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PenView.h"
#import "ShareImageManager.h"
#import "DeviceDetection.h"
#import "AccountService.h"
#import <QuartzCore/QuartzCore.h>
#define VIEW_HEIGHT [DeviceDetection isIPAD] ? 70 : 35
#define VIEW_WDITH [DeviceDetection isIPAD] ? 40 : 20

#define VIEW_FRAME CGRectMake(0,0,VIEW_WDITH,VIEW_HEIGHT)



@implementation PenView
@synthesize penType = _penType;
@synthesize price = _price;
- (void)dealloc
{
    [super dealloc];
}

- (id)initWithPenType:(ItemType)type
{
    self = [super initWithFrame:VIEW_FRAME];
    if (self) {
        self.penType = type;
    }
    return self;
}

+ (PenView *)penViewWithType:(ItemType)type
{
    return [[[PenView alloc] initWithPenType:type]autorelease];
}

+ (CGFloat)height
{
    return VIEW_HEIGHT;
}
+ (CGFloat)width
{
    return VIEW_WDITH;
}

- (BOOL)isRightDownRotate
{
    if (self.penType == Pencil || self.penType == WaterPen || self.penType == Eraser) {
        return NO;
    }
    return YES;
}
- (BOOL)isDefaultPen
{
    return self.penType == Pencil;
}
- (UIImage *)penImageForType:(ItemType)type
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    switch (type) {
        case Pen:
            return [imageManager penImage];            
        case Quill:
            return [imageManager quillImage];            
        case WaterPen:
            return [imageManager waterPenImage];            
        case IcePen:
            return [imageManager iceImage];            
        case Eraser:
            return [imageManager eraserImage];            
        case Pencil:
            default:
            return [imageManager pencilImage];            
    }
    
}



- (void) setPenType:(ItemType)penType
{
    if (penType < PenStartType || (penType >= PenCount && penType != Eraser)) {
        _penType = Pencil;
    }else{
        _penType = penType;
    }
    UIImage *image = [self penImageForType:penType];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    
    BOOL hasBought = _penType == Pencil || [[AccountService defaultService] hasEnoughItemAmount:_penType amount:1];
    if (!hasBought) {
        [self setAlpha:1.0];
    }
    
}


#define LAST_PEN_TYPE @"LastPenTypeKey"
+ (ItemType)lastPenType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger type = [userDefaults integerForKey:LAST_PEN_TYPE];
    if (type < PenStartType || type >= PenCount) {
        return Pencil;
    }
    return type;
}
+ (void)savePenType:(ItemType)type
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:type forKey:LAST_PEN_TYPE];
    [userDefaults synchronize];
}

@end
