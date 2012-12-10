//
//  ZJHPokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-26.
//
//

#import "ZJHPokerView.h"
#import "ZJHImageManager.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimationManager.h"
#import "FXLabel.h"
#import "AnimationManager.h"
#import "ArrowView.h"

#define TAG_BOMB_BUTTON 300
#define CARD_TYPE_LABEL_TAG 200

#define CARD_TYPE_LABEL_HEIGHT ([DeviceDetection isIPAD] ? 25 : 15)
#define CARD_TYPE_STRING_FONT [UIFont boldSystemFontOfSize:([DeviceDetection isIPAD] ? 21 :12)]

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

- (void)dismissButtons
{
    [self.pokerView1 dismissButtons];
    [self.pokerView2 dismissButtons];
    [self.pokerView3 dismissButtons];
}

- (void)clear
{
    for (UIView *view in [self subviews]) {
        [view.layer removeAllAnimations];
        [view removeFromSuperview];
    }
}

#define GAP_RATIO_BETWEEN_CARDS 0.5

- (void)makeSectorShape:(ZJHPokerSectorType)sectorType animation:(BOOL)animation
{
    switch (sectorType) {
        case ZJHPokerSectorTypeRight:
            [self.pokerView2 rotateToAngle:(M_PI * (1.0/12.0))
                                 animation:animation];
            [self.pokerView3 rotateToAngle:(M_PI * (1.0/6.0))
                                 animation:animation];
            break;
            
        case ZJHPokerSectorTypeLeft:
            [self.pokerView2 rotateToAngle:(-M_PI * (1.0/12.0))
                                 animation:animation];
            [self.pokerView1 rotateToAngle:(-M_PI * (1.0/6.0))
                                animation:animation];
            break;
            
        case ZJHPokerSectorTypeCenterUp:
            [self.pokerView1 moveToCenter:CGPointMake(self.pokerView2.center.x - self.pokerView2.frame.size.width, self.pokerView2.center.y) animation:animation];
            [self.pokerView3 moveToCenter:CGPointMake(self.pokerView2.center.x + self.pokerView2.frame.size.width, self.pokerView2.center.y) animation:animation];
            break;
            
        default:
            break;
    }
}

- (void)xMotion:(ZJHPokerXMotionType)xMotiontype animation:(BOOL)animation
{
    switch (xMotiontype) {
        case ZJHPokerXMotionTypeRight:
            [self.pokerView2 moveToCenter:CGPointMake(self.pokerView1.center.x + self.pokerView1.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView1.center.y) animation:animation];
            [self.pokerView3 moveToCenter:CGPointMake(self.pokerView1.center.x + 2 * self.pokerView1.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView1.center.y) animation:animation];
            break;
            
        case ZJHPokerXMotionTypeLeft:
            [self.pokerView2 moveToCenter:CGPointMake(self.pokerView3.center.x - self.pokerView3.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView3.center.y) animation:animation];
            [self.pokerView1 moveToCenter:CGPointMake(self.pokerView3.center.x - 2 * self.pokerView3.frame.size.width * GAP_RATIO_BETWEEN_CARDS, self.pokerView3.center.y) animation:animation];
            break;
            
        case ZJHPokerXMotionTypeCenter:
            [self.pokerView1 moveToCenter:CGPointMake(self.pokerView2.center.x - self.pokerView2.frame.size.width, self.pokerView2.center.y) animation:animation];
            [self.pokerView3 moveToCenter:CGPointMake(self.pokerView2.center.x + self.pokerView2.frame.size.width, self.pokerView2.center.y) animation:animation];
            break;
            
        default:
            break;
    }
}

- (void)faceUpCardsWithCardType:(NSString *)cardType
                    xMotiontype:(ZJHPokerXMotionType)xMotiontype
                      animation:(BOOL)animation
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
    
    if (xMotiontype == ZJHPokerXMotionTypeCenter) {
        [self performSelector:@selector(showCardTypeOnLeft:) withObject:cardType afterDelay:MOVE_ANIMATION_DURATION];
    }else {
        [self performSelector:@selector(showCardTypeOnTop:) withObject:cardType afterDelay:MOVE_ANIMATION_DURATION];
    }
}

- (void)showCardTypeOnTop:(NSString *)cardType
{
    if (![LocaleUtils supportChinese]) {
        return;
    }
    
    CGFloat offsetY = ([DeviceDetection isIPAD] ? -8 : -5);
    CGPoint center = CGPointMake(self.pokerView2.center.x, offsetY - CARD_TYPE_LABEL_HEIGHT/2);
    
    FXLabel *label = [self cardTypeLabelWithCenter:center
                                          cardType:cardType];
    [self addSubview:label];
}

