//
//  MoneyTreeView.m
//  Draw
//
//  Created by Kira on 12-11-16.
//
//

#import "MoneyTreeView.h"
#import "AnimationManager.h"

@implementation MoneyTreeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)createView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MoneyTreeView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}

+ (MoneyTreeView*)createMoneyTreeView
{
    MoneyTreeView* view = [MoneyTreeView createView];
    view.moneyTree.delegate = view;
    return view;
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
        }
        _timer = nil;
    }
}


- (void)growMoneyTree
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
    [self growMoneyTree];
}
- (void)coinDidRaiseUp:(MoneyTree*)tree
{
    
}
- (void)treeDidMature:(MoneyTree*)tree
{
    [self popupMatureMessage];
}
@end
