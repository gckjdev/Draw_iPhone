//
//  DrawToolPanel.h
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import <UIKit/UIKit.h>
#import "ColorPoint.h"
#import "DrawSlider.h"
#import "PenView.h"
#import "ItemType.h"
#import "Palette.h"
#import "CMPopTipView.h"
#import "PenBox.h"
#import "ColorBox.h"
#import "ColorShopView.h"


@class DrawToolPanel;

@protocol DrawToolPanelDelegate <NSObject>

@optional
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickRedoButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickEraserButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickPaintBucket:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectPen:(ItemType)penType;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectWidth:(CGFloat)width;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectAlpha:(CGFloat)alpha;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectColor:(DrawColor *)color;

@end

@interface DrawToolPanel : UIView<ColorPointDelegate, DrawSliderDelegate, CMPopTipViewDelegate, PenBoxDelegate, ColorBoxDelegate, ColorShopViewDelegate>
{
    
}
@property(nonatomic, assign)id<DrawToolPanelDelegate>delegate;
@property(nonatomic, retain)DrawColor *color;
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)CGFloat alpha;
@property(nonatomic, assign)ItemType penType;

+ (id)createViewWithdelegate:(id)delegate;
- (void)dismissAllPopTipViews;


@end
