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

@class DrawToolPanel;

@protocol DrawToolPanelDelegate <NSObject>

@optional
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickRedoButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickEraserButton:(UIButton *)button;

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickPaintBucket:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectPen:(PenView *)penView;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectWidth:(CGFloat)width;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectColor:(DrawColor *)color;

@end

@interface DrawToolPanel : UIView<ColorPointDelegate, DrawSliderDelegate, CMPopTipViewDelegate>
{
    
}
@property(nonatomic, assign)id<DrawToolPanelDelegate>delegate;
+ (id)createViewWithdelegate:(id)delegate;
- (void)dismissAllPopTipViews;

@end
