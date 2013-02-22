//
//  SuperPen.h
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "DrawPenProtocol.h"

@interface SuperPen : NSObject
{
    
}

- (void)updateCGContext:(CGContextRef)context paint:(Paint *)paint;

@end
