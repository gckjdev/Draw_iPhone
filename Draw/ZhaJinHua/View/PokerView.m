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
#import <QuartzCore/QuartzCore.h>
#import "CMPopTipView.h"
#import "AnimationManager.h"
#import "ArrowView.h"
#import "ZJHRuleConfigFactory.h"

#define POKER_VIEW_ROTATE_ANCHOR_POINT CGPointMake(0, 0)
#define SHOW_CARD_FLAG_IMAGE_TAG 308

#define ARROW_TAG 444

#define CARD_LIGHT_WIDTH ([DeviceDetection isIPAD] ? 100 : 50)
#define CARD_LIGHT_HEIGHT ([DeviceDetection isIPAD] ? 126 : 63)


@interface PokerView ()
{
    CGPoint _originCenter;
    CGFloat _angle;
}

@property (readwrite, assign, nonatomic) id<PokerViewProtocol> delegate;
@property (readwrite, retain, nonatomic) Poker *poker;
@property (readwrite, assign, nonatomic) BOOL isFaceUp;
@property (retain, nonatomic) CMPopTipView *popupView;

@end

@implementation PokerView
@synthesize poker = _poker;
@synthesize backImageView = _backImageView;
@synthesize frontView = _frontView;
@synthesize rankImageView = _rankImageView;
@synthesize suitImageView = _suitImageView;
@synthesize frontBgImageView = _frontBgImageView;
@synthesize tickImageView = _tickImageView;
@synthesize bodyImageView = _bodyImageView;
@synthesize popupView = _popupView;
@synthesize isFaceUp = _isFaceUp;
@synthesize delegate = _delegate;

#pragma mark - life cycle

- (void)dealloc {
    [_poker release];
    [_backImageView release];
    [_frontView release];
    [_rankImageView release];
    [_suitImageView release];
    [_frontBgImageView release];
    [_tickImageView release];
    [_bodyImageView release];
    [_popupView release];
    [super dealloc];
}


+ (id)createPokerViewWithPoker:(Poker *)poker
                         frame:(CGRect)frame
                      delegate:(id<PokerViewProtocol>)delegate
{
    PokerView *pokerView = [PokerView createPokerView];
    pokerView.delegate = delegate;

    pokerView.backgroundColor = [UIColor clearColor];
    pokerView.frame = frame;
    [pokerView setOriginInfo];
    
    pokerView.poker = poker;
    pokerView.isFaceUp = poker.faceUp;
    
    pokerView.backImageView.image = [[ZJHImageManager defaultManager] pokerBackImage];
    
    pokerView.frontBgImageView.image = [[ZJHImageManager defaultManager] pokerFrontBgImage];
    pokerView.rankImageView.image = [[ZJHImageManager defaultManager] pokerRankImage:poker];
    pokerView.suitImageView.image = [[ZJHImageManager defaultManager] pokerSuitImage:poker];
    pokerView.bodyImageView.image = [[ZJHImageManager defaultManager] pokerBodyImage:poker];
    
    pokerView.backImageView.hidden = poker.faceUp;
    pokerView.frontView.hidden = !poker.faceUp;
    
    return pokerView;
}

#pragma mark - public methods

- (void)enableUserInterface
{
    [self.frontView addTarget:self
                       action:@selector(clickSelf:)
             forControlEvents:UIControlEventTouchUpInside];
}

- (void)faceDown:(BOOL)animation
{
    if (!_isFaceUp) {
        return;
    }
    _isFaceUp = NO;
    
    self.backImageView.hidden = NO;
    self.frontView.hidden = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:(animation ? FACEDOWN_ANIMATION_DURATION : 0)];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self cache:YES];
    [UIView commitAnimations];
    
    return;
}

- (void)faceUp:(BOOL)animation
{
    if (_isFaceUp) {
        return;
    }
    
    _isFaceUp = YES;
    
    self.backImageView.hidden = YES;
    self.frontView.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:(animation ? FACEUP_ANIMATION_DURATION : 0)];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:self cache:YES];
    [UIView commitAnimations];
    
    return;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint oldAnchorPoint = self.layer.anchorPoint;
    CGPoint newAnchorPoint = anchorPoint;
    CGPoint oldPosition = self.layer.position;
    
    self.layer.anchorPoint = newAnchorPoint;
    CGFloat px = oldPosition.x + (newAnchorPoint.x - oldAnchorPoint.x) * self.frame.size.width;
    CGFloat py = oldPosition.y + (newAnchorPoint.y - oldAnchorPoint.y) * self.frame.size.height;
    self.layer.position = CGPointMake(px, py);
}

