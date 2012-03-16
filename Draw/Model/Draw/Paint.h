//
//  Paint.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DrawColor;
@interface Paint : NSObject
{
    CGFloat _width;
    DrawColor *_color;
    NSMutableArray *_pointList;
}
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,retain)DrawColor* color;
@property(nonatomic,retain)NSMutableArray *pointList;
- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color;
- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList;

- (void)addPoint:(CGPoint)point;
- (CGPoint)pointAtIndex:(NSInteger)index;
- (NSInteger)pointCount;



@end
