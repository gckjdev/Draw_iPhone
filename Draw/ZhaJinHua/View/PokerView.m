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

#define POKER_VIEW_ROTATE_ANCHOR_POINT CGPointMake(0, 0)


#define FACEUP_ANIMATION_DURATION 0.75
#define FACEDOWN_ANIMATION_DURATION 0.75

#define ROTATE_ANIMATION_DURATION 1
#define MOVE_ANIMATION_DURATION 1

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
@synthesize locateLabel = _locateLabel;
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
    [_locateLabel release];
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

- (void)setAcnhorPoint:(CGPoint)anchorPoint
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

    [self setAcnhorPoint:CGPointMake(0.5, 1)];
    
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
        [self setAcnhorPoint:CGPointMake(0.5, 0.5)];
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

- (void)dismissShowCardButton
{
    [self.popupView dismissAnimated:YES];
}

#define SHOW_CARD_VIEW_WIDTH ([DeviceDetection isIPAD] ? 72 : 43)
#define SHOW_CARD_VIEW__HEIGHT ([DeviceDetection isIPAD] ? 60 : 36)

#define SHOW_CARD_BUTTON_X_OFFSET ([DeviceDetection isIPAD] ? 6 : 4)
#define SHOW_CARD_BUTTON_Y_OFFSET ([DeviceDetection isIPAD] ? 6 : 4)

#define SHOW_CARD_BUTTON_WIDTH ([DeviceDetection isIPAD] ? 56 : 35)
#define SHOW_CARD_BUTTON_HEIGHT ([DeviceDetection isIPAD] ? 40 : 25)

#define SHOW_CARD_BUTTON_FONT ([DeviceDetection isIPAD] ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:13])

- (UIView *)createShowCardButton
{

    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SHOW_CARD_VIEW_WIDTH, SHOW_CARD_VIEW__HEIGHT)] autorelease];
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:view.bounds] autorelease];
    imageView.image = [[ZJHImageManager defaultManager] showCardButtonBgImage];
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(SHOW_CARD_BUTTON_X_OFFSET, SHOW_CARD_BUTTON_Y_OFFSET, SHOW_CARD_BUTTON_WIDTH, SHOW_CARD_BUTTON_HEIGHT)] autorelease];
    [button.titleLabel setFont:SHOW_CARD_BUTTON_FONT];
    [button setTitle:@"亮牌" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickShowCardButton:) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:imageView];
    [view addSubview:button];
    
    return view;
}

- (void)popupShowCardButtonInView:(UIView *)inView
                        aboveView:(UIView *)aboveView
{
    UIView *showCardButton = [self createShowCardButton];
    
    self.popupView = [[[CMPopTipView alloc] initWithCustomView:showCardButton needBubblePath:NO] autorelease];
    self.popupView.backgroundColor = [UIColor clearColor];
    
    [self.popupView presentPointingAtView:self.locateLabel
                                   inView:inView
                                aboveView:aboveView
                                 animated:YES
                           pointDirection:PointDirectionDown];
    
    [self.popupView performSelector:@selector(dismissAnimated:)
                         withObject:[NSNumber numberWithBool:YES]
                         afterDelay:3.0];
    
}

- (BOOL)showCardButtonIsPopup
{
    return self.popupView.isPopup;
}

- (void)clickShowCardButton:(id)sender
{
    PPDebug(@"didClickShowCardButton");
    [self dismissShowCardButton];
    self.tickImageView.image = [UIImage imageNamed:@""];
    if ([self.delegate respondsToSelector:@selector(didClickShowCardButton:)]) {
        [self.delegate didClickShowCardButton:self];
    }
}    

@end
