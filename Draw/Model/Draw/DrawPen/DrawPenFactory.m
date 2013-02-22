//
//  DrawPenFactory.m
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import "DrawPenFactory.h"

@implementation DrawPenFactory

+ (id<DrawPenProtocol>)createDrawPen:(DrawPenType)type
{
    switch (type) {
        case DrawPenTypeBlur:
            
            break;
        
        case DrawPenTypeDash:
            
            break;

        case DrawPenTypeMark:
            
            break;
            
        default:
            return nil;
    }
}

@end
