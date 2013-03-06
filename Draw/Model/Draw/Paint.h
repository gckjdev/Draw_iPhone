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

#define BACK_GROUND_WIDTH 3000

@class DrawColor;
@class GameMessage;
@class PointNode;

//CGPoint midPoint(CGPoint p1, CGPoint p2);

//#define POINT_COUNT        3
//#define POINT_COUNT        5

@interface Paint : NSObject <NSCoding>
{
    CGFloat _width;
    DrawColor *_color;
//    NSMutableArray *_pointList;
    ItemType _penType;
    
    id<PenEffectProtocol> _pen;
    
    // to be removed
//    CGMutablePathRef _path;
//    CGMutablePathRef _pathToShow;
//    CGPoint pts[10];
//    int     ptsCount;
//    BOOL    ptsComplete;
}
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)ItemType penType;
@property(nonatomic, retain)DrawColor* color;
//@property(nonatomic,retain)NSMutableArray *pointList;
@property(nonatomic, retain)NSMutableArray *pointNodeList;

@property(nonatomic,retain)id<PenEffectProtocol> pen;


- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
            penType:(ItemType)penType
          pointList:(NSMutableArray *)pointNodeList;

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color;
- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList;

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color penType:(ItemType)type;
- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList penType:(ItemType)type;


- (id)initWithGameMessage:(GameMessage *)gameMessage;

- (void)addPoint:(CGPoint)point;
- (void)finishAddPoint;

- (CGPoint)pointAtIndex:(NSInteger)index;
- (NSInteger)pointCount;

- (CGPathRef)path;

+ (Paint *)paintWithWidth:(CGFloat)width color:(DrawColor*)color;
+ (Paint *)paintWithWidth:(CGFloat)width color:(DrawColor*)color penType:(ItemType)type;

//- (CGMutablePathRef)getPath;
//- (CGMutablePathRef)getPathForShow;
//- (CGRect)rectForPath;

//- (void)clearPath;
//- (void)releasePathToShow;
- (NSMutableArray *)createNumberPointList:(BOOL)isCompressed pointXList:(NSArray**)pointXList pointYList:(NSArray**)pointYList;



@end
