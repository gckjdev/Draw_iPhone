//
//  NewGridDrawSlide.h
//  Draw
//
//  Created by ChaoSo on 14-10-22.
//
//

#import <Foundation/Foundation.h>
#import "DrawSlider.h"
@interface NewGridDrawSlide : DrawSlider
@property (retain, nonatomic) IBOutlet UIButton *addButton;
@property (retain, nonatomic) IBOutlet UIButton *delButton;

+ (id)sliderWithMaxValue:(CGFloat)maxValue
                minValue:(CGFloat)minValue
            defaultValue:(CGFloat)defaultValue
                delegate:(id<DrawSliderDelegate>) delegate;
- (void)updateView;
@end
