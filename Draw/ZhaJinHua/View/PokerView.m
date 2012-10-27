//
//  PokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "PokerView.h"
#import "ZJHGameService.h"

#define POKER_VIEW_ROTATE_ANCHOR_POINT CGPointMake(0, 0)

@interface PokerView ()
{
    CGFloat _originAngle;
    CGFloat _newAngle;
    CGPoint _originCenter;
    CGPoint _newCenter;
    
    
}

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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self  = [super initWithCoder:aDecoder];
    if (self) {
        [self addTarget:self action:@selector(clickSelf:) forControlEvents:UIControlEventTouchUpInside];
        _originAngle =  0;
        _newAngle = 0;
        _originCenter = self.center;
        _newCenter = self.center;
    }
    
    return self;
}

- (void)updatePoker:(Poker *)poker
{
    
}


- (void)faceDown:(BOOL)animation
{
    self.backImageView.hidden = NO;
}

- (void)faceUp:(BOOL)animation
{
    self.backImageView.hidden = YES;
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



- (void)clickSelf:(id)sender
{
    PPDebug(@"clickSelf");
    [self popupShowCardButton];
}


- (void)didClickShowCardButton:(id)sender
{
    PPDebug(@"didClickShowCardButton");
    [[ZJHGameService defaultService] showCard:_poker.pokerId];
    self.tickImageView.image = [UIImage imageNamed:@""];
}

@end
