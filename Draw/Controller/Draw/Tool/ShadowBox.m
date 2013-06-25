//
//  ShadowBox.m
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import "ShadowBox.h"
#import "DrawAction.h"
#import "DrawSlider.h"



@implementation ShadowBox


- (void)dealloc {
    [_cancelButton release];
    [_applyButton release];
    [_customButton release];
    PPRelease(_shadow);
    [super dealloc];
}
- (IBAction)clickCancel:(id)sender {
}

- (IBAction)clickApply:(id)sender {
}

- (IBAction)clickCustom:(id)sender {
}

- (IBAction)clickExistingShadow:(UIButton *)sender {
    
}
@end






#define PREVIEW_FRAME_IPHONE CGRectMake(5, 85, 240, 60)
#define PREVIEW_FRAME_IPAD CGRectMake(5, 85, 240, 60)
#define PREVIEW_FRAME ISIPAD ? PREVIEW_FRAME_IPAD : PREVIEW_FRAME_IPHONE

@implementation ShadowPreview

- (void)setShadow:(Shadow *)shadow
{
    if (_shadow != shadow) {
        _shadow = shadow;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    
}

@end


@implementation ShadowSettingView


- (void)dealloc {
    [_degreeLabel release];
    [_distanceLabel release];
    [_blurLabel release];
    [_degreeSlider release];
    [_distanceSlider release];
    [_blurSlider release];
    [super dealloc];
}
@end
