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

@implementation MoneyTreeView

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
    return view;
}

- (void)showInView:(UIView *)view
{
    self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:self];
}

- (void)popupMatureMessage
{
    [self.popMessageLabel setText:[NSString stringWithFormat:NSLS(@"kMatureMessage")]];
    [self popupMessage];
}

- (void)popupNotMatureMessage
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

- (void)update:(id)sender
{
    _remainTime --;
    if (_remainTime <= 0) {
//        [self popupMatureMessage];
        [self killTreeTimer];
        return;
    }
    [self.popMessageLabel setText:[NSString stringWithFormat:NSLS(@"kRemainTimes"),_remainTime/60, _remainTime%60]];
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


- (void)startGrowing
{
    [self killTreeTimer];
    _remainTime = self.growthTime;
    self.moneyTree.growthTime = _remainTime;
    [self.moneyTree startGrow];
    self.popMessageBody.layer.opacity = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    [_timer retain];
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
- (void)moneyTreeNotMature:(MoneyTree*)tree
{
    [self popupNotMatureMessage];
}
- (void)getMoney:(int)money fromTree:(MoneyTree*)tree
{
    [[AudioManager defaultManager] playSoundByURL:[ZJHSoundManager defaultManager].betSoundEffect];
    [self startGrowing];
}
- (void)coinDidRaiseUp:(MoneyTree*)tree
{
    
}
- (void)treeDidMature:(MoneyTree*)tree
{
    [self popupMatureMessage];
}
@end
