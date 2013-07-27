//
//  ChatCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ChatCommand.h"
#import "OnlineDrawViewController.h"

@implementation ChatCommand

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_CHAT);
}

- (BOOL)execute
{
    [self sendAnalyticsReport];
    OnlineDrawViewController *oc = (OnlineDrawViewController *)self.controller;
    [oc showGroupChatView];
    return YES;
}

@end
