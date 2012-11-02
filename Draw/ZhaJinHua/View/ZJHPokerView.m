//
//  ZJHPokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-26.
//
//

#import "ZJHPokerView.h"
#import "ZJHImageManager.h"

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
    [_pokerView1 release];
    [_pokerView2 release];
    [_pokerView3 release];
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
    self.pokerView1 = [PokerView createPokerViewWithPoker:poker1
                                                    frame:frame
                                                 isFaceUp:NO
                                                 delegate:delegate];
    
    pokerViewOffset = self.pokerView1.frame.origin.x + self.pokerView1.frame.size.width + gap;
    frame = CGRectMake(pokerViewOffset, 0, size.width, size.height);
    self.pokerView2 = [PokerView createPokerViewWithPoker:poker2
                                                    frame:frame
                                                 isFaceUp:NO
                                                 delegate:delegate];

    
    pokerViewOffset = self.pokerView2.frame.origin.x + self.pokerView2.frame.size.width + gap;
    frame = CGRectMake(pokerViewOffset, 0, size.width, size.height);
    self.pokerView3 = [PokerView createPokerViewWithPoker:poker3
                                                    frame:frame
                                                 isFaceUp:NO
                                                 delegate:delegate];
    
//    // save original center
//    _poker1OriginCenter = self.poker1View.center;
//    _poker2OriginCenter = self.poker2View.center;
//    _poker3OriginCenter = self.poker3View.center;
    
    // add poker views
    [self addSubview:self.pokerView1];
    [self addSubview:self.pokerView2];
    [self addSubview:self.pokerView3];
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
            [self.pokerView2 rotateToAngle:(M_PI * (1.0/12.0)) animation:animation];
            [self.pokerView3 rotateToAngle:(M_PI * (1.0/6.0)) animation:animation];
            break;
            
        case ZJHPokerSectorTypeLeft:
            [self.pokerView1 rotateToAngle:(-M_PI * (1.0/6.0)) animation:animation];
            [self.pokerView2 rotateToAngle:(-M_PI * (1.0/12.0)) animation:animation];
            break;
            
        case ZJHPokerSectorTypeCenter:
            [self.pokerView1 rotateToAngle:(-M_PI * (1.0/12.0)) animation:animation];
            [self.pokerView3 rotateToAngle:(M_PI * (1.0/12.0)) animation:animation];
            break;
            
        default:
            break;
    }
}

- (void)faceUpCards:(BOOL)animation
{
//    [self.poker1View moveToCenter:CGPointMake(_poker1OriginCenter.x - POKER_X_AXIS_OFFSET, _poker1OriginCenter.y) animation:animation];
    [self.pokerView1 faceUp:animation];
    [self.pokerView1 enableUserInterface];
    
    [self.pokerView2 faceUp:animation];
    [self.pokerView2 enableUserInterface];

//    [self.poker3View moveToCenter:CGPointMake(_poker3OriginCenter.x + POKER_X_AXIS_OFFSET, _poker3OriginCenter.y) animation:animation];
    [self.pokerView3 faceUp:animation];
    [self.pokerView3 enableUserInterface];
}

- (void)faceUpCard:(int)cardId animation:(BOOL)animation
{
    if (self.pokerView1.poker.pokerId == cardId) {
        [self.pokerView1 faceUp:animation];
    }
    
    if (self.pokerView2.poker.pokerId == cardId) {
        [self.pokerView2 faceUp:animation];
    }
    
    if (self.pokerView3.poker.pokerId == cardId) {
        [self.pokerView3 faceUp:animation];
    }
}

- (void)foldCards:(BOOL)animation
{
    self.pokerView1.backImageView.image = [[ZJHImageManager defaultManager] pokerFoldBackImage];
    [self.pokerView1 faceDown:animation];
    [self.pokerView1 backToOriginPosition:animation];
    
    self.pokerView2.backImageView.image = [[ZJHImageManager defaultManager] pokerFoldBackImage];
    [self.pokerView2 faceDown:animation];
    [self.pokerView2 backToOriginPosition:animation];
    
    self.pokerView3.backImageView.image = [[ZJHImageManager defaultManager] pokerFoldBackImage];
    [self.pokerView3 faceDown:animation];
    [self.pokerView3 backToOriginPosition:animation];
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
