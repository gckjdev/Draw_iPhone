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

#define    ROW_COUNT 1


@interface UserDetailViewController ()

@end

@implementation UserDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.detail && [self.detail needUpdate]) {
        [[UserService defaultService] getUserInfo:[self.detail getUserId] resultBlock:^(int resultCode, PBGameUser *user) {
            if (resultCode == 0 &&[self.detail respondsToSelector:@selector(setPbGameUser:)]
                                && user != nil) {
                [self.detail setPbGameUser:user];
                [self.dataTableView reloadData];
            }
        }];
    }
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
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailCell* cell = [UserDetailCell createCell:self];
    
    if (cell) {
        [cell setCellWithUserDetail:self.detail];
        cell.detailDelegate = self;
    }
    return cell;
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
    self = [super init];
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

- (void)didClickFanCountButton
{
    
}
- (void)didClickFollowCountButton
{
    
}
- (void)didClickFollowButton
{
    [[FriendService defaultService] followUser:[self.detail getUserId] withDelegate:self];
    [self showActivityWithText:NSLS(@"kFollowing")];
}
- (void)didClickChatButton
{
    PBGameUser* pbUser = [self.detail queryUser];
    MyFriend* targetFriend = [MyFriend friendWithFid:[self.detail getUserId] nickName:pbUser.nickName avatar:pbUser.avatar gender:pbUser.gender level:pbUser.level];
    MessageStat *stat = [MessageStat messageStatWithFriend:targetFriend];
        ChatDetailController *controller = [[ChatDetailController alloc] initWithMessageStat:stat];
    [self.navigationController pushViewController:controller
                                                                 animated:YES];
    [controller release];
}
- (void)didClickDrawToButton
{
    SelectHotWordController *vc = [[[SelectHotWordController alloc] initWithTargetUid:[self.detail getUserId]] autorelease];
    vc.superController = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didFollowUser:(int)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowFailed")
                                                       delayTime:1.5
                                                         isHappy:NO];
    } else {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFollowSuccessfully")
                                                       delayTime:1.5
                                                         isHappy:YES];
    }
}

@end
