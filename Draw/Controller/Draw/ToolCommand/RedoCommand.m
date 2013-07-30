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
    [self sendAnalyticsReport];
    [self.drawView redo];
    [self updateToolPanel];
    return YES;
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_REDO);
}
@end

