//
//  GradientAction.m
//  Draw
//
//  Created by gamy on 13-7-1.
//
//

#import "GradientAction.h"
#import "DrawColor.h"

@implementation Gradient

- (void)dealloc
{
    PPRelease(_startColor);
    PPRelease(_endColor);
    [super dealloc];
}

#define COLOR_COUNT 2
#define POINT_COUNT 4

- (void)updatePBGradientC:(Game__PBGradient *)gradient
{
    gradient->division = self.division;
    gradient->division = 1;


    gradient->n_point = POINT_COUNT;
    gradient->point = malloc(sizeof(int32_t) * POINT_COUNT);
    gradient->point[0] = self.startPoint.x;
    gradient->point[1] = self.startPoint.y;
    gradient->point[2] = self.endPoint.x;
    gradient->point[3] = self.endPoint.y;

    
    if (self.startColor && self.endColor) {
        gradient->n_color = COLOR_COUNT;
        gradient->color = malloc(sizeof(int32_t) * COLOR_COUNT);
        gradient->color[0] = [self.startColor toBetterCompressColor];
        gradient->color[1] = [self.endColor toBetterCompressColor];
        
    }else{
        gradient->n_color = 0;
    }

}

- (id)initWithPBGradientC:(Game__PBGradient *)gradient
{
    self = [super init];
    if (self) {
        self.division = gradient->division;
        NSInteger count = gradient->n_color;
        if (count >= COLOR_COUNT) {
            self.startColor = [DrawColor colorWithBetterCompressColor:gradient->color[0]];
            self.endColor = [DrawColor colorWithBetterCompressColor:gradient->color[1]];
        }
        
        count = gradient->n_point;
        if (count >= POINT_COUNT) {
            _startPoint.x = gradient->point[0];
            _startPoint.y = gradient->point[1];
            _endPoint.x = gradient->point[2];
            _endPoint.y = gradient->point[3];
        }
    }
    return self;
}

- (CGFloat)degree
{
    //TODO
    return 0;
}

@end

@implementation GradientAction

@end
