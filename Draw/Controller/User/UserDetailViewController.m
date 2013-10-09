//
//  UserDetailViewController.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "UserDetailViewController.h"
#import "GameBasic.pb.h"
#import "UserDetailCell.h"
#import "UserService.h"
#import "UserSettingController.h"
#import "FriendController.h"
#import "FriendService.h"
#import "ChatDetailController.h"
#import "MyFriend.h"
#import "MessageStat.h"
#import "SelectHotWordController.h"
#import "CommonMessageCenter.h"
#import "ChangeAvatar.h"
#import "UserService.h"
#import "SuperUserManageAction.h"
#import "PPSNSCommonService.h"
#import "SNSUtils.h"
#import "PPSNSIntegerationService.h"
#import "CommonMessageCenter.h"
#import "CommonDialog.h"
#import "FeedService.h"
#import "Feed.h"
#import "UserFeedController.h"
#import "ShowFeedController.h"
#import "UIImageView+WebCache.h"
#import "UseItemScene.h"
#import "HPThemeManager.h"
#import "SelfUserDetail.h"

#define    ROW_COUNT 1


@interface UserDetailViewController () {
    ChangeAvatar* _changeAvatar;
    int currentTabIndex;
}

@property (retain, nonatomic) UserDetailCell* detailCell;
@property (retain, nonatomic) NSMutableArray* opusList;
@property (retain, nonatomic) NSMutableArray* guessedList;
@property (retain, nonatomic) NSMutableArray* favoriteList;

@end

@implementation UserDetailViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _opusList = [[NSMutableArray alloc] init];
        _guessedList = [[NSMutableArray alloc] init];
        _favoriteList = [[NSMutableArray alloc] init];        
    }
    return self;
}

- (void)viewDidLoad
{
    [self.detail loadUser:self];
    [super viewDidLoad];
    [self.backButton setBackgroundImage:UIThemeImageNamed(@"navigation_back@2x.png") forState:UIControlStateNormal];
    self.unReloadDataWhenViewDidAppear = YES;
    
    
    if (!(currentTabIndex == DetailTabActionClickOpus && self.opusList.count != 0)) {
        [self didClickTabAtIndex:currentTabIndex];
    }
    
    if ([self.detail isKindOfClass:[SelfUserDetail class]]){
        [self registerNotificationWithName:NOTIFCATION_USER_DATA_CHANGE usingBlock:^(NSNotification *note) {
            PPDebug(@"recv NOTIFCATION_USER_DATA_CHANGE, reload user data");
            [self.dataTableView reloadData];
        }];
    }
    
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    if (!(currentTabIndex == DetailTabActionClickOpus && self.opusList.count != 0)) {
//        [self didClickTabAtIndex:currentTabIndex];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [self unregisterAllNotifications];
    
    PPRelease(_detail);
    PPRelease(_detailCell);
    PPRelease(_backButton);
    PPRelease(_changeAvatar);
    PPRelease(_opusList);
    PPRelease(_guessedList);
    PPRelease(_favoriteList);
    
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackButton:nil];
    [super viewDidUnload];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailCell) {
        self.detailCell = [UserDetailCell createCell:self];
        self.detailCell.detailDelegate = self;
    }
    if (self.detailCell) {
        [self.detailCell setCellWithUserDetail:self.detail];
    }
    
    return self.detailCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ROW_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UserDetailCell getCellHeight];
}

- (id)initWithUserDetail:(NSObject<UserDetailProtocol>*)detail
{
    self = [self init];
    if (self) {
        self.detail = detail;
    }
    return self;
}

+ (void)presentUserDetail:(NSObject<UserDetailProtocol>*)detail inViewController:(PPViewController*)viewController
{
    if ([detail shouldShow]) {
        UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:detail] autorelease];
        [viewController.navigationController pushViewController:uc animated:YES];
    }
    else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCannotShowYourself") delayTime:2];
    }
}


#pragma mark - user detail cell delegate
- (void)didClickEdit
{
    [self.navigationController pushViewController:[[[UserSettingController alloc] init] autorelease] animated:YES];
}


- (void)didClickAvatar
{
    __block UserDetailViewController* uc = self;
    [self.detail clickAvatar:self didSelectBlock:^(UIImage *image) {
        [uc uploadUserAvatar:image];
    }];
}

- (void)didClickCustomBackground
{
    __block UserDetailViewController* uc = self;
    [self.detail clickCustomBg:self didSelectBlock:^(UIImage *image) {
        [uc uploadCustomBg:image];
    }];
}

- (void)uploadCustomBg:(UIImage*)image
{
    [self showActivityWithText:NSLS(
                                    @"kSaving")];
    [[UserService defaultService] uploadUserBackground:image resultBlock:^(int resultCode, NSString *imageRemoteURL) {
        [self hideActivity];
        if (resultCode == 0 && [imageRemoteURL length] > 0){
            [[UserManager defaultManager] setBackground:imageRemoteURL];
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateBackgroundSucc") delayTime:1.5];
            [self.detail loadUser:self];
            
            [[self detailCell].customBackgroundImageView setImage:image];
            [self detailCell].customBackgroundImageView.alpha = 0.5;
            [UIView animateWithDuration:1 animations:^{
                [self detailCell].customBackgroundImageView.alpha = 1;
            }];
        }
        else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateBackgroundFail") delayTime:1.5];
        }
    }];
}


