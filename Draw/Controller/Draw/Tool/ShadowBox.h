//
//  ShapeBox.h
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import <UIKit/UIKit.h>
#import "DrawSlider.h"
#import "Palette.h"

@class Shadow;
@class DrawSlider;
@class ShadowBox;
@class ShadowSettingView;

@protocol ShadowSettingViewDelegate <NSObject>

- (void)shadowSettingView:(ShadowSettingView *)settingView
          didChangeShadow:(Shadow *)shadow;

@end

@protocol ShadowBoxDelegate <NSObject>

- (void)shadowBox:(ShadowBox *)box didGetShadow:(Shadow *)shadow;

@end

@interface ShadowBox : UIView<ShadowSettingViewDelegate>
{
    
}

@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *applyButton;
@property (retain, nonatomic) IBOutlet UIButton *customButton;
@property (retain, nonatomic)  Shadow *shadow;
@property (assign, nonatomic) id<ShadowBoxDelegate>delegate;

- (IBAction)clickCancel:(id)sender;
- (IBAction)clickApply:(id)sender;
- (IBAction)clickCustom:(id)sender;
- (IBAction)clickRecentShadow:(UIButton *)sender;
- (IBAction)clickSystemShadow:(UIButton *)sender;


//Should pass a copy of shadow, or the attributes of it will be changed
+ (id)shadowBoxWithShadow:(Shadow *)shadow;

@end



@interface ShadowPreview : UIView
{
    
}

@property(nonatomic, assign) Shadow *shadow;

+ (id)shadowPreviewWithShadow:(Shadow *)shadow;

@end



@interface ShadowSettingView : UIView <DrawSliderDelegate, ColorPickingBoxDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *degreeLabel;
@property (retain, nonatomic) IBOutlet UILabel *distanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *blurLabel;
@property (retain, nonatomic) IBOutlet DrawSlider *degreeSlider;
@property (retain, nonatomic) IBOutlet DrawSlider *distanceSlider;
@property (retain, nonatomic) IBOutlet DrawSlider *blurSlider;

@property(nonatomic, assign) id<ShadowSettingViewDelegate>delegate;

@property(nonatomic, assign) Shadow *shadow;
@property (retain, nonatomic) IBOutlet Palette *palette;

+ (id)shadowSettingViewWithShadow:(Shadow *)shadow;
- (void)updateSliders;
@end
