//
//  DrawToCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "DrawToCommand.h"
#import "MyFriend.h"
#import "UIImageUtil.h"
#import "OfflineDrawViewController.h"
#import "UIButton+WebCache.h"

@implementation DrawToCommand

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_CHANGE_DRAWTOUSER);
}


- (void)changeTargetFriend:(MyFriend *)aFriend
{
    if (aFriend) {
        PPDebug(@"<changeDrawToFriend> nick = %@", aFriend.nickName);
        OfflineDrawViewController *oc = (OfflineDrawViewController *)[self.control theViewController];
        [oc setTargetUid:aFriend.friendUserId];
        [(UIButton *)self.control setImageWithURL:[NSURL URLWithString:aFriend.avatar]];
    }
}

- (void)friendController:(FriendController *)controller
         didSelectFriend:(MyFriend *)aFriend
{
    [self changeTargetFriend:aFriend];
    [controller.navigationController popViewControllerAnimated:YES];
}

- (BOOL)execute
{
    FriendController *fc = [[FriendController alloc] initWithDelegate:self];
    [[[self.toolPanel theViewController] navigationController] pushViewController:fc animated:YES];
    [fc release];
    [self sendAnalyticsReport];
    return YES;
}


@end
