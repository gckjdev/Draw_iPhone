//
//  BrushStroke.h
//  Draw
//
//  Created by 黄毅超 on 14-9-1.
//
//

#import <Foundation/Foundation.h>
#import "PenView.h"
#import "ItemType.h"
#import "PenEffectProtocol.h"

@class HBrushPointList;

#define BACK_GROUND_WIDTH 3000

@class DrawColor;
@class GameMessage;
@class PointNode;
@class PBDrawAction_Builder;
@protocol DrawPenProtocol;


@interface BrushStroke : NSObject
{
}

@property(nonatomic, assign)CGRect canvasRect;
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)ItemType brushType;
@property(nonatomic, assign)CGLayerRef brushLayer;
@property(nonatomic, retain)DrawColor* color;
@property(nonatomic,retain)id<PenEffectProtocol> pen;
@property(nonatomic, retain)id<DrawPenProtocol> drawPen;
@property(nonatomic, retain) UIImage *brushImage;
@property(nonatomic, assign) CGImageRef brushImageRef;

- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
            brushType:(ItemType)brushType
          pointList:(HBrushPointList*)pointList;

+ (id)brushStrokeWithWidth:(CGFloat)width
               color:(DrawColor *)color
             brushType:(ItemType)brushType
           pointList:(HBrushPointList*)pointList;

- (id)initWithGameMessage:(GameMessage *)gameMessage;

#pragma mark- get && add point methods
- (void)updateLastPoint:(CGPoint)point inRect:(CGRect)rect;
- (void)addPoint:(CGPoint)point inRect:(CGRect)rect;
- (void)finishAddPoint;
- (CGPoint)pointAtIndex:(NSInteger)index;
- (NSInteger)pointCount;

#pragma mark- path && draw methods
//- (CGPathRef)path;
- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect;

- (CGRect)redrawRectInRect:(CGRect)rect;

- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder;
- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC;

- (void)clearMemory;

@end
