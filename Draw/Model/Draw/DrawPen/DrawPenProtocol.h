//
//  DrawPenProtocol.h
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "Paint.h"
#import "SuperPen.h"

typedef enum{
    DrawPenTypeDefault = 1000,
    DrawPenTypeMark,
    DrawPenTypeDash,
    DrawPenTypeBlur,
}DrawPenType;


@protocol DrawPenProtocol <NSObject>

@required
- (void)updateCGContext:(CGContextRef)context paint:(Paint *)paint;
- (DrawPenType)penType;

@optional
- (UIImage *)penImage;
- (NSString *)name;
- (NSString *)desc;


@end

