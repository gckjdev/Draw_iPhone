//
//  DrawSlider.h
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import <UIKit/UIKit.h>


@class DrawSlider;

@protocol DrawSliderDelegate <NSObject>

@optional
- (void)drawSlider:(DrawSlider *)drawSlider
    didValueChange:(CGFloat)value;
//       pointCenter:(CGPoint)center;

- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value;
- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value;


@end

@interface DrawSlider : UIControl
{
    
}


//@property(nonatomic, assign)CGFloat value;
@property(nonatomic, assign)CGFloat maxValue;
@property(nonatomic, assign)CGFloat minValue;
@property(nonatomic, assign)id<DrawSliderDelegate> delegate;
- (CGFloat)value;
- (void)setValue:(CGFloat)value;
@end

@class CMPopTipView;

@interface DrawSlider (PopupView)

- (void)popupWithContenView:(UIView *)contentView;
- (void)dismissPopupView;
- (UIView *)contentView;
- (CMPopTipView *)popTipView;
@end
