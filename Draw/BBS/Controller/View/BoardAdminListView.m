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

#define VALUE(x) (ISIPAD ? x * 2 : x)
//#define SIZE(x) (ISIPAD : (CGSizeMake(x.width, x.height)) : x)

#define ADMIN_VIEW_MAX_WIDTH VALUE(70)
#define ADMIN_VIEW_MAX_HEIGHT VALUE(15)
#define ADMIN_AVATAR_WIDTH VALUE(12)

#define ADMIN_LIST_SIZE (ISIPAD ? CGSizeMake(320,25) : CGSizeMake(768,50))


@interface AdminView : UIControl

@property(nonatomic, retain)PBBBSUser *user;

@end

@implementation AdminView

- (void)dealloc
{
    PPRelease(_user);
    [super dealloc];
    
}

- (void)updateAvatar
{
    
}

- (void)updateNickName
{
    
}

+ (id)adminViewWithBBSUser:(PBBBSUser *)user
{
    AdminView *view = [[AdminView alloc] initWithFrame:CGRectMake(0, 0, ADMIN_VIEW_MAX_WIDTH, ADMIN_VIEW_MAX_HEIGHT)];
    view.user = user;
    [view updateAvatar];
    [view updateNickName];
    return [view autorelease];
}

@end


@implementation BoardAdminListView

- (void)updateView
{
    
}


+ (id)adminListViewWithBBSUserList:(NSArray *)userList controller:(PPViewController *)controller
{
    
//    CGRect rect = CGRectZero;
//    rect.size = ADMIN_LIST_SIZE;
//    BoardAdminListView *view = [BoardAdminListView
}

@end
