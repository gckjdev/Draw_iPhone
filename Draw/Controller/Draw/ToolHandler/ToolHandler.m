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
#import "CanvasRect.h"
#import "OfflineDrawViewController.h"
#import "UIViewUtils.h"

@interface ToolHandler ()
{
    BOOL _isNewDraft;
    CGFloat _alpha;
}

@end

@implementation ToolHandler


#pragma mark - Draw Tool Panel Delegate





- (void)setDrawView:(DrawView *)drawView
{
    _drawView = drawView;
    self.penColor = drawView.lineColor;
    self.penType = drawView.penType;
}

- (void)changePenColor:(DrawColor *)color
{
    CGFloat alpha = self.penColor.alpha;
    color = [DrawColor colorWithColor:color];
    self.penColor = color;
    self.drawView.lineColor = color;
    self.drawView.penType = self.penType;
    [self changeAlpha:alpha];
    
}
- (void)changeDrawBG:(PBDrawBg *)drawBG
{
    [self.drawView changeBGImageWithDrawBG:drawBG];
}

- (void)usePaintBucket
{
    DrawColor *color = [DrawColor colorWithColor:self.penColor];
    color.alpha = 1;
    [self.drawView changeBackWithColor:color];

    [self changePenColor:[DrawColor blackColor]];
    [self changeInPenType:self.penType];
    [self.drawToolPanel updateRecentColorViewWithColor:[DrawColor blackColor] updateModel:NO];

}

- (void)changeInPenType:(ItemType)type
{

    [self.drawView setPenType:type];
    if (type == Eraser) {
        self.drawView.lineColor = [DrawColor colorWithColor:self.eraserColor];
    }else{
        self.penType = type;        
        self.drawView.lineColor = self.penColor;
    }
}

- (BOOL)changeCanvasRect:(CanvasRect *)canvasRect
{
    if ([[self.drawView drawActionList] count] == 0) {
        self.canvasRect = canvasRect;
        [self.drawView changeRect:canvasRect.rect];
        return YES;
    }
    PPDebug(@"<changeCanvasRect> fail, draw view is not empty");
    return NO;
}
- (void)changeWidth:(CGFloat)width
{
    self.drawView.lineWidth = width;
}
- (void)changeAlpha:(CGFloat)alpha
{
    [self.penColor setAlpha:alpha];
    if (self.drawView.penType != Eraser) {
        [self.drawView.lineColor setAlpha:alpha];
    }
}
- (void)changeShape:(ShapeType)shape
{
    self.drawView.touchActionType = TouchActionTypeShape;
    [self.drawView setShapeType:shape];
    self.drawView.penType = self.penType;
}
- (void)changeDesc:(NSString *)desc
{
    PPDebug(@"<ChangeDesc> desc = %@", desc);
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self.drawView theViewController];
    oc.opusDesc = desc;
}
- (void)changeDrawToFriend:(MyFriend *)aFriend
{
    PPDebug(@"<changeDrawToFriend> nick = %@", aFriend.nickName);
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self.drawView theViewController];
    [oc setTargetUid:aFriend.friendUserId];
}

- (void)enterDrawMode
{
    self.drawView.touchActionType = TouchActionTypeDraw;
}
- (void)enterStrawMode
{
    self.drawView.touchActionType = TouchActionTypeGetColor;
}

- (void)useGid:(BOOL)flag
{
    self.drawView.grid = flag;
}

- (void)handleRedo
{
    [self.drawView redo];
}
- (void)handleUndo
{
    [self.drawView undo];
}

- (TouchActionType)setTouchActionType:(TouchActionType)type
{
    self.drawView.touchActionType = type;
}
- (TouchActionType)touchActionType
{
    return self.drawView.touchActionType;
}
/////////////////////////////
//Atrributes

- (BOOL)grid
{
    return self.drawView.grid;
}


- (CGFloat)width
{
    return self.drawView.lineWidth;
}

- (CanvasRect *)canvasRect
{
    if (_canvasRect == nil) {
        self.canvasRect = [CanvasRect canvasRectWithStyle:[CanvasRect defaultCanvasRectStyle]];
    }
    return _canvasRect;
}

- (DrawColor *)eraserColor
{
    return self.drawView.bgColor;
}

@end
