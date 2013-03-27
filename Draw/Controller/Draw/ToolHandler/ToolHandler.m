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

- (void)changePenColor:(DrawColor *)color
{
    
}
- (void)changeDrawBG:(PBDrawBg *)drawBG
{
    
}

- (void)usePaintBucket
{
    
}

- (void)changeInPenType:(ItemType)type
{
    
}
- (void)changeCanvasRect:(CanvasRect *)canvasRect
{
    self.canvasRect = canvasRect;
}
- (void)changeWidth:(CGFloat)width
{
    
}
- (void)changeAlpha:(CGFloat)alpha
{
    
}
- (void)changeShape:(ShapeType)shape
{
    
}
- (void)changeDesc:(NSString *)desc
{
    
}
- (void)changeDrawToFriend:(MyFriend *)aFriend
{
    
}

- (void)enterDrawMode
{
    
}
- (void)enterStrawMode
{
    
}

- (void)useGid:(BOOL)flag
{
    
}


- (CGFloat)width
{
    return self.drawView.lineWidth;
}
- (PBDrawBg *)drawBG
{
    return self.drawView.drawBg;
}

@end
