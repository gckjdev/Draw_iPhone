//
//  NewGridDrawSlide.m
//  Draw
//
//  Created by ChaoSo on 14-10-22.
//
//

#import "NewGridDrawSlide.h"

@implementation NewGridDrawSlide

- (void)updateView
{
    [super updateView];
    [self setListenIntoBtn];
    
}
-(void)setListenIntoBtn{
    [_addButton addTarget:self action:@selector(touchDownBtn) forControlEvents:UIControlEventTouchDown];
    [_addButton addTarget:self action:@selector(touchUpBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [_delButton addTarget:self action:@selector(touchDownBtn) forControlEvents:UIControlEventTouchDown];
    [_delButton addTarget:self action:@selector(touchUpBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}



-(void)touchDownBtn{
    PPDebug(@"<NewGridDrawSlider touch Down AddButton>");
    [self didStartToChangeValue];
}
-(void)touchUpBtn:(UIButton *)btn{
    PPDebug(@"<NewGridDrawSlider touch up addButton>");
    int index = 1;
    if(btn.tag == 10000){
        index = -1;
    }
    
    int value = self.value+index;
    [self setValue:value];
    [self didValueChange];
//    [self didFinishClick];
    [self performSelector:@selector(updateNewValue) withObject:self afterDelay:0.0];

//    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(didFinishClick) userInfo:nil repeats:NO];

    
//    [self updateDegreeWithValue:value slider:drawSlider];
}

- (void)updateNewValue
{
    [self didStartToChangeValue];
    [self didFinishChangeValue];
}



+ (id)sliderWithMaxValue:(CGFloat)maxValue
                minValue:(CGFloat)minValue
            defaultValue:(CGFloat)defaultValue
                delegate:(id<DrawSliderDelegate>) delegate
{
    NewGridDrawSlide *slider = [UIView createViewWithXibIdentifier:@"NewGridDrawSlider"];
    [slider updateView];
    [slider setMaxValue:maxValue];
    [slider setMinValue:minValue];
    [slider setValue:defaultValue];
    [slider setDelegate:delegate];
    return slider;
}


-(void)didFinishChangeValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didFinishChangeValue:)]) {
        [self.delegate drawSlider:self didFinishChangeValue:self.value];
    }
}

-(void)didValueChange{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didValueChange:)]) {
        [self.delegate drawSlider:self didValueChange:self.value];
    }
}

-(void)didStartToChangeValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawSlider:didStartToChangeValue:)]) {
        [self.delegate drawSlider:self didStartToChangeValue:self.value];
    }
}


- (void)dealloc {
    [_addButton release];
    [_delButton release];
    [super dealloc];
}
@end
