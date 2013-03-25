//
//  ToolHandler.m
//  Draw
//
//  Created by gamy on 13-3-21.
//
//

#import "ToolHandler.h"
#import "BuyItemView.h"
#import "ItemType.h"
#import "BalanceNotEnoughAlertView.h"

@interface ToolHandler ()
{
    BOOL _isNewDraft;
    CGFloat _alpha;
}
@property (retain, nonatomic) DrawColor* eraserColor;
@property (retain, nonatomic) DrawColor* penColor;
@property (retain, nonatomic) DrawColor *tempColor;

@end

@implementation ToolHandler


#pragma mark - Draw Tool Panel Delegate


- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickRedoButton:(UIButton *)button
{
    BOOL canRedo = [_drawView canRedo];
    if (canRedo) {
        [_drawView redo];
        _isNewDraft = NO;
        [self synEraserColor];
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickStrawButton:(UIButton *)button
{
    _drawView.touchActionType = TouchActionTypeGetColor;
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickUndoButton:(UIButton *)button
{
    if ([_drawView canRevoke]) {
        _isNewDraft = NO;
        //        [self showActivityWithText:NSLS(@"kRevoking")];
        [self performSelector:@selector(performRevoke) withObject:nil afterDelay:0.1f];
    }else{
        [self.controller popupUnhappyMessage:NSLS(@"kCannotRevoke") title:nil];
    }
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickEraserButton:(UIButton *)button
{
    _drawView.touchActionType = TouchActionTypeDraw;
    [self.eraserColor setAlpha:1.0];
    [_drawView setLineColor:self.eraserColor];
    [_drawView setPenType:Eraser];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didClickPaintBucket:(UIButton *)button
{
    if (_drawView.touchActionType == TouchActionTypeGetColor) {
        _drawView.touchActionType = TouchActionTypeDraw;
    }
    
    _isNewDraft = NO;
    
    self.eraserColor = [DrawColor colorWithColor:self.penColor];
    [self.eraserColor setAlpha:1.0];
    [_drawView changeBackWithColor:self.eraserColor];
    
    self.penColor = [DrawColor blackColor];
    [toolPanel setColor:self.penColor];
    
    _drawView.lineColor = [DrawColor blackColor];
    [_drawView.lineColor setAlpha:_alpha];
    
    [self updateRecentColors];
    [_drawToolPanel updateRecentColorViewWithColor:[DrawColor blackColor]];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectPen:(ItemType)penType
               bought:(BOOL)bought
{
    if (bought) {
        PPDebug(@"<didSelectPen> pen type = %d",penType);
        _drawView.touchActionType = TouchActionTypeDraw;
        _drawView.penType = penType;
        //set draw color
        _drawView.lineColor = [DrawColor colorWithColor:self.penColor];
        [_drawView.lineColor setAlpha:_alpha];
    }else{
        [BuyItemView showOnlyBuyItemView:penType inView:self.controller.view resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
            if (resultCode == ERROR_BALANCE_NOT_ENOUGH) {
                [BalanceNotEnoughAlertView showInController:self.controller];
            }
        }];
    }
    
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectWidth:(CGFloat)width
{
    if (_drawView.touchActionType == TouchActionTypeGetColor) {
        _drawView.touchActionType = TouchActionTypeDraw;
    }
    _drawView.lineWidth = width;
    PPDebug(@"<didSelectWidth> width = %f",width);
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectColor:(DrawColor *)color
{
    if (_drawView.touchActionType == TouchActionTypeGetColor) {
        _drawView.touchActionType = TouchActionTypeDraw;
    }
    if (_drawView.penType == Eraser) {
        _drawView.penType = Pencil;
    }
    self.tempColor = color;
    self.penColor = color;
    [_drawView setLineColor:[DrawColor colorWithColor:color]];
    [_drawView.lineColor setAlpha:_alpha];
}
- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectAlpha:(CGFloat)alpha
{
    if (_drawView.touchActionType == TouchActionTypeGetColor) {
        _drawView.touchActionType = TouchActionTypeDraw;
    }
    _alpha = alpha;
    if (_drawView.lineColor != self.eraserColor) {
        DrawColor *color = [DrawColor colorWithColor:_drawView.lineColor];
        color.alpha = alpha;
        _drawView.lineColor = color;
    }
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel startToBuyItem:(ItemType)type
{
    [BuyItemView showOnlyBuyItemView:type inView:self.controller.view resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
        if (resultCode == ERROR_SUCCESS) {
            [self buyItemSuccess:itemId result:resultCode];
        }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH) {
            [BalanceNotEnoughAlertView showInController:self.controller];
        }
    }];
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectShapeType:(ShapeType)type
{
    _drawView.touchActionType = TouchActionTypeShape;
    _drawView.shapeType = type;
}

- (void)drawToolPanel:(DrawToolPanel *)toolPanel didSelectDrawBg:(PBDrawBg *)drawBg
{
    [_drawView setDrawBg:drawBg];
    //TODO add into off line draw bg
//    [[DrawRecoveryService defaultService] handleChangeDrawBg:drawBg];
    
}

@end
