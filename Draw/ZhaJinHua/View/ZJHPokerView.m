//
//  ZJHPokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-26.
//
//

#import "ZJHPokerView.h"

//#define POKER_X_AXIS_OFFSET 30
#define POKER_VIEW_TAG_OFFSET 200

@interface ZJHPokerView ()
{
//    CGPoint _poker1OriginCenter;
//    CGPoint _poker2OriginCenter;
//    CGPoint _poker3OriginCenter;
}

@end

@implementation ZJHPokerView

#pragma mark - life cycle

- (void)dealloc {    
    [_poker1View release];
    [_poker2View release];
    [_poker3View release];
    [super dealloc];
}

#pragma mark - public methods

- (void)updateWithPokers:(NSArray *)pokers
                    size:(CGSize)size
                     gap:(CGFloat)gap
                delegate:(id<PokerViewProtocol>)delegate
{
    if ([pokers count] < 3) {
        return;
    }
    [self clear];
        
    Poker *poker1 = [pokers objectAtIndex:0];
    Poker *poker2 = [pokers objectAtIndex:1];
    Poker *poker3 = [pokers objectAtIndex:2];

    // alloc and init poker view
    CGFloat pokerViewOffset = 0;
    CGRect frame = CGRectMake(pokerViewOffset, 0, size.width, size.height);
    self.poker1View = [PokerView createPokerViewWithPoker:poker1
                                                    frame:frame
                                                 isFaceUp:NO
                                                 delegate:delegate];
    
    pokerViewOffset = self.poker1View.frame.origin.x + self.poker1View.frame.size.width + gap;
    frame = CGRectMake(pokerViewOffset, 0, size.width, size.height);
    self.poker2View = [PokerView createPokerViewWithPoker:poker2
                                                    frame:frame
                                                 isFaceUp:NO
                                                 delegate:delegate];

    
    pokerViewOffset = self.poker2View.frame.origin.x + self.poker2View.frame.size.width + gap;
    frame = CGRectMake(pokerViewOffset, 0, size.width, size.height);
    self.poker3View = [PokerView createPokerViewWithPoker:poker3
                                                    frame:frame
                                                 isFaceUp:NO
                                                 delegate:delegate];
    
//    // save original center
//    _poker1OriginCenter = self.poker1View.center;
//    _poker2OriginCenter = self.poker2View.center;
//    _poker3OriginCenter = self.poker3View.center;
    
    // add poker views
    [self addSubview:self.poker1View];
    [self addSubview:self.poker2View];
    [self addSubview:self.poker3View];
}

- (void)clear
{
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
}

- (void)makeSectorShape:(ZJHPokerSectorType)sectorType animation:(BOOL)animation
{
    switch (sectorType) {
        case ZJHPokerSectorTypeRight:
            [self.poker2View rotateToAngle:(M_PI * (1.0/12.0)) animation:animation];
            [self.poker3View rotateToAngle:(M_PI * (1.0/6.0)) animation:animation];
            break;
            
        case ZJHPokerSectorTypeLeft:
            [self.poker1View rotateToAngle:(-M_PI * (1.0/6.0)) animation:animation];
            [self.poker2View rotateToAngle:(-M_PI * (1.0/12.0)) animation:animation];
            break;
            
        case ZJHPokerSectorTypeCenter:
            [self.poker1View rotateToAngle:(-M_PI * (1.0/12.0)) animation:animation];
            [self.poker3View rotateToAngle:(M_PI * (1.0/12.0)) animation:animation];
            break;
            
        default:
            break;
    }
}

- (void)faceUpCards:(BOOL)animation
{
//    [self.poker1View moveToCenter:CGPointMake(_poker1OriginCenter.x - POKER_X_AXIS_OFFSET, _poker1OriginCenter.y) animation:animation];
    [self.poker1View faceUp:animation];
    [self.poker1View enableUserInterface];
    
    [self.poker2View faceUp:animation];
    [self.poker2View enableUserInterface];

//    [self.poker3View moveToCenter:CGPointMake(_poker3OriginCenter.x + POKER_X_AXIS_OFFSET, _poker3OriginCenter.y) animation:animation];
    [self.poker3View faceUp:animation];
    [self.poker3View enableUserInterface];
}

- (void)faceUpCard:(int)cardId animation:(BOOL)animation
{
    if (self.poker1View.poker.pokerId == cardId) {
        [self.poker1View faceUp:animation];
    }
    
    if (self.poker2View.poker.pokerId == cardId) {
        [self.poker2View faceUp:animation];
    }
    
    if (self.poker3View.poker.pokerId == cardId) {
        [self.poker3View faceUp:animation];
    }
}

- (void)foldCards:(BOOL)animation
{
    [self.poker1View faceDown:animation];
    [self.poker1View backToOriginPosition:animation];
    [self.poker2View faceDown:animation];
    [self.poker2View backToOriginPosition:animation];
    [self.poker3View faceDown:animation];
    [self.poker3View backToOriginPosition:animation];
}

- (void)compare:(BOOL)animation
            win:(BOOL)win
{
    // TODO:
    if (win) {
        [self win:animation];
    }else {
        [self lose:animation];
    }
}

#pragma mark - pravite methods

- (void)lose:(BOOL)animation
{
    
}

- (void)win:(BOOL)animation
{
    
}


@end
