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
#import "CommonRoundAvatarView.h"
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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.detail loadUser:self];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!(currentTabIndex == DetailTabActionClickOpus && self.opusList.count != 0)) {
        [self didClickTabAtIndex:currentTabIndex];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundImageView release];
    [_detail release];
    PPRelease(_detailCell);
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
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
//    if (![detail shouldShow]) {
//        return nil;//TODO: temply fix bug:show self and follow self, should optimize later
//    }
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
        }
        else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateBackgroundFail") delayTime:1.5];
        }
    }];
}


//- (void)didClickCustomBackground{
//    __block UserDetailViewController* uc = self;
//    if (_changeAvatar == nil) {
//        _changeAvatar = [[ChangeAvatar alloc] init];
//        _changeAvatar.autoRoundRect = NO;
//    }
//    [_changeAvatar showSelectionView:self selectedImageBlock:^(UIImage *image) {
//        [uc uploadCustomBg:image];
//    }];
//}

- (void)uploadUserAvatar:(UIImage*)image
{
    [self showActivityWithText:NSLS(@"kSaving")];
    [[UserService defaultService] uploadUserAvatar:image resultBlock:^(int resultCode, NSString *imageRemoteURL) {
        [self hideActivity];
        if (resultCode == 0 && [imageRemoteURL length] > 0){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateAvatarSucc") delayTime:1.5];
            [self.detail loadUser:self];
            [self.detailCell.avatarView setImage:image];            
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
    [[FeedService defaultService] getUserFavoriteOpusList:[self.detail getUserId] offset:0 limit:[ConfigManager getDefaultDetailOpusCount] delegate:self];
}

- (void)updateOpusList
{
    [[FeedService defaultService] getUserOpusList:[self.detail getUserId] offset:0 limit:[ConfigManager getDefaultDetailOpusCount] type:FeedListTypeUserOpus delegate:self];
}

- (void)didClickTabAtIndex:(int)index
{
    currentTabIndex = index;
    [[self detailCell] clearDrawFeedList];
    [[self detailCell] setIsLoadingFeed:YES];
    switch (index) {
        case DetailTabActionClickFavouriate:
        {
                [self updateFavoriteList];
        }
            break;
        case DetailTabActionClickOpus:
        {
            if (self.favoriteList.count == 0 || [self.detail canEdit]) {
                [self updateOpusList];
            } else {
                [[self detailCell] setDrawFeedList:self.opusList tipText:NSLS(@"kNoOpus")];
                [[self detailCell] setIsLoadingFeed:NO];
            }
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
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}

- (void)didClickUserActionButtonAtIndex:(NSInteger)index
{
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


@end
