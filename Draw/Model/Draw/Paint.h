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
@class DrawColor;
@class GameMessage;

CGPoint midPoint(CGPoint p1, CGPoint p2);

#define POINT_COUNT        5

@interface Paint : NSObject <NSCoding>
{
    CGFloat _width;
    DrawColor *_color;
    NSMutableArray *_pointList;
    ItemType _penType;
    CGMutablePathRef _path;
    CGMutablePathRef _pathToShow;
    CGPoint pts[POINT_COUNT];
    int     ptsCount;
    BOOL    ptsComplete;
}
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)ItemType penType;
@property(nonatomic,retain)DrawColor* color;
@property(nonatomic,retain)NSMutableArray *pointList;


- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
            penType:(ItemType)penType
          pointList:(NSMutableArray *)pointList;

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color;
- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList;

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color penType:(ItemType)type;
- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList penType:(ItemType)type;


- (id)initWithGameMessage:(GameMessage *)gameMessage;

- (void)addPoint:(CGPoint)point;
- (CGPoint)pointAtIndex:(NSInteger)index;
- (NSInteger)pointCount;
- (NSString *)toString;
- (CGPathRef)path;

+ (Paint *)paintWithWidth:(CGFloat)width color:(DrawColor*)color;
+ (Paint *)paintWithWidth:(CGFloat)width color:(DrawColor*)color penType:(ItemType)type;

- (CGMutablePathRef)getPath;
- (CGMutablePathRef)getPathForShow;
- (CGRect)rectForPath;

- (void)releasePathToShow;

@end
