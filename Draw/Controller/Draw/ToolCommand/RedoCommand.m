//
//  RedoCommand.m
//  Draw
//
//  Created by gamy on 13-3-30.
//
//

#import "RedoCommand.h"

@implementation RedoCommand

- (BOOL)execute
{
    [self.toolHandler handleRedo];
    return YES;
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_REDO);
}
@end

