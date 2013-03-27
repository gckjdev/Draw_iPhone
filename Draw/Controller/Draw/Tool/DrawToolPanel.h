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
#import "DrawView.h"
#import "WidthBox.h"
#import "ShapeBox.h"
#import "DrawBgBox.h"



@class DrawToolPanel;
@class ToolHandler;

@protocol DrawToolPanelDelegate <NSObject>

@optional
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickStrawButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickRedoButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickEraserButton:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickPaintBucket:(UIButton *)button;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectPen:(ItemType)penType
               bought:(BOOL)bought;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectWidth:(CGFloat)width;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectAlpha:(CGFloat)alpha;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectColor:(DrawColor *)color;

- (void)drawToolPanel:(DrawToolPanel *)toolPanel startToBuyItem:(ItemType)type;
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectShapeType:(ShapeType)type;

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectDrawBg:(PBDrawBg *)drawBg;

//online
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickChatButton:(UIButton *)button;
- (void)drawToolPanelDidTimeout:(DrawToolPanel *)toolPanel;
@end


//@protocol ColorPointDelegate;
//@protocol DrawSliderDelegate;
//@protocol CMPopTipViewDelegate;
//@protocol PenBoxDelegate;
//@protocol ColorBoxDelegate;
//@protocol ColorShopViewDelegate;
//@protocol DrawViewStrawDelegate;
//@protocol WidthBoxDelegate;
//@protocol ShapeBoxDelegate;
//@protocol ColorPickingBoxDelegate;


@interface DrawToolPanel : UIView<ColorPointDelegate, DrawSliderDelegate, CMPopTipViewDelegate, PenBoxDelegate, ColorBoxDelegate, ColorShopViewDelegate, DrawViewStrawDelegate, WidthBoxDelegate, ShapeBoxDelegate, DrawBgBoxDelegate>
{
    
}
@property(nonatomic, assign)id<DrawToolPanelDelegate>delegate;
@property(nonatomic, retain)DrawColor *color;
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)CGFloat alpha;
@property(nonatomic, assign)ItemType penType;
@property(nonatomic, assign)ShapeType shapeType;
@property(nonatomic, assign)NSInteger timerDuration;
@property(nonatomic, retain)NSString *drawBgId;

@property(nonatomic, retain)ToolHandler *toolHandler;


+ (id)createViewWithdelegate:(id)delegate;

+ (id)createViewWithdToolHandler:(ToolHandler *)handler;

- (void)updateView;
- (void)dismissAllPopTipViews;
- (void)setPanelForOnline:(BOOL)isOnline;
- (void)updateRecentColorViewWithColor:(DrawColor *)color;
- (void)updateNeedBuyToolViews;

- (void)userItem:(ItemType)type;

#pragma mark - Timer

- (void)startTimer;
- (void)stopTimer;
//- (void)restartTimer;
@end
