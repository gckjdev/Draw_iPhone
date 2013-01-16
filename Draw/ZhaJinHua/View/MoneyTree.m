//
//  MoneyTree.m
//  Draw
//
//  Created by Kira on 12-11-5.
//
//

#import "MoneyTree.h"
#import "ConfigManager.h"
#import "ZJHImageManager.h"
#import "ShareImageManager.h"
#import "LevelService.h"
#import "AnimationManager.h"
#import "NSMutableArray+Queue.h"

#define EARN_COIN_EACH_LEVEL (50)
#define COIN_RADIUS ([DeviceDetection isIPAD]?28:14)

@implementation MoneyTree
@synthesize isMature = _isMature;

- (void)dealloc
{
    _delegate = nil;
    [self killTimer];
    [_rewardCoinLabel release];
    [_rewardView release];
    [_rewardCoinView release];
    [_layerQueue release];
    [super dealloc];
}

- (void)removeFromSuperview
{
    [self killTimer];
    self.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self addTarget:self action:@selector(clickTree:) forControlEvents:UIControlEventTouchUpInside];
        _layerQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addTarget:self action:@selector(clickTree:) forControlEvents:UIControlEventTouchUpInside];
        _layerQueue = [[NSMutableArray alloc] init];
        
        int pointSize = [DeviceDetection isIPAD]?26:13;
        _rewardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/4)];
        _rewardCoinView = [[UIImageView alloc] initWithImage:[ShareImageManager defaultManager].rewardCoin];
        [_rewardCoinView setFrame:CGRectMake(_rewardView.frame.size.width/2-_rewardView.frame.size.height, 0, _rewardView.frame.size.height, _rewardView.frame.size.height)];
        _rewardCoinLabel = [[UILabel alloc] initWithFrame:CGRectMake(_rewardView.frame.size.width/2, 0, _rewardView.frame.size.width, _rewardView.frame.size.height)];
        [_rewardCoinLabel setFont:[UIFont systemFontOfSize:pointSize]];
        [_rewardCoinLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_rewardCoinLabel setBackgroundColor:[UIColor clearColor]];
        [_rewardCoinLabel setTextColor:[UIColor yellowColor]];
        //[_rewardCoinLabel setTextAlignment:UITextAlignmentCenter];
        [_rewardView addSubview:_rewardCoinView];
        [_rewardView addSubview:_rewardCoinLabel];
        _rewardView.hidden = YES;
        [self addSubview:_rewardView];
    }
    return self;
}

- (CALayer*)coinLayer
{
    CALayer* coinLayer = [CALayer layer];
    UIImage* coinImage = [ZJHImageManager defaultManager].moneyTreeCoinImage;
    coinLayer.contents = (id)[coinImage CGImage];
    [coinLayer setBounds:CGRectMake(0, 0, COIN_RADIUS, COIN_RADIUS)];
    [_layerQueue enqueue:coinLayer];
    return coinLayer;
}

- (CALayer*)shiningLightLayer
{
    CALayer* layer = [CALayer layer];
    UIImage* layerImage = [ZJHImageManager defaultManager].moneyTreeCoinLightImage;
    layer.contents = (id)[layerImage CGImage];
    [layer setBounds:CGRectMake(0, 0, COIN_RADIUS, COIN_RADIUS)];
//    [_layerQueue enqueue:layer];
    return layer;
}

- (void)showOneCoin
{
    self.coinsOnTree ++;
    CGPoint coinPos = CGPointMake(self.frame.size.width*0.75, self.frame.size.height/2);
    [self addCoinAtPosition:coinPos];
    [self killTimer];
    [self startGrowCoinTimer:self.gainTime selector:@selector(showTwoCoin)];
}

- (void)showTwoCoin
{
    self.coinsOnTree ++;
    [self addCoinAtPosition:CGPointMake(self.frame.size.width*0.35, self.frame.size.height/4)];
    if (_delegate && [_delegate respondsToSelector:@selector(treeFullCoins:)]) {
        [_delegate treeFullCoins:self];
    }
}

- (void)setIsMature:(BOOL)isMature
{
    _isMature = isMature;
    if (isMature) {
        [self setBackgroundImage:[ZJHImageManager defaultManager].bigMoneyTreeImage forState:UIControlStateNormal];
        if (_delegate && [_delegate respondsToSelector:@selector(treeDidMature:)]) {
            [_delegate treeDidMature:self];
        }
    } else {
        
        [self setBackgroundImage:[[ZJHImageManager defaultManager] moneyTreeImage] forState:UIControlStateNormal];
        
    }
}

- (void)killTimer
{
    if (_treeTimer) {
        if ([_treeTimer isValid]) {
            [_treeTimer invalidate];
            [_treeTimer release];
        }
        _treeTimer = nil;
    }
}

- (void)mature
{
    PPDebug(@"<MoneyTree> Money tree is mature ,now start to grow coin");
    [self setIsMature:YES];
    [self startGrowCoin];
}

