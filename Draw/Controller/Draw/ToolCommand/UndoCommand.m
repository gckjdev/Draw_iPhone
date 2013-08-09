//
//  UndoCommand.m
//  Draw
//
//  Created by gamy on 13-3-30.
//
//

#import "UndoCommand.h"
#import "PPTableViewController.h"

@implementation UndoCommand

- (BOOL)execute
{
    [self sendAnalyticsReport];
    if (![self.drawView undo]) {
        [(PPTableViewController *)[self.control theViewController] popupHappyMessage:NSLS("kCannotRevoke") title:nil];
    }
    [self updateToolPanel];
    return YES;
}
-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_UNDO);
}

@end
