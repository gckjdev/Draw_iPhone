//
//  DrawToCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "DrawToCommand.h"
#import "MyFriend.h"


@implementation DrawToCommand

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_CHANGE_DRAWTOUSER);
}


- (void)changeTargetFriend:(MyFriend *)aFriend
{
    if (aFriend) {
        [self.toolHandler changeDrawToFriend:aFriend];
        UIButton *button = (UIButton *)self.control;
        //TODO set the button image, not the background image with aFriend.avatar.
    }
}

- (BOOL)execute
{
    //TODO enter MyFriendController and select the friend
}


//TODO

@end
