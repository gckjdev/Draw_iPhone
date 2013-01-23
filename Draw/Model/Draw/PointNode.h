//
//  PointNode.h
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import <Foundation/Foundation.h>

@interface PointNode : NSObject

@property(nonatomic, assign) CGFloat x;
@property(nonatomic, assign) CGFloat y;

- (void)setPoint:(CGPoint)point;
- (CGPoint)point;
+ (id)pointWithCGPoint:(CGPoint)point;

@end

