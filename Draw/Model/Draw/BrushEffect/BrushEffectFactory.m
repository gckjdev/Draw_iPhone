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
            
        case ItemTypeBrushPen:
            return [PenCalligraphyBrush sharedBrush];
            
        case ItemTypeBrushFeather://deprecated
            return [FeatherBrush sharedBrush];

        case ItemTypeBrushFilledCalligraphy:
            return [FilledCalligraphyBrush sharedBrush];
            
        case ItemTypeBrushDryCalligraphy:
            return [DryCalligraphyBrush sharedBrush];
            
        //取代旧的算法，进行了性能优化。
        case ItemTypeBrushNewCrayon:
            return [NewCrayonBrush sharedBrush];
            
        case ItemTypeBrushNewWater:
            return [NewWaterBrush sharedBrush];
            
        case ItemTypeBrushNewPencil:
            return [NewPencilBrush sharedBrush];
            
        //已经使用新的算法代替，以下三种不再使用
        case ItemTypeBrushCrayon:
            return [CrayonBrush sharedBrush];
            
        case ItemTypeBrushWater:
            return [WaterBrush sharedBrush];
            
        case ItemTypeBrushPencil:
            return [PencilBrush sharedBrush];
            
        default:
            break;
    }
    
    return nil;
}

@end
