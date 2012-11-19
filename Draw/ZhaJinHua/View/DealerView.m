//
//  DealerView.m
//  Draw
//
//  Created by Kira on 12-11-1.
//
//

#import "DealerView.h"
#import "ZJHImageManager.h"
#import "AnimationManager.h"
#import "ZJHGameController.h"
#import "ZJHPokerView.h"
#import "AudioManager.h"
#import "ZJHSoundManager.h"

#define DEAL_TIMEINTERVAL   0.33
#define DEAL_ANIMATION_DURATION 0.33

@implementation DealPoint
@synthesize x;
@synthesize y;

+ (DealPoint*)pointWithCGPoint:(CGPoint)point
{
    DealPoint* aPoint = [[[DealPoint alloc] init] autorelease];
    aPoint.x = point.x;
    aPoint.y = point.y;
    return aPoint;
}

@end


@interface DealerView ()
@property (readwrite, assign, nonatomic) BOOL isDealing;

@end

@implementation DealerView
@synthesize delegate = _delegate;

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
    self = [super initWithCoder:aDecoder];
    if (self) {
        _dispatcher = [self cardLayer];
        _dispatcher.position = CGPointMake(self.frame.size.width/2, 0);
        [_dispatcher setOpacity:0];
        [self.layer addSublayer:_dispatcher];
    }
    return self;
}

- (void)removeFromSuperview
{
    self.delegate = nil;
    [super removeFromSuperview];
}

- (void)dealloc
{
    [self setDelegate:nil];
    [super dealloc];
}

- (CGFloat)randomAngle
{
    return ((float)(rand()%100)/100);
}

//- (CGPoint)pointByPosition:(UserPosition)position
//{
//    switch (position) {
//        case UserPositionRight:
//            return CGPointMake(self.frame.size.width, self.frame.size.height*0.75);
//        case UserPositionRightTop:
//            return CGPointMake(self.frame.size.width, self.frame.size.height*0.25);
//        case UserPositionLeft:
//            return CGPointMake(0, self.frame.size.height*0.75);
//        case UserPositionLeftTop:
//            return CGPointMake(0, self.frame.size.height*0.25);
//        case UserPositionCenter:
//            return CGPointMake(self.frame.size.width/2, self.frame.size.height);
//        default:
//            return CGPointMake(self.frame.size.width/2, 0);
//            break;
//    };
//}

- (CALayer*)cardLayer
{
    CALayer* layer= [CALayer layer];
    UIImage* back = [[ZJHImageManager defaultManager] pokerBackImage];
    layer.contents = (id)[back CGImage];
    layer.bounds = CGRectMake(0, 0, SMALL_POKER_VIEW_WIDTH, SMALL_POKER_VIEW_HEIGHT);
    return layer;
}

- (void)dealCard:(id)point
{
    [[AudioManager defaultManager] playSoundByURL:[ZJHSoundManager defaultManager].dealCard];
    
    CGPoint destinationPoint = CGPointMake(((DealPoint*)point).x, ((DealPoint*)point).y);
    CALayer* layer= [self cardLayer];
//    layer.shouldRasterize = YES;
    layer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self.layer addSublayer:layer];

    CAAnimation* anim = [AnimationManager translationAnimationFrom:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) to:destinationPoint duration:DEAL_ANIMATION_DURATION delegate:self removeCompeleted:NO];
    float angle = [self randomAngle];
    CAAnimation* anim2 = [AnimationManager rotateAnimationWithRoundCount:angle duration:DEAL_ANIMATION_DURATION];
    
    anim2.removedOnCompletion = NO;
    //        PPDebug(@"deal to point (%.2f, %.2f)",points[i].x, points[i].y );
//    PPDebug(@" <test> remain cards = %d", _remainCards);
    if (_remainCards == 1) {
        
        [CATransaction setCompletionBlock:^{
            if (_delegate && [_delegate respondsToSelector:@selector(didDealFinish:)]) {
                _isDealing = NO;
                [self dispatchDisappear];
                [_delegate didDealFinish:self];
            }
//            PPDebug(@"<test> deal finish!");
        }];
    }
    
    [layer addAnimation:anim forKey:nil];
    [layer addAnimation:anim2 forKey:nil];
    
    _remainCards--;
}

- (void)dispatchAppear:(NSArray*)array times:(int)times
{
    _dispatcher.opacity = 1;
    CAAnimation* appear = [AnimationManager translationAnimationFrom:CGPointMake(self.frame.size.width/2, 0) to:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) duration:1 delegate:self removeCompeleted:NO];
    [CATransaction setCompletionBlock:^{
        [self startDeal:array times:times];
    }];
    [_dispatcher addAnimation:appear forKey:nil];
}

- (void)dispatchDisappear
{
    CAAnimation* disappear = [AnimationManager translationAnimationFrom:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) to:CGPointMake(self.frame.size.width/2, 0) duration:1 delegate:self removeCompeleted:NO];
    [CATransaction setCompletionBlock:^{
        [_dispatcher setOpacity:0];
        for (CALayer* layer in [self.layer sublayers]) {
            [layer setOpacity:0];
        }
    }];
    [_dispatcher addAnimation:disappear forKey:nil];
    
}

- (void)startDeal:(NSArray*)array times:(int)times
{
    _isDealing = YES;
    float delay = 0;
    _remainCards = times * [array count];
    while (times --) {
        for (DealPoint* point in array) {
            [self performSelector:@selector(dealCard:) withObject:point afterDelay:delay];
            delay = delay + DEAL_TIMEINTERVAL;
            
        }
    }
}

- (void)dealWithPositionArray:(NSArray*)array
                        times:(int)times
{
    [self dispatchAppear:array times:times];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
