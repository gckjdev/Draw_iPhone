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

#define    ROW_COUNT 1


@interface UserDetailViewController () {
    ChangeAvatar* _changeAvatar;
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
    [self didClickTabAtIndex:0];
    // Do any additional setup after loading the view from its nib.
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
    self = [self init];
    if (self) {
        self.detail = detail;
    }
    return self;
}


#pragma mark - user detail cell delegate
- (void)didClickEdit
{
    [self.navigationController pushViewController:[[[UserSettingController alloc] init] autorelease] animated:YES];
}


- (void)didClickAvatar
{
    if ([self.detail canEdit]) {
        if (_changeAvatar == nil) {
            _changeAvatar = [[ChangeAvatar alloc] init];
            _changeAvatar.autoRoundRect = NO;
        }
        [_changeAvatar showSelectionView:self];
    }
    
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
        }
        else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateAvatarFail") delayTime:1.5];
        }
    }];
}

// ChangeAvatar Delegate
- (void)didImageSelected:(UIImage *)image
{
    [self uploadUserAvatar:image];
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
                                                               nickName:[self.detail getUser].nickName];
    [self.navigationController pushViewController:uc animated:YES];
    [uc release];
}



- (void)didclickSina
{
    [self.detail clickSNSBtnType:TYPE_SINA viewController:self];
    
}
- (void)didclickQQ
{
    [self.detail clickSNSBtnType:TYPE_QQ viewController:self];
}
- (void)didclickFacebook
{
    [self.detail clickSNSBtnType:TYPE_FACEBOOK viewController:self];
}

- (void)didClickTabAtIndex:(int)index
{
    switch (index) {
        case DetailTabActionClickFavouriate:
        {
            [[FeedService defaultService] getUserFavoriteOpusList:[self.detail getUserId] offset:0 limit:[ConfigManager getDefaultDetailOpusCount] delegate:self];
        }
            break;
        case DetailTabActionClickOpus:
        {
            [[FeedService defaultService] getUserOpusList:[self.detail getUserId] offset:0 limit:[ConfigManager getDefaultDetailOpusCount] type:FeedListTypeUserOpus delegate:self];
        }
            break;
        default:
            break;
    }
}

- (void)didClickDrawFeed:(DrawFeed *)drawFeed
{
    ShowFeedController* sc = [[ShowFeedController alloc] initWithFeed:drawFeed];
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
    [self hideActivity];
    if (resultCode == 0) {
        switch (type) {
            case FeedListTypeUserFavorite: {
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[DrawFeed class]]) {
                        [self.favoriteList addObject:feed];
                        PPDebug(@"<UserDetailViewController> get opus - <%@>", ((DrawFeed*)feed).wordText);
                    }
                }
                [[self detailCell] setDrawFeedList:self.favoriteList];
            } break;
            case FeedListTypeUserOpus: {
                for (Feed* feed in feedList) {
                    if ([feed isKindOfClass:[DrawFeed class]]) {
                        [self.opusList addObject:feed];
                        PPDebug(@"<UserDetailViewController> get opus - <%@>", ((DrawFeed*)feed).wordText);
                    }
                }
                UserDetailCell* cell = [self detailCell];
                [cell setDrawFeedList:self.opusList];
            }
            default:
                break;
        }
    } 
}


@end