- (void)uploadUserAvatar:(UIImage*)image
{
    [self showActivityWithText:NSLS(@"kSaving")];
    [[UserService defaultService] uploadUserAvatar:image resultBlock:^(int resultCode, NSString *imageRemoteURL) {
        [self hideActivity];
        if (resultCode == 0 && [imageRemoteURL length] > 0){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateAvatarSucc") delayTime:1.5];
            [self.detail loadUser:self];
            
            [self.detailCell.avatarView setImage:image];
            self.detailCell.avatarView.alpha = 0.5;
            [UIView animateWithDuration:1 animations:^{
                self.detailCell.avatarView.alpha = 1;
            }];
        }
        else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateAvatarFail") delayTime:1.5];
        }
    }];
}

// ChangeAvatar Delegate
- (void)didImageSelected:(UIImage *)image
{
//    [self uploadUserAvatar:image];
}

- (void)didclickBlack
{
    CHECK_AND_LOGIN(self.view);
    [self.detail blackUser:self];
    
}
- (void)didclickManage
{
    [self.detail superManageUser:self];
    
}
- (void)didClickMore
{
    UserFeedController* uc = [[UserFeedController alloc] initWithUserId:[self.detail getUserId]
                                                               nickName:[self.detail getUser].nickName
                                                        defaultTabIndex:currentTabIndex];
    [self.navigationController pushViewController:uc animated:YES];
    [uc release];
}



- (void)didclickSina
{
    [self.detail clickSNSBtnType:TYPE_SINA viewController:self];
    [self.dataTableView reloadData];//TODO:should be optimize later, don't use hightLight to mark sns status , because when click btn, it auto reset highLight status, same as follows
}
- (void)didclickQQ
{
    [self.detail clickSNSBtnType:TYPE_QQ viewController:self];
    [self.dataTableView reloadData];
}
- (void)didclickFacebook
{
    [self.detail clickSNSBtnType:TYPE_FACEBOOK viewController:self];
    [self.dataTableView reloadData];
}

- (void)didClickBBSPost
{
    [self.detail viewBBSPost:self];
}

- (void)updateFavoriteList
{
    if ([self.favoriteList count] > 0) {
        [[self detailCell] setDrawFeedList:self.favoriteList tipText:NSLS(@"kNoFavorite")];
    }else{
        [[FeedService defaultService] getUserFavoriteOpusList:[self.detail getUserId] offset:0 limit:[ConfigManager getDefaultDetailOpusCount] delegate:self];
        [[self detailCell] setIsLoadingFeed:YES];
    }
}

- (void)updateOpusList
{
    if ([self.opusList count] > 0) {
        [[self detailCell] setDrawFeedList:self.opusList tipText:NSLS(@"kNoOpus")];
    }else{
        [[FeedService defaultService] getUserOpusList:[self.detail getUserId] offset:0 limit:[ConfigManager getDefaultDetailOpusCount] type:FeedListTypeUserOpus delegate:self];
        [[self detailCell] setIsLoadingFeed:YES];
    }
}

- (void)didClickTabAtIndex:(int)index
{
    currentTabIndex = index;
    [[self detailCell] clearDrawFeedList];
    switch (index) {
        case DetailTabActionClickFavouriate:
        {
            [self updateFavoriteList];
        }
            break;
        case DetailTabActionClickOpus:
        {
            [self updateOpusList];
        }
            break;
        default:
            break;
    }
}

- (void)didClickDrawFeed:(DrawFeed *)drawFeed
{
    
    UseItemScene *scene  = [UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:drawFeed];
    ShowFeedController* sc = [[ShowFeedController alloc] initWithFeed:drawFeed scene:scene];
    [sc showOpusImageBrower];
    sc.feedList = [self opusList];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}

- (void)didClickUserActionButtonAtIndex:(NSInteger)index
{
    CHECK_AND_LOGIN(self.view);
    [self.detail clickUserActionButtonAtIndex:index viewController:self];
}

#pragma mark - feed service delegate
- (void)didGetFeedList:(NSArray *)feedList
            targetUser:(NSString *)userId
                  type:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    [[self detailCell] setIsLoadingFeed:NO];
    if (resultCode == 0) {
        switch (type) {
            case FeedListTypeUserFavorite: {
                [self.favoriteList removeAllObjects];
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[DrawFeed class]]) {
                        [self.favoriteList addObject:feed];
                        PPDebug(@"<UserDetailViewController> get opus - <%@>", ((DrawFeed*)feed).wordText);
                    }
                }
                [[self detailCell] setDrawFeedList:self.favoriteList tipText:NSLS(@"kNoFavorite")];
            } break;
            case FeedListTypeUserOpus: {
                [self.opusList removeAllObjects];
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[DrawFeed class]]) {
                        [self.opusList addObject:feed];
                        PPDebug(@"<UserDetailViewController> get opus - <%@>", ((DrawFeed*)feed).wordText);
                    }
                }
                UserDetailCell* cell = [self detailCell];
                [cell setDrawFeedList:self.opusList tipText:NSLS(@"kNoOpus")];
            }
            default:
                break;
        }
    } 
}

- (void)clickBack:(id)sender{
    
    [self unregisterNotificationWithName:NOTIFCATION_USER_DATA_CHANGE];

    PPRelease(_detail);
    PPRelease(_detailCell);
    PPRelease(_backButton);
    PPRelease(_changeAvatar);
    PPRelease(_opusList);
    PPRelease(_guessedList);
    PPRelease(_favoriteList);
    
    [super clickBack:sender];
}


@end
