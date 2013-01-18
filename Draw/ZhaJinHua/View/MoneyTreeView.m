//
//  MoneyTreeView.m
//  Draw
//
//  Created by Kira on 12-11-16.
//
//

#import "MoneyTreeView.h"
#import "AnimationManager.h"
#import "AudioManager.h"
#import "ZJHSoundManager.h"
#import "AutoCreateViewByXib.h"
#import "ZJHImageManager.h"

@implementation MoneyTreeView
@synthesize moneyTree = _moneyTree;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

AUTO_CREATE_VIEW_BY_XIB(MoneyTreeView)


+ (MoneyTreeView*)createMoneyTreeView
{
    MoneyTreeView* view = [MoneyTreeView createView];
    view.moneyTree.delegate = view;
    [view.popMessageBackgroundImageView setImage:[ZJHImageManager defaultManager].moneyTreePopupMessageBackground];
    return view;
}

- (void)showInView:(UIView *)view
{
    self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    if(self.isAlwaysShowMessage) [self popupRemainTimeMessage];
    [view addSubview:self];
}

- (void)popupMatureMessage
{
    [self.popMessageLabel setText:[NSString stringWithFormat:NSLS(@"kMatureMessage")]];
    [self popupMessage];
}

- (void)popupRemainTimeMessage
{
    [self popupMessage];
}

- (void)popupMessage
{
    self.popMessageBody.layer.opacity = 1;
    [UIView animateWithDuration:4 animations:^{
        self.popMessageBody.layer.opacity = 0.99;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            self.popMessageBody.layer.opacity = self.isAlwaysShowMessage?1:0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)update:(id)sender
{
    _remainTime --;
    if (_remainTime <= 0) {
//        [self popupMatureMessage];
        [self killTreeTimer];
        return;
    }
    [self.popMessageLabel setText:[NSString stringWithFormat:NSLS(@"kRemainTime"),_remainTime/60, _remainTime%60]];
    if (_delegate && [_delegate respondsToSelector:@selector(moneyTreeUpdateRemainSeconds:)]) {
        [_delegate moneyTreeUpdateRemainSeconds:_remainTime];
    }
}

- (void)killTreeTimer
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
            [_timer release];
        }
        _timer = nil;
    }
}

- (void)startTreeTimerWithRemainTime:(CFTimeInterval)remainTime
{
    [self killTreeTimer];
    _remainTime = remainTime;
    self.popMessageBody.layer.opacity = (self.isAlwaysShowMessage)?1:0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    [_timer retain];
}

- (void)startGrowing
{
    self.moneyTree.growthTime = self.growthTime;
    self.moneyTree.gainTime = self.gainTime;
    self.moneyTree.coinValue = self.coinValue;
    _remainTime = self.growthTime + self.gainTime*MAX_COINS_ON_TREE;
    
    [self.moneyTree startGrow];
    [self startTreeTimerWithRemainTime:_remainTime];
}

- (void)startGrowingCoin
{
    if (self.isAlwaysShowMessage) self.popMessageBody.layer.opacity = 1;
    [self startTreeTimerWithRemainTime:self.gainTime*MAX_COINS_ON_TREE];
}

- (void)killMoneyTree
{
    [self killTreeTimer];
    [self.moneyTree kill];
}

- (CFTimeInterval)totalTime
{
    return _growthTime + _gainTime * MAX_COINS_ON_TREE;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    
    [_moneyTree release];
    [_popMessageLabel release];
    [_popMessageBackgroundImageView release];
    [_popMessageBody release];
    [super dealloc];
}

#pragma mark - money tree delegate
- (void)moneyTreeNoCoin:(MoneyTree*)tree
{
    [self popupRemainTimeMessage];
}
- (void)getMoney:(int)money fromTree:(MoneyTree*)tree
{
    [[AudioManager defaultManager] playSoundByURL:[ZJHSoundManager defaultManager].betSoundEffect];
    [self startGrowingCoin];
    if (_delegate && [_delegate respondsToSelector:@selector(didGainMoney:fromTree:)]){
        [_delegate didGainMoney:money fromTree:self];
    }
}
- (void)coinDidRaiseUp:(MoneyTree*)tree
{
    
}
- (void)treeDidMature:(MoneyTree*)tree
{
//    if (self.isAlwaysShowMessage) {
//        self.popMessageBody.layer.opacity = 0;
//    } else {
//        [self popupMatureMessage];
//    }
    if (_delegate && [_delegate respondsToSelector:@selector(moneyTreeDidMature:)]) {
        [_delegate moneyTreeDidMature:self];
    }
}

- (void)treeFullCoins:(MoneyTree *)tree
{
    [self popupRemainTimeMessage];
    if (_delegate && [_delegate respondsToSelector:@selector(moneyTreeFullCoins:)]) {
        [_delegate moneyTreeFullCoins:self];
    }
}


@end
