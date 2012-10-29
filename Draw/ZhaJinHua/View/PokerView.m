//
//  PokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "PokerView.h"
#import "ZJHGameService.h"
#import "ZJHImageManager.h"

#define POKER_VIEW_ROTATE_ANCHOR_POINT CGPointMake(0, 0)

@interface PokerView ()
{
    CGFloat _originAngle;
    CGFloat _newAngle;
    CGPoint _originCenter;
    CGPoint _newCenter;
}

@property (readwrite, retain, nonatomic) Poker *poker;
@property (readwrite, assign, nonatomic) BOOL isFaceUp;

@end

@implementation PokerView


- (void)dealloc {
    [_poker release];
    [_backImageView release];
    [_fontView release];
    [_rankImageView release];
    [_suitImageView release];
    [_bodyImageView release];
    [_tickImageView release];
    [_bodyImageView release];
    [super dealloc];
}

- (void)setOriginCenter:(CGPoint *)center
          originalAngle:(CGFloat)angle
{
    _originAngle = angle;
    _originCenter = self.center;
}

+ (id)createPokerView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PokerView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}

+ (id)createPokerViewWithPoker:(Poker *)poker isFaceUp:(BOOL)isFaceUp
{
    PokerView *pokerView = [PokerView createPokerView];
    [pokerView addTarget:self action:@selector(clickSelf:) forControlEvents:UIControlEventTouchUpInside];
    
    pokerView.poker = poker;
    pokerView.isFaceUp = isFaceUp;
    
    pokerView.backImageView.image = [[ZJHImageManager defaultManager] pokerBackImage];
    
    pokerView.fontBgImageView.image = [[ZJHImageManager defaultManager] pokerFontBgImage];
    pokerView.rankImageView.image = [[ZJHImageManager defaultManager] pokerRankImage:poker];
    pokerView.suitImageView.image = [[ZJHImageManager defaultManager] pokerSuitImage:poker];
    pokerView.bodyImageView.image = [[ZJHImageManager defaultManager] pokerBodyImage:poker];
    
    if (isFaceUp) {
        [pokerView faceUp:NO];
    }else {
        [pokerView faceDown:NO];
    }
    
    return pokerView;
}

- (void)faceDown:(BOOL)animation
{
    if (_isFaceUp) {
        _isFaceUp = NO;
        
        self.backImageView.hidden = NO;
        self.fontBgImageView.hidden = YES;
    }
}

- (void)faceUp:(BOOL)animation
{
    if (!_isFaceUp) {
        _isFaceUp = YES;
        
        self.backImageView.hidden = YES;
        self.fontBgImageView.hidden = NO;
    }
}

- (void)rotateToAngle:(CGFloat)angle animation:(BOOL)animation
{
    if (angle == _newAngle) {
        return;
    }
    
    CGFloat routeAngle = angle - _newAngle;
    _newAngle = angle;

    // TODO: rotate self
    
}

- (void)moveToCenter:(CGPoint)center animation:(BOOL)animation
{
    if (center.x == _newCenter.x && center.y == _newCenter.y) {
        return;
    }
    
    _newCenter = center;
    
    // TODO: move to center;
    
}

- (void)backToOriginPosition:(BOOL)animation
{
    if (_newAngle != _originAngle) {
        [self rotateToAngle:_originAngle animation:animation];
    }
    
    if (_newCenter.x != _originCenter.x || _newCenter.y != _originCenter.y) {
        [self moveToCenter:_originCenter animation:animation];
    }
}


#pragma mark - click action
- (void)clickSelf:(id)sender
{
    PPDebug(@"clickSelf");
    PokerView *pokerView = (PokerView *)pokerView;
    
    if (pokerView.isFaceUp) {
        [self popupShowCardButton];
    }
}

- (void)didClickShowCardButton:(id)sender
{
    PPDebug(@"didClickShowCardButton");
    self.tickImageView.image = [UIImage imageNamed:@""];

    [[ZJHGameService defaultService] showCard:_poker.pokerId];
}


@end
