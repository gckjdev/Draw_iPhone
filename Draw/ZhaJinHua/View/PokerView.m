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
                      isFaceUp:(BOOL)isFaceUp                      delegate:(id<PokerViewProtocol>)delegate
{
    PokerView *pokerView = [PokerView createPokerView];
    pokerView.delegate = delegate;

    pokerView.backgroundColor = [UIColor clearColor];
    pokerView.frame = frame;
    [pokerView setOriginInfo];
    
    pokerView.poker = poker;
    pokerView.isFaceUp = isFaceUp;
    
    pokerView.backImageView.image = [[ZJHImageManager defaultManager] pokerBackImage];
    
    pokerView.frontBgImageView.image = [[ZJHImageManager defaultManager] pokerFrontBgImage];
    pokerView.rankImageView.image = [[ZJHImageManager defaultManager] pokerRankImage:poker];
    pokerView.suitImageView.image = [[ZJHImageManager defaultManager] pokerSuitImage:poker];
    pokerView.bodyImageView.image = [[ZJHImageManager defaultManager] pokerBodyImage:poker];
    
    pokerView.backImageView.hidden = isFaceUp;
    pokerView.frontView.hidden = !isFaceUp;
    
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
    if (_isFaceUp) {
        _isFaceUp = NO;
        
        self.backImageView.hidden = NO;
        self.frontView.hidden = YES;
        
        if (!animation) {
            return;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.75];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:self cache:YES];
        [UIView commitAnimations];
    }
}

- (void)faceUp:(BOOL)animation
{
    if (!_isFaceUp) {
        _isFaceUp = YES;
        
        self.backImageView.hidden = YES;
        self.frontView.hidden = NO;
        
        if (!animation) {
            return;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.75];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:self cache:YES];
        [UIView commitAnimations];
    }
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
    
    CFTimeInterval duration = animation ? 1 : 0;
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
}

- (void)moveToCenter:(CGPoint)center animation:(BOOL)animation
{
    if (self.center.x == center.x && self.center.y == center.y) {
        return;
    }
    
    if (animation) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1];
        self.center = center;
        [UIView commitAnimations];
    }else{
        self.center = center;
    }
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

- (UIView *)createShowCardButton:(BOOL)enabled
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 43, 36)] autorelease];
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:view.bounds] autorelease];
    imageView.image = enabled ? [[ZJHImageManager defaultManager] showCardButtonBgImage] : [[ZJHImageManager defaultManager] showCardButtonDisableBgImage];
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(4, 4, 35, 25)] autorelease];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [button setTitle:@"亮牌" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (enabled) {
        [button addTarget:self action:@selector(clickShowCardButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [view addSubview:imageView];
    [view addSubview:button];
    
    return view;
}

- (void)popupShowCardButtonInView:(UIView *)inView
                        aboveView:(UIView *)aboveView
                          enabled:(BOOL)enabled
{
    UIView *showCardButton = [self createShowCardButton:enabled];
    
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
