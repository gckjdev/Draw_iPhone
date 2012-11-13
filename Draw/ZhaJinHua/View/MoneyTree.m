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

@implementation MoneyTree
@synthesize isMature = _isMature;

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
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addTarget:self action:@selector(clickTree:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setIsMature:(BOOL)isMature
{
    _isMature = isMature;
    if (isMature) {
        //TODO: here set button image a coin
        
        [self setImage:[[ShareImageManager defaultManager] coinImage] forState:UIControlStateNormal];
    } else {
        //TODO: here set button image a tree
        [self setImage:[[ZJHImageManager defaultManager] moneyTreeImage] forState:UIControlStateNormal];
    }
}

- (void)killTimer
{
    if (_treeTimer) {
//        if ([_treeTimer isValid]) {
//            [_treeTimer invalidate];
//        }
        _treeTimer = nil;
    }
}

- (void)mature
{
    [self setIsMature:YES];
}

- (void)startGrowthTimer:(CFTimeInterval)timeInterval
{
    _treeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                  target:self
                                                selector:@selector(mature)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)startGrow
{
    PPDebug(@"<MoneyTree> tree start growth");
    [self killTimer];
    [self setIsMature:NO];
    [self startGrowthTimer:[ConfigManager getTreeMatureTime]];
    
}

- (void)kill
{
    [self killTimer];
    
}

- (void)clickTree:(id)sender
{
    if (_isMature) {
        self.isMature = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(getMoney:fromTree:)]) {
            [_delegate getMoney:10 fromTree:self];
        }
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