- (void)showCardTypeOnLeft:(NSString *)cardType
{
    if (![LocaleUtils supportChinese]) {
        return;
    }
    CGFloat offsetX = ([DeviceDetection isIPAD] ? 32 : 20);

    CGPoint center = CGPointMake(self.pokerView3.frame.origin.x + self.pokerView3.frame.size.width + offsetX, self.pokerView3.center.y);
    
    FXLabel *label = [self cardTypeLabelWithCenter:center
                                          cardType:cardType];
    [self addSubview:label];
}

- (FXLabel *)cardTypeLabelWithCenter:(CGPoint)center
                            cardType:(NSString *)cardType
{
    FXLabel *label = [[[FXLabel alloc] initWithFrame:CGRectMake(0, 0, self.pokerView2.frame.size.width, CARD_TYPE_LABEL_HEIGHT)] autorelease];
    label.center = center;
    label.backgroundColor = [UIColor clearColor];
    label.font = CARD_TYPE_STRING_FONT;
    
    label.textAlignment = UITextAlignmentCenter;
    
    label.gradientStartColor = [UIColor colorWithRed:254.0/255.0 green:241.0/255.0 blue:67.0/255.0 alpha:1];
    label.gradientEndColor = [UIColor colorWithRed:238.0/255.0 green:159.0/255.0 blue:7.0/255.0 alpha:1];
    label.shadowColor = nil;
    label.shadowOffset = CGSizeMake(0.0f, 2.0f);
    label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    label.shadowBlur = 5.0f;
    
    label.text = cardType;
    label.tag = CARD_TYPE_LABEL_TAG;
    
    [label.layer addAnimation:[AnimationManager appearAnimationFrom:0 to:1 duration:0.5] forKey:nil];
    
    return label;
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

- (void)setShowCardFlag:(int)cardId animation:(BOOL)animation
{
    if (self.pokerView1.poker.pokerId == cardId) {
        [self.pokerView1 setShowCardFlag:animation];
    }
    
    if (self.pokerView2.poker.pokerId == cardId) {
        [self.pokerView2 setShowCardFlag:animation];
    }
    
    if (self.pokerView3.poker.pokerId == cardId) {
        [self.pokerView3 setShowCardFlag:animation];
    }
}

- (void)changeCard:(int)cardId toCard:(Poker *)poker animation:(BOOL)animation
{
    if (self.pokerView1.poker.pokerId == cardId) {
        [self.pokerView1 changeToCard:poker animation:animation];
    }
    
    if (self.pokerView2.poker.pokerId == cardId) {
        [self.pokerView2 changeToCard:poker animation:animation];
    }
    
    if (self.pokerView3.poker.pokerId == cardId) {
        [self.pokerView3 changeToCard:poker animation:animation];
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
    self.pokerView1.backImageView.image = [[ZJHImageManager defaultManager] pokerLoseBackImage];
    [self.pokerView1 faceDown:animation];
    [self.pokerView1 backToOriginPosition:animation];
    
    self.pokerView2.backImageView.image = [[ZJHImageManager defaultManager] pokerLoseBackImage];
    [self.pokerView2 faceDown:animation];
    [self.pokerView2 backToOriginPosition:animation];
    
    self.pokerView3.backImageView.image = [[ZJHImageManager defaultManager] pokerLoseBackImage];
    [self.pokerView3 faceDown:animation];
    [self.pokerView3 backToOriginPosition:animation];
}

- (void)showBomb
{
    [self clearBomb];
    UIButton *bomb = [ArrowView arrowWithCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - ([DeviceDetection isIPAD] ? 10 : 5))];
    bomb.tag = TAG_BOMB_BUTTON;
    [bomb addTarget:self action:@selector(clickBomb:) forControlEvents:UIControlEventTouchUpInside];
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
    [self dismissButtons];
    if ([_delegate respondsToSelector:@selector(didClickShowCardButton:)]) {
        [_delegate didClickShowCardButton:pokerView];
    }
}

- (void)didClickChangeCardButton:(PokerView *)pokerView;
{
    [self dismissButtons];
    if ([_delegate respondsToSelector:@selector(didClickChangeCardButton:)]) {
        [_delegate didClickChangeCardButton:pokerView];
    }
}

- (void)clearBomb
{
    [[self viewWithTag:TAG_BOMB_BUTTON] removeFromSuperview];
}

@end
