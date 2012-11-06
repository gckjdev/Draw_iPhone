//
//  MoneyTree.m
//  Draw
//
//  Created by Kira on 12-11-5.
//
//

#import "MoneyTree.h"
#import "ConfigManager.h"

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

- (void)setIsMature:(BOOL)isMature
{
    _isMature = isMature;
    if (isMature) {
        //TODO: here set button image a coin
    } else {
        //TODO: here set button image a tree
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

- (void)mature:(id)sender
{
    [self setIsMature:YES];
}

- (void)startGrowthTimer:(CFTimeInterval)timeInterval
{
    _treeTimer = [NSTimer timerWithTimeInterval:timeInterval target:self
                                       selector:@selector(mature:) userInfo:nil repeats:NO];
}

- (void)startGrowth
{
    [self killTimer];
    [self setIsMature:NO];
    [self startGrowthTimer:[ConfigManager getTreeMatureTime]];
    
}

- (void)kill
{
    [self killTimer];
    
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
