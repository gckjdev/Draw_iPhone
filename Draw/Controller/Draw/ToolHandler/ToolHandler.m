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
#import "OnlineDrawViewController.h"
#import "UIViewUtils.h"

@interface ToolHandler ()
{
    BOOL _isNewDraft;
    CGFloat _alpha;
}

@end

@implementation ToolHandler


- (void)dealloc
{
    PPDebug(@"%@ dealloc",self);
    self.controller = nil;
    self.drawView = nil;
    self.drawToolPanel = nil;
    PPRelease(_canvasRect);
    PPRelease(_penColor);
    [super dealloc];
}


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
        self.drawView.lineColor = [DrawColor colorWithColor:self.penColor];
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
    self.penColor = [DrawColor colorWithColor:self.penColor];
    [self.penColor setAlpha:alpha];
    if (self.drawView.penType != Eraser) {
        DrawColor *color = [DrawColor colorWithColor:self.drawView.lineColor];
        [color setAlpha:alpha];
        self.drawView.lineColor = color;
    }
}
- (void)changeShape:(ShapeType)shape isStroke:(BOOL)isStroke
{
    [self enterShapeMode];
    [self.drawView setShapeType:shape];
    [self.drawView setStrokeShape:isStroke];
    self.drawView.penType = self.penType;
    [self changePenColor:self.penColor];
}
- (void)changeDesc:(NSString *)desc
{
    PPDebug(@"<ChangeDesc> desc = %@", desc);
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    oc.opusDesc = desc;
}
- (void)changeDrawWord:(NSString*)wordText
{
    PPDebug(@"<changeDrawWord> desc = %@", wordText);
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    oc.word = [Word wordWithText:wordText level:0];
}
- (void)changeDrawToFriend:(MyFriend *)aFriend
{
    PPDebug(@"<changeDrawToFriend> nick = %@", aFriend.nickName);
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    [oc setTargetUid:aFriend.friendUserId];
}

- (void)enterShapeMode
{
    self.drawView.touchActionType = TouchActionTypeShape;
    [self.drawToolPanel setShapeSelected:YES];
    [self.drawToolPanel setPenSelected:NO];
    [self.drawToolPanel setStrawSelected:NO];
    [self.drawToolPanel setEraserSelected:NO];    
}
- (void)enterEraserMode
{
    self.drawView.touchActionType = TouchActionTypeDraw;
    [self.drawToolPanel setPenSelected:NO];
    [self.drawToolPanel setShapeSelected:NO];
    [self.drawToolPanel setStrawSelected:NO];
    [self.drawToolPanel setEraserSelected:YES];
}
- (void)enterDrawMode
{
    self.drawView.touchActionType = TouchActionTypeDraw;
    [self.drawToolPanel setPenSelected:YES];
    [self.drawToolPanel setShapeSelected:NO];
    [self.drawToolPanel setStrawSelected:NO];
    [self.drawToolPanel setEraserSelected:NO];
}
- (void)enterStrawMode
{
    self.drawView.touchActionType = TouchActionTypeGetColor;
    [self.drawToolPanel setStrawSelected:YES];
    [self.drawToolPanel setShapeSelected:NO];
    [self.drawToolPanel setPenSelected:NO];
    [self.drawToolPanel setEraserSelected:NO];
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

- (void)handleChat
{
    OnlineDrawViewController *oc = (OnlineDrawViewController *)self.controller;
    [oc showGroupChatView];
}

- (TouchActionType)setTouchActionType:(TouchActionType)type
{
    self.drawView.touchActionType = type;
    return self.drawView.touchActionType;
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
        self.canvasRect = [CanvasRect canvasRectWithRect:self.drawView.bounds];
        if(_canvasRect == nil){
            self.canvasRect = [CanvasRect canvasRectWithStyle:[CanvasRect defaultCanvasRectStyle]];
        }
    }
    return _canvasRect;
}

- (DrawColor *)eraserColor
{
    return self.drawView.bgColor;
}

@end
