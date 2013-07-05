//
//  GradientAction.h
//  Draw
//
//  Created by gamy on 13-7-1.
//
//

#import "DrawAction.h"

@class PBGradient;

@interface Gradient : NSObject
{
    CGFloat _degree;
    CGRect _rect;
}


@property(nonatomic, assign)CGFloat division;
@property(nonatomic, retain)DrawColor *startColor;
@property(nonatomic, retain)DrawColor *endColor;
@property(nonatomic, assign)CGPoint startPoint;
@property(nonatomic, assign)CGPoint endPoint;

- (CGFloat)degree;

- (id)initWithPBGradientC:(Game__PBGradient *)gradient;
- (void)updatePBGradientC:(Game__PBGradient *)gradient;
- (void)drawInContext:(CGContextRef)context;

//- (id)initWithStartPoint:(CGPoint)sp
//                endPoint:(CGPoint)ep
//              startColor:(DrawColor *)sc
//                endColor:(DrawColor *)ec
//                division:(CGFloat)division;

- (void)setDegree:(CGFloat)degree;

- (id)initWithDegree:(CGFloat)degree
          startColor:(DrawColor *)sc
            endColor:(DrawColor *)ec
            division:(CGFloat)division
              inRect:(CGRect)rect;


@end

@interface GradientAction : DrawAction
{
    
}
@property(nonatomic, retain) Gradient *gradient;
- (id)initWithGradient:(Gradient *)gradient;

@end
