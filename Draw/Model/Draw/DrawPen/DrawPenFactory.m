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

@implementation DrawPenFactory

+ (id<DrawPenProtocol>)createDrawPen:(DrawPenType)type
{
    //return default pen
    PPDebug(@"<createDrawPen> type = %d", type);
    return [[[DefaultPen alloc] init] autorelease];
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
}

@end
