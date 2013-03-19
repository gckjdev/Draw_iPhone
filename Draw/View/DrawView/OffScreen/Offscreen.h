//
//  Offscreen.h
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import <Foundation/Foundation.h>
#import "DrawPenFactory.h"

@class DrawColor;
@class DrawAction;
@class Paint;
@class ShapeInfo;

@interface Offscreen : NSObject

@property(nonatomic, assign, readonly)NSUInteger actionCount;
@property(nonatomic, assign, readonly)NSUInteger capacity;
@property(nonatomic, assign, readonly)CGRect rect; //default is DRAW_VIEW_RECT
@property(nonatomic, assign, readonly)BOOL hasImage;
@property(nonatomic, retain)id<DrawPenProtocol> drawPen;


- (id)initWithCapacity:(NSUInteger)capacity; //default is 50, 0 for no limit
- (id)initWithCapacity:(NSUInteger)capacity rect:(CGRect)rect; //default is 50, 0 for no limit

- (CGLayerRef)cacheLayer;
- (CGContextRef)cacheContext;

+ (id)offscreenWithCapacity:(NSUInteger)capacity;
+ (id)unlimitOffscreen;



- (void)updateContextWithCGLayer:(CGLayerRef)layer
                    actionCount:(NSInteger)actionCount;
- (void)addContextWithCGLayer:(CGLayerRef)layer
                   actionCount:(NSInteger)actionCount;

//- (CGRect)strokePaint:(Paint *)paint clear:(BOOL)clear;
//- (CGRect)drawShape:(ShapeInfo *)shape clear:(BOOL)clear;
//- (void)setStrokeColor:(DrawColor *)color lineWidth:(CGFloat)width;

- (CGRect)drawAction:(DrawAction *)action clear:(BOOL)clear;
- (void)clear;
- (void)showInContext:(CGContextRef)context;
- (BOOL)isFull;
- (BOOL)noLimit;
- (BOOL)hasContentToShow;

- (void)showImage:(UIImage *)image;


@end
