//
//  BoardAdminListView.m
//  Draw
//
//  Created by gamy on 13-1-26.
//
//

#import "BoardAdminListView.h"
#import "BBSModelExt.h"
#import "UIViewUtils.h"
#import "CommonUserInfoView.h"
#import "MyFriend.h"
#import "UIImageView+WebCache.h"
#import "BBSViewManager.h"

#import <QuartzCore/QuartzCore.h>

#define VALUE(x) (ISIPAD ? x * 2.0 : x)

#define SPACE_ADMINVIEW VALUE(3.0)

#define ADMIN_NICK_MAX_WIDTH VALUE(65.0) //nick
#define ADMIN_NICK_HEIGHT VALUE(55.0) //nick

#define ADMIN_AVATAR_WIDTH VALUE(12.0) //avatar

#define ADMIN_VIEW_HEIGHT VALUE(15.0) //admin view


#define ADMIN_START_X VALUE(65.0)

#define NICK_FONT_SIZE VALUE(14)
#define NICK_FONT [[BBSFontManager defaultManager] boardAdminNickFont]


@interface AdminView : UIControl
{
    UILabel *_nick;
    UIImageView *_avatar;
}
@property(nonatomic, retain)PBBBSUser *user;

@end

@implementation AdminView

- (void)dealloc
{
    PPDebug(@"%@ dealloc", self);
    PPRelease(_user);
    [super dealloc];
    
}

- (void)updateAvatar
{
    CGRect frame = CGRectZero;
    CGFloat y = (CGRectGetHeight(self.bounds) - ADMIN_AVATAR_WIDTH)/2.0;
    frame.origin = CGPointMake(0, y);
    frame.size = CGSizeMake(ADMIN_AVATAR_WIDTH, ADMIN_AVATAR_WIDTH);
    
    _avatar = [[[UIImageView alloc] initWithFrame:frame] autorelease];
    [_avatar.layer setCornerRadius:ADMIN_AVATAR_WIDTH/6.0];
    [_avatar.layer setMasksToBounds:YES];
    //set bounds color
    [self addSubview:_avatar];
    [_avatar setImageWithURL:self.user.avatarURL placeholderImage:self.user.defaultAvatar];
    _avatar.userInteractionEnabled = YES;
}

- (void)updateNickName
{
    CGRect frame = CGRectZero;
    CGFloat y = (CGRectGetHeight(self.bounds) - ADMIN_VIEW_HEIGHT)/2.0;
    frame.origin = CGPointMake(ADMIN_AVATAR_WIDTH * 1.3, y);
    CGSize size = [_user.nickName sizeWithFont:NICK_FONT forWidth:ADMIN_NICK_MAX_WIDTH lineBreakMode:NSLineBreakByCharWrapping];
    frame.size = CGSizeMake(size.width * 1.2, CGRectGetHeight(self.bounds));
    
    _nick = [[[UILabel alloc] initWithFrame:frame] autorelease];
    [_nick setText:_user.nickName];
    [_nick setLineBreakMode:NSLineBreakByTruncatingTail];
    [_nick setFont:NICK_FONT];
    [_nick setBackgroundColor:[UIColor clearColor]];
    [_nick setTextColor:[[BBSColorManager defaultManager] bbsAdminNickColor]];
    [self addSubview:_nick];
}

- (void)updateFrame
{
    CGFloat width = CGRectGetWidth(_nick.frame) + CGRectGetWidth(_avatar.frame);
    self.frame = CGRectMake(0, 0, width, ADMIN_VIEW_HEIGHT);
}

+ (id)adminViewWithBBSUser:(PBBBSUser *)user
{
    AdminView *view = [[AdminView alloc] initWithFrame:CGRectMake(0, 0, 1, ADMIN_VIEW_HEIGHT)];
    view.user = user;
    [view updateAvatar];
    [view updateNickName];
    [view updateFrame];
    return [view autorelease];
}

@end


@implementation BoardAdminListView

- (void)dealloc
{
    PPDebug(@"%@ dealloc", self);
    [_adminTitle release];
    [super dealloc];
}

- (void)clickAdminView:(AdminView *)adminView
{
    PBBBSUser *user = adminView.user;
    if (user) {
        MyFriend *f = [MyFriend friendWithFid:user.userId nickName:user.nickName avatar:user.avatar gender:user.genderString level:1];
        [CommonUserInfoView showFriend:f inController:self.controller needUpdate:YES canChat:YES];
    }
}

- (void)updateAdminView:(AdminView *)view frameWithX:(CGFloat)x
{
    view.center = self.center;
    CGRect frame = view.frame;
    frame.origin = CGPointMake(x, CGRectGetMinY(frame));
    view.frame = frame;
}

- (void)updateViewWithUserList:(NSArray *)userList
{
    CGFloat x = ADMIN_START_X;
    for (PBBBSUser *user in userList) {
        AdminView *view = [AdminView adminViewWithBBSUser:user];
        [self addSubview:view];
        [view addTarget:self action:@selector(clickAdminView:) forControlEvents:UIControlEventTouchUpInside];
        [self updateAdminView:view frameWithX:x];
        x = CGRectGetMaxX(view.frame) + SPACE_ADMINVIEW;
    }
    [self updateTitleWithUserList:userList];
}

- (void)updateTitleWithUserList:(NSArray *)userList
{
    if ([userList count] == 0) {
        [self.adminTitle setText:NSLS(@"kNoBoardAdmin")];
        CGRect frame = [self.adminTitle frame];
        frame.size.width = CGRectGetWidth(self.frame);
        [self.adminTitle setFrame:frame];
    }else{
        [self.adminTitle setText:NSLS(@"kBoardAdmin")];
    }
    [self.adminTitle setTextColor:[[BBSColorManager defaultManager] bbsAdminTitleColor]];
    [self.adminTitle setFont:[[BBSFontManager defaultManager] boardAdminTitleFont]];
    [self.adminTitle setBackgroundColor:[UIColor clearColor]];
}

+ (id)adminListViewWithBBSUserList:(NSArray *)userList controller:(PPViewController *)controller
{
    BoardAdminListView *view = [UIView createViewWithXibIdentifier:@"BoardAdminListView"];
    view.controller = controller;
    [view updateViewWithUserList:userList];
    return view;
}

@end
