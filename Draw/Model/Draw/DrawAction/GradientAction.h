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
    BOOL _canUpdatePoints;
//    CGRect _rect;
}


@property(nonatomic, assign)CGFloat division;
@property(nonatomic, retain)DrawColor *startColor;
@property(nonatomic, retain)DrawColor *endColor;
@property(nonatomic, assign)CGPoint startPoint;
@property(nonatomic, assign)CGPoint endPoint;
@property(nonatomic, assign)CGRect rect;

- (CGFloat)degree;
//- (CGRect)rect;

- (id)initWithPBGradientC:(Game__PBGradient *)gradient;
- (void)updatePBGradientC:(Game__PBGradient *)gradient;
- (void)drawInContext:(CGContextRef)context;

//- (id)initWithStartPoint:(CGPoint)sp
//                endPoint:(CGPoint)ep
//              startColor:(DrawColor *)sc
//                endColor:(DrawColor *)ec
//                division:(CGFloat)division;

- (void)setDegree:(CGFloat)degree;

- (void)updatePointsWithDegreeAndDivision;

- (id)initWithDegree:(CGFloat)degree
          startColor:(DrawColor *)sc
            endColor:(DrawColor *)ec
            division:(CGFloat)division
              inRect:(CGRect)rect;

- (id)initWithGradient:(Gradient *)gradient;


@end

@interface GradientAction : DrawAction
{
    
}
@property(nonatomic, retain) Gradient *gradient;
- (id)initWithGradient:(Gradient *)gradient;
+ (GradientAction *)actionWithGradient:(Gradient *)gradient;
@end
