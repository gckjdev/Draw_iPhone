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

@property (readwrite, retain, nonatomic) Poker *poker;
@property (readwrite, assign, nonatomic) BOOL isFaceUp;
@property (retain, nonatomic) CMPopTipView *popupView;

@end

@implementation PokerView

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
                      isFaceUp:(BOOL)isFaceUp
{
    PokerView *pokerView = [PokerView createPokerView];
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
//    
//    [self setAcnhorPoint:CGPointMake(0.5, 0.5)];
//    
//    [self moveToCenter:_originCenter animation:animation];
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
    self.popupView.isPopup ? [self.popupView dismissAnimated:YES]: [self popupShowCardButton];
}

+ (id)createShowCardButton
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PokerView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 1){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:1];
}

- (void)popupShowCardButton
{
    UIView *showCardButton = [PokerView createShowCardButton];
    
    self.popupView = [[[CMPopTipView alloc] initWithCustomView:showCardButton needBubblePath:NO] autorelease];
    self.popupView.backgroundColor = [UIColor clearColor];
    
    [self.popupView presentPointingAtView:self
                                   inView:self
                             aboveSubView:self
                                 animated:YES
                           pointDirection:PointDirectionDown];
    
    [self.popupView performSelector:@selector(dismissAnimated:)
                         withObject:[NSNumber numberWithBool:YES]
                         afterDelay:3.0];
    
}

- (void)didClickShowCardButton:(id)sender
{
    PPDebug(@"didClickShowCardButton");
    self.tickImageView.image = [UIImage imageNamed:@""];

    [[ZJHGameService defaultService] showCard:_poker.pokerId];
}

@end