- (void)rotateToAngle:(CGFloat)angle
            animation:(BOOL)animation
{
    // TODO: rotate self
    if (_angle == angle) {
        return;
    }

    [self setAnchorPoint:CGPointMake(0.5, 1)];
    
    CFTimeInterval duration = animation ? ROTATE_ANIMATION_DURATION : 0;
    CABasicAnimation * rotation = [CABasicAnimation       animationWithKeyPath:@"transform.rotation.z"];
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rotation.fromValue = [NSNumber numberWithFloat:_angle];
    rotation.toValue = [NSNumber numberWithFloat:angle];
    rotation.duration = duration ;
    [self.layer addAnimation:rotation forKey:nil];

    [self.layer setTransform:CATransform3DMakeRotation(angle, 0, 0, 1)];
        
    _angle = angle;
    
    if (angle == 0) {
        [self setAnchorPoint:CGPointMake(0.5, 0.5)];
    }
    
    return;
}

- (void)moveToCenter:(CGPoint)center animation:(BOOL)animation
{
    if (self.center.x == center.x && self.center.y == center.y) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:(animation ? MOVE_ANIMATION_DURATION : 0)];
    self.center = center;
    [UIView commitAnimations];

    return;
}

- (void)backToOriginPosition:(BOOL)animation
{
    [self rotateToAngle:0
              animation:animation];
    [self moveToCenter:_originCenter animation:animation];
}

#pragma mark - pravite methods

+ (id)createPokerView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PokerView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}



- (void)setOriginInfo
{
    _angle = 0;
    _originCenter = self.center;
}


#pragma mark - click action
- (void)clickSelf:(id)sender
{
    PPDebug(@"clickSelf");
    
    if ([self.delegate respondsToSelector:@selector(didClickPokerView:)]) {
        [self.delegate didClickPokerView:self];
    }
}

- (void)dismissButtons
{
    [self.popupView dismissAnimated:YES];
}

- (void)popupButtons:(UIView *)buttons InView:(UIView *)inView
{
    self.popupView = [[[CMPopTipView alloc] initWithCustomViewWithoutBubble:buttons] autorelease];
    self.popupView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    
    [self.popupView presentPointingAtView:self
                                   inView:inView
                                 animated:YES
                           pointDirection:PointDirectionDown];
    
    [self performSelector:@selector(dismissButtons)
               withObject:nil
               afterDelay:3.0];
}

- (BOOL)buttonsIsPopup
{
    return self.popupView.isPopup;
}

- (void)setShowCardFlag:(BOOL)animation
{
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CARD_LIGHT_WIDTH, CARD_LIGHT_HEIGHT)] autorelease];
    imageView.image = [[ZJHImageManager defaultManager] showCardFlagImage];
    imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:imageView];
    
    [imageView.layer addAnimation:[AnimationManager appearAnimationFrom:0.5 to:1 duration:(animation ? 0.8 : 0)] forKey:nil];
}

- (void)changeToCard:(Poker *)poker
{
    self.poker = poker;
    
    self.rankImageView.image = [[ZJHImageManager defaultManager] pokerRankImage:poker];
    self.suitImageView.image = [[ZJHImageManager defaultManager] pokerSuitImage:poker];
    self.bodyImageView.image = [[ZJHImageManager defaultManager] pokerBodyImage:poker];
}

- (void)changeToCard:(Poker *)poker animation:(BOOL)animation
{

    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self changeToCard:poker];
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)clickShowCardButton:(id)sender
{
    if ([_delegate respondsToSelector:@selector(didClickShowCardButton:)]) {
        [_delegate didClickShowCardButton:self];
    }
}

- (void)clickChangeCardButton:(id)sender
{
    [self dismissButtons];
    if ([_delegate respondsToSelector:@selector(didClickChangeCardButton:)]) {
        [_delegate didClickChangeCardButton:self];
    }
}


@end
