//
//  ZJHUserInfoView.m
//  Draw
//
//  Created by Kira on 12-12-4.
//
//

#import "ZJHUserInfoView.h"
#import "ZJHImageManager.h"
#import "UserManager.h"

@implementation ZJHUserInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (ZJHUserInfoView*)createUserInfoView
{
    return (ZJHUserInfoView*)[self createInfoViewByXibName:@"CommonUserInfoView"];
}

- (void)initView
{
    
}

+ (void)showFriend:(MyFriend*)afriend
        infoInView:(PPViewController*)superController
        needUpdate:(BOOL)needUpdate //if need update the info from service.
{
    if ([[UserManager defaultManager] isMe:afriend.friendUserId]) {
        return;
    }
    
    ZJHUserInfoView *view = [ZJHUserInfoView createUserInfoView];
    [view initViewWithFriend:afriend superController:superController];
    [view.backgroundImageView setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
    [view show];
    if (needUpdate) {
        [view updateInfoFromService];
    }
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
