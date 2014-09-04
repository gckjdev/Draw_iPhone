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
#import "PenBrush.h"


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
            return [PenBrush sharedBrush];
            
            
        default:
            break;
    }
    
    return nil;
}

@end
