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

@implementation MoneyTree
@synthesize isMature = _isMature;

- (void)dealloc
{
    [_rewardCoinLabel release];
    [_rewardView release];
    [_rewardCoinView release];
    [_layerQueue release];
    [super dealloc];
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
        [self init];
        
        int pointSize = [DeviceDetection isIPAD]?32:16;
        _rewardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
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
    [coinLayer setBounds:CGRectMake(0, 0, coinImage.size.width, coinImage.size.height)];
    [_layerQueue enqueue:coinLayer];
    return coinLayer;
}

- (void)showOneCoin
{
    [self setImage:[ZJHImageManager defaultManager].bigMoneyTreeImage forState:UIControlStateNormal];
    CALayer* coinLayer = [self coinLayer];
    coinLayer.position = CGPointMake(self.frame.size.width*0.75, self.frame.size.height*0.5);
    [self.layer addSublayer:coinLayer];
    if (_delegate && [_delegate respondsToSelector:@selector(treeDidMature:)]) {
        [_delegate treeDidMature:self];
    }
}

- (void)setIsMature:(BOOL)isMature
{
    _isMature = isMature;
    if (isMature) {
        [self showOneCoin];
    } else {
        while ([_layerQueue peek]) {
            CALayer* layer = [_layerQueue dequeue];
            [layer removeFromSuperlayer];
        }
        [self setImage:[[ZJHImageManager defaultManager] moneyTreeImage] forState:UIControlStateNormal];
    }
}

- (void)killTimer
{
    if (_treeTimer) {
        if ([_treeTimer isValid]) {
            [_treeTimer invalidate];
        }
        _treeTimer = nil;
    }
}

- (void)mature
{
    [self setIsMature:YES];
    [self killTimer];
    [self startMatureTimer:self.growthTime/2];
}

- (void)tooMature
{
    CALayer* coinLayer = [self coinLayer];
    coinLayer.position = CGPointMake(self.frame.size.width*0.25, self.frame.size.height*0.25);
    [self.layer addSublayer:coinLayer];
    if (_delegate && [_delegate respondsToSelector:@selector(treeDidMature:)]) {
        [_delegate treeDidMature:self];
    }
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

- (void)startMatureTimer:(CFTimeInterval)timeInterval
{
    _treeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                  target:self
                                                selector:@selector(tooMature)
                                                userInfo:nil
                                                 repeats:NO];
    [_treeTimer retain];
}

- (void)startGrow
{
    PPDebug(@"<MoneyTree> tree start growth");
    [self killTimer];
    [self setIsMature:NO];
    [self startGrowthTimer:self.growthTime];
    
}

- (void)kill
{
    [self killTimer];
    
}

- (int)calAwardCoinByLevel:(int)level
{
    return level * 50;
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

- (void)clickTree:(id)sender
{
    if (_isMature) {
        self.isMature = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(getMoney:fromTree:)]) {
            [_delegate getMoney:[self calAwardCoinByLevel:[LevelService defaultService].level] fromTree:self];
        }
        [self rewardCoins:[self calAwardCoinByLevel:[LevelService defaultService].level] duration:1];
        
        [self startGrow];

    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(moneyTreeNotMature:)]) {
            [_delegate moneyTreeNotMature:self];
        }
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

@end
