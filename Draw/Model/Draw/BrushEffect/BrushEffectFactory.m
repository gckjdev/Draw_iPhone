//
//  BrushEffectFactory.m
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import "BrushEffectFactory.h"
#import "GouacheBrush.h"
#import "BlurBrush.h"
#import "CrayonBrush.h"
#import "PencilBrush.h"
#import "WaterBrush.h"
#import "FeatherBrush.h"
#import "FilledCalligraphyBrush.h"
#import "PenCalligraphyBrush.h"
#import "DryCalligraphyBrush.h"

#import "NewCrayonBrush.h"
#import "NewPencilBrush.h"
#import "NewWaterBrush.h"

static BrushEffectFactory* sharedBrushFactory;
static dispatch_once_t brushFactoryOnceToken;

@implementation BrushEffectFactory

+ (BrushEffectFactory*)sharedInstance
{
    if (sharedBrushFactory == nil){
        dispatch_once(&brushFactoryOnceToken, ^{
            sharedBrushFactory = [[BrushEffectFactory alloc] init];
        });
    }
    
    return sharedBrushFactory;
}

- (id<BrushEffectProtocol>)brush:(ItemType)brushType
{
    //2015 5 8 charlie
    //为了优化笔刷性能，做了一些优化。
    //为了兼容，其中的蜡笔，铅笔，水笔使用了新建的类，前缀为New
    
    switch (brushType) {
        case ItemTypeBrushGouache:
            return [GouacheBrush sharedBrush];

        case ItemTypeBrushBlur:
            return [BlurBrush sharedBrush];
            
        case ItemTypeBrushCrayon:
            return [NewCrayonBrush sharedBrush];
            
        case ItemTypeBrushPen:
            return [PenCalligraphyBrush sharedBrush];
            
        case ItemTypeBrushPencil:
            return [NewPencilBrush sharedBrush];
            
        case ItemTypeBrushWater:
            return [NewWaterBrush sharedBrush];
            
        case ItemTypeBrushFeather:
            return [FeatherBrush sharedBrush];

        case ItemTypeBrushFilledCalligraphy:
            return [FilledCalligraphyBrush sharedBrush];
            
        case ItemTypeBrushDryCalligraphy:
            return [DryCalligraphyBrush sharedBrush];
            
        default:
            break;
    }
    
    return nil;
}

@end
