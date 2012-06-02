//
//  Paint.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PenView.h"

@class DrawColor;
@class GameMessage;

@interface Paint : NSObject <NSCoding>
{
    CGFloat _width;
    DrawColor *_color;
    NSMutableArray *_pointList;
    PenType _penType;
}
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)PenType penType;
@property(nonatomic,retain)DrawColor* color;
@property(nonatomic,retain)NSMutableArray *pointList;



- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color;
- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList;

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color penType:(PenType)type;
- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList penType:(PenType)type;


- (id)initWithGameMessage:(GameMessage *)gameMessage;

- (void)addPoint:(CGPoint)point;
- (CGPoint)pointAtIndex:(NSInteger)index;
- (NSInteger)pointCount;
- (NSString *)toString;
+ (Paint *)paintWithWidth:(CGFloat)width color:(DrawColor*)color;
+ (Paint *)paintWithWidth:(CGFloat)width color:(DrawColor*)color penType:(PenType)type;

@end
