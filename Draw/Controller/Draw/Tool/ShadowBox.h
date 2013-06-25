//
//  ShapeBox.h
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import <UIKit/UIKit.h>
#import "Draw.pb.h"


@class Shadow;
@class DrawSlider;
@class ShadowBox;

@protocol ShadowBoxDelegate <NSObject>

- (void)shadowBox:(ShadowBox)box didGetShadow:(Shadow *)shadow;

@end

@interface ShadowBox : UIView
{
    
}

@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *applyButton;
@property (retain, nonatomic) IBOutlet UIButton *customButton;
@property (retain, nonatomic)  Shadow *shadow;;

- (IBAction)clickCancel:(id)sender;
- (IBAction)clickApply:(id)sender;
- (IBAction)clickCustom:(id)sender;
- (IBAction)clickExistingShadow:(UIButton *)sender;

@end



@interface ShadowPreview : UIView
{
    
}

@property(nonatomic, assign) Shadow *shadow;

@end



@interface ShadowSettingView : UIView
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *degreeLabel;
@property (retain, nonatomic) IBOutlet UILabel *distanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *blurLabel;
@property (retain, nonatomic) IBOutlet DrawSlider *degreeSlider;
@property (retain, nonatomic) IBOutlet DrawSlider *distanceSlider;
@property (retain, nonatomic) IBOutlet DrawSlider *blurSlider;

@property(nonatomic, assign) Shadow *shadow;

@end
