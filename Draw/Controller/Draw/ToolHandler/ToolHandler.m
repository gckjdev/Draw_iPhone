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
#import "CommonMessageCenter.h"
#import "GradientAction.h"

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


- (void)printDrawColor:(NSTimer *)timer
{
//    PPDebug(@"Draw Color = %@", self.drawView.lineColor);
}

- (id)init
{
    self = [super init];
    if (self) {

#ifdef DEBUG
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(printDrawColor:) userInfo:nil repeats:YES];
#endif
        
    }
    return self;
}

- (void)setDrawView:(DrawView *)drawView
{
    _drawView = drawView;
    self.penColor = [DrawColor colorWithColor:drawView.lineColor];
    self.penType = drawView.penType;
}

- (void)changeShadow:(Shadow *)shadow
{
    self.shadow = shadow;
    self.drawView.shadow = shadow;
}



- (void)changePenColor:(DrawColor *)color
{
    CGFloat alpha = self.penColor.alpha;
    self.penColor = [DrawColor colorWithColor:color];
    self.drawView.lineColor = [DrawColor colorWithColor:color];;
    self.drawView.penType = self.penType;

    [self.penColor setAlpha:alpha];
    if (self.drawView.penType != Eraser) {
        [self.drawView.lineColor setAlpha:alpha];
    }
}
- (void)changeDrawBG:(PBDrawBg *)drawBG
{
    [self.drawView changeBGImageWithDrawBG:drawBG];
}

- (void)addGradient
{

    CGPoint ep = CGPointMake(CGRectGetMaxX(self.drawView.bounds), CGRectGetMaxY(self.drawView.bounds));
    Gradient *gd = [[Gradient alloc] initWithStartPoint:CGPointZero endPoint:ep startColor:[DrawColor rankColor] endColor:[DrawColor rankColor] division:0.5];
    GradientAction *gradient = [[[GradientAction alloc] initWithGradient:gd] autorelease];
    [self.drawView addGradient:gradient];
}

- (void)usePaintBucket
{
#ifdef DEBUG
    [self addGradient];
    return;
#endif
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
    [self.penColor setAlpha:alpha];
    if (self.drawView.penType != Eraser) {
        self.drawView.lineColor = [DrawColor colorWithColor:self.penColor];
    }
}
- (void)changeShape:(ShapeType)shape isStroke:(BOOL)isStroke
{
    [self enterShapeMode];
    [self.drawView setShapeType:shape];
    [self.drawView setStrokeShape:isStroke];
    self.drawView.penType = self.penType;
    self.drawView.lineColor = [DrawColor colorWithColor:self.penColor];
}
- (void)changeShapeStroke:(BOOL)isStroke
{
    [self.drawView setStrokeShape:isStroke];
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

- (void)changeCopyPaint:(PBUserPhoto*)aPhoto
{
    PPDebug(@"<changeCopyPaint> photo id = ", aPhoto.photoId);
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    [oc setCopyPaintUrl:aPhoto.url];
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
    if ([self.drawView canRevoke]) {
        [self.drawView undo];
    }else if([[self.drawView drawActionList] count] > 0){
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCannotRevoke") delayTime:1.5 isHappy:NO];
    }    
}

- (void)handleChat
{
    OnlineDrawViewController *oc = (OnlineDrawViewController *)self.controller;
    [oc showGroupChatView];
}

- (void)handleShowCopyPaint
{
    OfflineDrawViewController *oc = (OfflineDrawViewController *)self.controller;
    [oc showCopyPaint];
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
