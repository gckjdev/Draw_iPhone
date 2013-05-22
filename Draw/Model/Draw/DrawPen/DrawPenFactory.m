//
//  DrawPenFactory.m
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import "DrawPenFactory.h"
#import "DashPen.h"
#import "MarkPen.h"
#import "BlurPen.h"
#import "DefaultPen.h"

static DefaultPen* globalDefaultPen;

@implementation DrawPenFactory

+ (id<DrawPenProtocol>)createDrawPen:(DrawPenType)type
{
    static dispatch_once_t onceTokenDrawPen;
    dispatch_once(&onceTokenDrawPen, ^{
        globalDefaultPen = [[DefaultPen alloc] init];
    });

    return globalDefaultPen;

    /*
    switch (type) {
        case DrawPenTypeBlur:
            return [[[BlurPen alloc] init] autorelease];
        
        case DrawPenTypeDash:
            return [[[DashPen alloc] init] autorelease];

        case DrawPenTypeMark:
            return [[[MarkPen alloc] init] autorelease];
            
        default:
            return [[[DefaultPen alloc] init] autorelease];
    }
     */
}

@end
