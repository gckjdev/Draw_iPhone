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
    self.penColor = color;
    self.drawView.lineColor = color;
    self.drawView.penType = self.penType;
}
- (void)changeDrawBG:(PBDrawBg *)drawBG
{
    self.drawView.drawBg = drawBG;
}

- (void)usePaintBucket
{
    DrawColor *color = [DrawColor colorWithColor:self.penColor];
    color.alpha = 1;
    [self.drawView changeBackWithColor:color];

    //TODO call back
}

- (void)changeInPenType:(ItemType)type
{
    self.penType = type;
    [self.drawView setPenType:type];
    if (type == Eraser) {
        self.drawView.lineColor = [DrawColor colorWithColor:self.eraserColor];
    }else{
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
}
- (void)changeDesc:(NSString *)desc
{
    
}
- (void)changeDrawToFriend:(MyFriend *)aFriend
{
    
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



/////////////////////////////

- (BOOL)grid
{
    return self.drawView.grid;
}


- (CGFloat)width
{
    return self.drawView.lineWidth;
}
- (PBDrawBg *)drawBG
{
    return self.drawView.drawBg;
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
