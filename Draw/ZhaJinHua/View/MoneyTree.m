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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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

- (void)startGrowth
{
    [self killTimer];
//    _treeTimer = [NSTimer timerWithTimeInterval:[ConfigManager getTreeMatureTime] target:self
//                                       selector:@selector(mature:) userInfo:nil repeats:NO];
}

- (void)kill
{
    
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
