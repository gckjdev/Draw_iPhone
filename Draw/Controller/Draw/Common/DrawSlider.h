//
//  DrawSlider.h
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import <UIKit/UIKit.h>

typedef enum{
    
    DrawSliderStyleSmall = 1,
    DrawSliderStyleLarge = 2,
    
}DrawSliderStyle;

@interface DrawSlider : UIControl
{
    
}

- (id)initWithDrawSliderStyle:(DrawSliderStyle)style;

@property(nonatomic, assign)CGFloat value;
@property(nonatomic, assign)DrawSliderStyle style;


@end
