//
//  Paint.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Paint : NSObject
{
    CGFloat _width;
    UIColor *_color;
    NSMutableArray *_pointList;
}
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,retain)UIColor* color;
@property(nonatomic,retain)NSMutableArray *pointList;
- (id)initWithWidth:(CGFloat)width color:(UIColor*)color;
- (void)addPoint:(CGPoint)point;
- (CGPoint)pointAtIndex:(NSInteger)index;
- (NSInteger)pointCount;

@end
