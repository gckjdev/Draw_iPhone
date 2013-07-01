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
    
}


@property(nonatomic, assign)CGFloat division;
@property(nonatomic, retain)DrawColor *startColor;
@property(nonatomic, retain)DrawColor *endColor;
@property(nonatomic, assign)CGPoint startPoint;
@property(nonatomic, assign)CGPoint endPoint;

- (CGFloat)degree;

- (id)initWithPBGradientC:(Game__PBGradient *)gradient;
- (void)updatePBGradientC:(Game__PBGradient *)gradient;

@end

@interface GradientAction : DrawAction
{
    
}


@end
