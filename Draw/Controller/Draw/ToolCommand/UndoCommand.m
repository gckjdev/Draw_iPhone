//
//  UndoCommand.m
//  Draw
//
//  Created by gamy on 13-3-30.
//
//

#import "UndoCommand.h"

@implementation UndoCommand

- (BOOL)execute
{
    [self sendAnalyticsReport];
    [self.drawView undo];
    return YES;
}
-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_UNDO);
}

@end
