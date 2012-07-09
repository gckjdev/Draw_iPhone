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

- (id)initWithPenType:(PenType)type
{
    self = [super initWithFrame:VIEW_FRAME];
    if (self) {
        self.penType = type;
    }
    return self;
}

+ (PenView *)penViewWithType:(PenType)type
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
    if (self.penType == Pen || self.penType == Pencil || self.penType == WaterPen || self.penType == Eraser) {
        return YES;
    }
    return NO;
}
- (BOOL)isDefaultPen
{
    return self.penType == Pencil;
}
- (UIImage *)penImageForType:(PenType)type
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



- (void) setPenType:(PenType)penType
{
    if (penType < PenStartType || (penType >= PenCount && penType != Eraser)) {
        _penType = Pencil;
    }else{
        _penType = penType;
    }
    UIImage *image = [self penImageForType:penType];
    [self setBackgroundImage:image forState:UIControlStateNormal];

    NSLog(@"pentype: type = %d.",penType);        
    
    BOOL hasBought = penType == Pencil || [[AccountService defaultService] hasEnoughItemAmount:penType amount:1];
    if (!hasBought) {
        NSLog(@"type = %d, not bought.",penType);        
        [self setAlpha:0.3];
    }
    
}
@end
