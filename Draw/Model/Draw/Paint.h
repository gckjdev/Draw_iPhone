//
//  Paint.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PenView.h"
#import "ItemType.h"
#import "PenEffectProtocol.h"

@class HPointList;

#define BACK_GROUND_WIDTH 3000

@class DrawColor;
@class GameMessage;
@class PointNode;
@class PBDrawActionBuilder;

@protocol DrawPenProtocol;


@interface Paint : NSObject //<NSCoding>
{
    CGFloat _width;
    DrawColor *_color;
    ItemType _penType;
    
    id<PenEffectProtocol> _pen;
    
}

@property(nonatomic, assign)CGRect canvasRect;
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)ItemType penType;
@property(nonatomic, retain)DrawColor* color;
//@property(nonatomic, retain)NSMutableArray *pointNodeList;
@property(nonatomic,retain)id<PenEffectProtocol> pen;
@property(nonatomic, retain)id<DrawPenProtocol> drawPen;

- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
            penType:(ItemType)penType
          pointList:(HPointList*)pointList;
//          pointList:(NSMutableArray *)pointNodeList;

+ (id)paintWithWidth:(CGFloat)width
               color:(DrawColor *)color
             penType:(ItemType)penType
           pointList:(HPointList*)pointList;
//           pointList:(NSMutableArray *)pointNodeList;


- (id)initWithGameMessage:(GameMessage *)gameMessage;

#pragma mark- get && add point methods
- (void)updateLastPoint:(CGPoint)point inRect:(CGRect)rect;
- (void)addPoint:(CGPoint)point inRect:(CGRect)rect;
- (void)finishAddPoint;
- (CGPoint)pointAtIndex:(NSInteger)index;
- (NSInteger)pointCount;

#pragma mark- path && draw methods
- (CGPathRef)path;
- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect;

- (CGRect)redrawRectInRect:(CGRect)rect;

- (void)updatePBDrawActionBuilder:(PBDrawActionBuilder *)builder;
- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC;

@end
