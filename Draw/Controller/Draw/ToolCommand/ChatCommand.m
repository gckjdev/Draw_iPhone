//
//  ChatCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ChatCommand.h"

@implementation ChatCommand

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_CHAT);
}

- (BOOL)execute
{
    [self.toolHandler handleChat];
    return YES;
}

@end
