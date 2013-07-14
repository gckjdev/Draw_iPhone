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

@implementation DrawToCommand

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_CHANGE_DRAWTOUSER);
}


- (void)changeTargetFriend:(MyFriend *)aFriend
{
    if (aFriend) {
        [self.toolHandler changeDrawToFriend:aFriend];
        [(DrawToolUpPanel *)self.toolPanel updateDrawToUser:aFriend];
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
    //TODO enter MyFriendController and select the friend
    FriendController *fc = [[FriendController alloc] initWithDelegate:self];
    [[[self.toolPanel theViewController] navigationController] pushViewController:fc animated:YES];
    [fc release];
    
    return YES;
}


@end
