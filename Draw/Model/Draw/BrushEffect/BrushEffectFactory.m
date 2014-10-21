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
    switch (brushType) {
        case ItemTypeBrushGouache:
            return [GouacheBrush sharedBrush];

        case ItemTypeBrushBlur:
            return [BlurBrush sharedBrush];
            
        case ItemTypeBrushCrayon:
            return [CrayonBrush sharedBrush];
            
        case ItemTypeBrushPen:
            return [PenCalligraphyBrush sharedBrush];
            
        case ItemTypeBrushPencil:
            return [PencilBrush sharedBrush];
            
        case ItemTypeBrushWater:
            return [WaterBrush sharedBrush];
            
        case ItemTypeBrushFeather:
            return [FeatherBrush sharedBrush];
            
        case ItemTypeBrushFilledCalligraphy:
            return [FilledCalligraphyBrush sharedBrush];
            
        case ItemTypeBrushDryCalligraphy:
            return [DryCalligraphyBrush sharedBrush];
        


            break;
            
        default:
            break;
    }
    
    return nil;
}

@end