- (void)addCoinAtPosition:(CGPoint)position
{
    CALayer* coinLayer = [self coinLayer];
    coinLayer.position = position;
    [self.layer addSublayer:coinLayer];
    
    CAAnimation* coinGrowAnim = [AnimationManager scaleAnimationWithFromScale:0.01 toScale:1.1 duration:1 delegate:self removeCompeleted:YES];
    [CATransaction setCompletionBlock:^{
        CALayer* lightLayer = [self shiningLightLayer];
        lightLayer.position = CGPointMake(coinLayer.bounds.size.width*0.75, coinLayer.bounds.size.width*0.75);
        [coinLayer addSublayer:lightLayer];
        
        CAAnimation* shining = [AnimationManager disappearAnimationWithDuration:1];
        shining.autoreverses = YES;
        shining.repeatCount = 1000;
        [lightLayer addAnimation:shining forKey:nil];
    }];
    [coinLayer addAnimation:coinGrowAnim forKey:nil];
}



- (void)startGrowthTimer:(CFTimeInterval)timeInterval
{
    _treeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                  target:self
                                                selector:@selector(mature)
                                                userInfo:nil
                                                 repeats:NO];
    [_treeTimer retain];
}

//- (void)startMatureTimer:(CFTimeInterval)timeInterval
//{
//    _treeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
//                                                  target:self
//                                                selector:@selector(tooMature)
//                                                userInfo:nil
//                                                 repeats:NO];
//    [_treeTimer retain];
//}

- (void)startGrowCoinTimer:(CFTimeInterval)timeInterval
                  selector:(SEL)aSelector
{
    _treeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                  target:self
                                                selector:aSelector
                                                userInfo:nil
                                                 repeats:NO];
    [_treeTimer retain];
}

- (void)startGrow
{
    PPDebug(@"<MoneyTree> tree start grow up");
    [self killTimer];
    [self setIsMature:NO];
    [self startGrowthTimer:self.growthTime];
    
}

- (void)startGrowCoin
{
    PPDebug(@"<MoneyTree> tree start grow coin");
    [self killTimer];
    [self startGrowCoinTimer:self.gainTime selector:@selector(showOneCoin)];
}


- (void)kill
{
    [self killTimer];
    
}

- (void)rewardCoins:(int)coinsCount
           duration:(float)duration
{
    
    [_rewardCoinLabel setText:[NSString stringWithFormat:@"%+d",coinsCount]];
    _rewardView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height + _rewardView.frame.size.height);
    _rewardView.alpha = 1;
    _rewardView.hidden = NO;
    [UIView animateWithDuration: duration
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         _rewardView.center = CGPointMake(self.frame.size.width/2                                                            , -1*_rewardView.frame.size.height);
                     }
                     completion: ^(BOOL finished){
                         if (_delegate && [_delegate respondsToSelector:@selector(coinDidRaiseUp:)]) {
                             [_delegate coinDidRaiseUp:self];
                         }
                         //PPDebug(@"raise finish");
                         //code that runs when this animation finishes
                     }
     ];
    
    [UIView animateWithDuration: duration
                          delay: duration
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         //view2.center = CGPointMake(x2, y2);
                         _rewardView.alpha = 0;
                     }
                     completion: ^(BOOL finished){
                         //PPDebug(@"dismiss finish");
                         _rewardView.hidden = YES;
                         //code that runs when this animation finishes
                     }
     ];
    
    
}

//- (void)showCoinsDrops
//{
//    CALayer* leftCoin = [self coinLayer];
//    CALayer* rightCoin = [self coinLayer];
//    [self.layer addSublayer:leftCoin];
//    [self.layer addSublayer:rightCoin];
//    CAAnimation* leftDropAnim = [AnimationManager bezierCurveStart:CGPointMake(self.frame.size.width*0.3, self.frame.size.height*0.25) controlPoint1:CGPointMake(self.frame.size.width/2, 0) controlPoint2:CGPointMake(self.frame.size.width/2, 0) endPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height) duration:1 delegate:nil];
//     CAAnimation* rightDropAnim = [AnimationManager bezierCurveStart:CGPointMake(self.frame.size.width*0.75, self.frame.size.height/2) controlPoint1:CGPointMake(self.frame.size.width/2, 0) controlPoint2:CGPointMake(self.frame.size.width/2, 0) endPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height) duration:1 delegate:nil];
//    [leftCoin addAnimation:leftDropAnim forKey:nil];
//    [rightCoin addAnimation:rightDropAnim forKey:nil];
//    
//}

- (void)clickTree:(id)sender
{
    if (self.coinsOnTree > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(getMoney:fromTree:)]) {
            [_delegate getMoney:(_coinValue * _coinsOnTree) fromTree:self];
        }
        [self rewardCoins:(self.coinValue * _coinsOnTree) duration:1];
//        [self showCoinsDrops];
        [self gain];
        [self startGrowCoin];

    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(moneyTreeNotMature:)]) {
            [_delegate moneyTreeNotMature:self];
        }
    }
}

- (void)gain
{
    _coinsOnTree = 0;
    while ([_layerQueue peek]) {
        CALayer* layer = [_layerQueue dequeue];
        CAAnimation* dropAnim = [AnimationManager bezierCurveStart:layer.position controlPoint1:CGPointMake(self.frame.size.width/2, 0) controlPoint2:CGPointMake(self.frame.size.width/2, 0) endPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height) duration:1 delegate:self];
        [CATransaction setCompletionBlock:^{
            [layer removeFromSuperlayer];
        }];
        [layer addAnimation:dropAnim forKey:nil];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)moneyTreeNotMature:(MoneyTree*)tree;
{
    
}

- (void)getMoney:(int)money fromTree:(MoneyTree*)tree
{
    
}

- (void)coinDidRaiseUp:(MoneyTree*)tree
{
    
}

- (void)treeDidMature:(MoneyTree*)tree
{
    
}


@end
