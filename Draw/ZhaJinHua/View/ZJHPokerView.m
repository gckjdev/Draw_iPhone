//
//  ZJHPokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-26.
//
//

#import "ZJHPokerView.h"
#import "ZJHImageManager.h"

#define TAG_BOMB_BUTTON 300

#define BOMB_BUTTON_WIDTH 30
#define BOMB_BUTTON_HEIGHT 30

@interface ZJHPokerView ()
{
//    CGPoint _poker1OriginCenter;
//    CGPoint _poker2OriginCenter;
//    CGPoint _poker3OriginCenter;
}

@end

@implementation ZJHPokerView
@synthesize pokerView1 = _pokerView1;
@synthesize pokerView2 = _pokerView2;
@synthesize pokerView3 = _pokerView3;

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
                     gap:(CGFloat)gap;
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
                                                 delegate:self];
    
    pokerViewOffset = self.pokerView1.frame.origin.x + gap;
    frame = CGRectMake(pokerViewOffset, 0, size.width, size.height);
    self.pokerView2 = [PokerView createPokerViewWithPoker:poker2
                                                    frame:frame
                                                 delegate:self];

    
    pokerViewOffset = self.pokerView2.frame.origin.x + gap;
    frame = CGRectMake(pokerViewOffset, 0, size.width, size.height);
    self.pokerView3 = [PokerView createPokerViewWithPoker:poker3
                                                    frame:frame
                                                 delegate:self];
    
//    // save original center
//    _poker1OriginCenter = self.poker1View.center;
//    _poker2OriginCenter = self.poker2View.center;
//    _poker3OriginCenter = self.poker3View.center;
    
    // add poker views
    [self addSubview:self.pokerView1];
    [self addSubview:self.pokerView2];
    [self addSubview:self.pokerView3];
}

- (void)dismissShowCardButtons
{
    [self.pokerView1 dismissShowCardButton];
    [self.pokerView2 dismissShowCardButton];
    [self.pokerView3 dismissShowCardButton];
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
            [self.pokerView2 rotateToAngle:(-M_PI * (1.0/12.0)) animation:animation];
            [self.pokerView1 rotateToAngle:(-M_PI * (1.0/6.0)) animation:animation];
            break;
            
        case ZJHPokerSectorTypeCenter:
            [self.pokerView1 rotateToAngle:(-M_PI * (1.0/12.0)) animation:animation];
            [self.pokerView3 rotateToAngle:(M_PI * (1.0/12.0)) animation:animation];
            break;
            
        default:
            break;
    }
}

#define GAP_RATIO_BETWEEN_CARDS 0.5
- (void)xMotion:(ZJHPokerXMotionType)xMotiontype animation:(BOOL)animation
{
    switch (xMotiontype) {
        case ZJHPokerXMotionTypeRight:
            [self.pokerView2 moveToCenter:CGPointMake(self.pokerView1.center.x + self.pokerView1.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView1.center.y) animation:animation];
            [self.pokerView3 moveToCenter:CGPointMake(self.pokerView1.center.x + 2 * self.pokerView1.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView1.center.y) animation:animation];
            break;
            
        case ZJHPokerSectorTypeLeft:
            [self.pokerView2 moveToCenter:CGPointMake(self.pokerView3.center.x - self.pokerView3.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView3.center.y) animation:animation];
            [self.pokerView1 moveToCenter:CGPointMake(self.pokerView3.center.x - 2 * self.pokerView3.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView3.center.y) animation:animation];
            break;
            
        case ZJHPokerSectorTypeCenter:
            [self.pokerView1 moveToCenter:CGPointMake(self.pokerView2.center.x - self.pokerView2.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView2.center.y) animation:animation];
            [self.pokerView3 moveToCenter:CGPointMake(self.pokerView2.center.x + self.pokerView2.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView2.center.y) animation:animation];
            break;
            
        default:
            break;
    }
}

- (void)faceUpCards:(ZJHPokerXMotionType)xMotiontype animation:(BOOL)animation
{
    [self clearBomb];

    [self.pokerView1 backToOriginPosition:animation];
    [self.pokerView1 faceUp:animation];
    [self.pokerView1 enableUserInterface];
    
    [self.pokerView2 backToOriginPosition:animation];
    [self.pokerView2 faceUp:animation];
    [self.pokerView2 enableUserInterface];

    [self.pokerView3 backToOriginPosition:animation];
    [self.pokerView3 faceUp:animation];
    [self.pokerView3 enableUserInterface];
    
    [self xMotion:xMotiontype animation:animation];
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
    [self clearBomb];
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

- (void)winCards:(BOOL)animation
{
}

- (void)loseCards:(BOOL)animation
{
}

- (void)showBomb
{
    [self clearBomb];
    
    UIButton *bomb = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, BOMB_BUTTON_WIDTH, BOMB_BUTTON_HEIGHT)] autorelease];
    bomb.tag = TAG_BOMB_BUTTON;
    [bomb setImage:[[ZJHImageManager defaultManager] bombImage] forState:UIControlStateNormal];
    [bomb addTarget:self action:@selector(clickBomb:) forControlEvents:UIControlEventTouchUpInside];
    bomb.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:bomb];
}

#pragma mark - bomb button action.

- (void)clickBomb:(id)sender
{
    [self clearBomb];
    
    if ([_delegate respondsToSelector:@selector(didClickBombButton:)]) {
        [_delegate didClickBombButton:self];
    }
}

#pragma mark - delegate methods.

- (void)didClickPokerView:(PokerView *)pokerView
{
    if ([_delegate respondsToSelector:@selector(didClickPokerView:)]) {
        [_delegate didClickPokerView:pokerView];
    }
}

- (void)didClickShowCardButton:(PokerView *)pokerView
{
    if ([_delegate respondsToSelector:@selector(didClickShowCardButton:)]) {
        [_delegate didClickShowCardButton:pokerView];
    }
}

- (void)clearBomb
{
    [[self viewWithTag:TAG_BOMB_BUTTON] removeFromSuperview];
}

@end
