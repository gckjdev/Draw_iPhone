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
    self.popMessageBody.layer.opacity = 0;
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
            self.popMessageBody.layer.opacity = 0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}


- (void)startGrowing
{
    self.moneyTree.growthTime = self.growthTime;
    self.moneyTree.gainTime = self.gainTime;
    self.moneyTree.coinValue = self.coinValue;
    _remainTime = self.growthTime + self.gainTime*MAX_COINS_ON_TREE;
    
    [self.moneyTree startGrow];
}



- (void)killMoneyTree
{

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
    
    _delegate = nil;
    [_moneyTree release];
    [_popMessageLabel release];
    [_popMessageBackgroundImageView release];
    [_popMessageBody release];
    [super dealloc];
}

- (void)removeFromSuperview
{
    _delegate = nil;
    [super removeFromSuperview];
}

#pragma mark - money tree delegate
- (void)moneyTreeNoCoin:(MoneyTree*)tree
{
    [self popupRemainTimeMessage];
}

- (void)getMoney:(int)money fromTree:(MoneyTree*)tree
{
    [[AudioManager defaultManager] playSoundByURL:[ZJHSoundManager defaultManager].betSoundEffect];
    if (_delegate && [_delegate respondsToSelector:@selector(didGainMoney:fromTree:)]){
        [_delegate didGainMoney:money fromTree:self];
    }
}
- (void)coinDidRaiseUp:(MoneyTree*)tree
{
    
}
- (void)treeDidMature:(MoneyTree*)tree
{

    if (_delegate && [_delegate respondsToSelector:@selector(moneyTreeDidMature:)]) {
        [_delegate moneyTreeDidMature:self];
    }
}

- (void)treeFullCoins:(MoneyTree *)tree
{
    [self popupMatureMessage];
    if (_delegate && [_delegate respondsToSelector:@selector(moneyTreeFullCoins:)]) {
        [_delegate moneyTreeFullCoins:self];
    }
}

- (void)treeUpdateRemainSeconds:(int)seconds toFullCoin:(MoneyTree *)tree
{
    int remainSeconds = seconds-self.gainTime;
    [self.popMessageLabel setText:[NSString stringWithFormat:NSLS(@"kRemainTime"),remainSeconds/60, remainSeconds%60]];
}


@end
