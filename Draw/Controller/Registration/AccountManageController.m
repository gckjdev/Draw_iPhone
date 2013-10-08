//
//  AccountManageController.m
//  Draw
//
//  Created by Gamy on 13-9-27.
//
//

#import "AccountManageController.h"
#import "UserManager.h"
#import "PPTableViewCell.h"
#import "StableView.h"
#import "UserNumberService.h"
#import "PPNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "TwoInputFieldView.h"
#import "UserService.h"


@interface AccountManageController ()
@property (nonatomic, retain) NSString *tempNumber;


@end

@implementation AccountManageController

- (void)dealloc
{
    PPRelease(_tempNumber);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showLoginViewWithNumber:(NSString *)number
{
    CommonDialog *logView = [TwoInputFieldView loginViewWithNumber:number passWord:nil];
//    [logView setManualClose:YES];
    [logView showInView:self.view];
    [logView setClickOkBlock:^(TwoInputFieldView *infoView){
        [self loginWithNumber:infoView.textField1.text passWord:infoView.textField2.text forSelected:NO];
    }];
}

- (void)addAccount:(id)sender
{
    if ([[[UserManager defaultManager] password] length] == 0){
        POSTMSG2(NSLS(@"kCannotLogoutWithoutPasswordSet"), 3.0f);
        return;
    }

    [self showLoginViewWithNumber:self.tempNumber];
}

- (void)loginWithNumber:(NSString *)number passWord:(NSString *)password forSelected:(BOOL)selected
{
    [self showActivityWithText:NSLS(@"kChangeAccount")];
    UserNumberServiceResultBlock block = ^(int resultCode, NSString *number) {
        [self hideActivity];
        if (resultCode == ERROR_SUCCESS){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else if (resultCode == ERROR_USERID_NOT_FOUND){
            POSTMSG(NSLS(@"kXiaojiNumberNotFound"));
            self.tempNumber = number;            
        }
        else if (resultCode == ERROR_PASSWORD_NOT_MATCH){
            POSTMSG(NSLS(@"kXiaojiPasswordIncorrect"));
            if (selected) {
                [self showLoginViewWithNumber:number];
            }else{
                self.tempNumber = number;
            }
        }
        else{
            POSTMSG(NSLS(@"kSystemFailure"));
            self.tempNumber = number;            
        }
    };
    if (selected) {
        [[UserNumberService defaultService] loginUser:number encodedPassword:password block:block];
    }else{
        [[UserNumberService defaultService] loginUser:number password:password block:block];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTitle:NSLS(@"kAccountManage")];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBack:)];
    [titleView setRightButtonTitle:NSLS(@"kAddAccount")];
    [titleView setRightButtonSelector:@selector(addAccount:)];
    
    self.canDragBack = NO;
    
    [UserManager syncHistoryUsers];
    self.dataList = [UserManager historyUsers];
    
    [self.dataTableView setBackgroundColor:COLOR_WHITE];
    SET_VIEW_BG(self.view);
    SET_NORMAL_TABLE_VIEW_Y(self.dataTableView);
    SET_NORMAL_CONTROLLER_VIEW_FRAME(self.view);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [AccountCell getCellIdentifier];
    
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [AccountCell createCell:self];
    }
    PBGameUser *user = self.dataList[indexPath.row];
    [cell updateCellWithAccount:user];
    
    if ([[UserManager defaultManager] isMe:user.userId]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

SET_CELL_BG_IN_CONTROLLER

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PBGameUser *user = self.dataList[indexPath.row];
    if ([[UserManager defaultManager] isMe:user.userId]) {
        if ([[[UserManager defaultManager] password] length] == 0){
            POSTMSG2(NSLS(@"kCannotLogoutWithoutPasswordSet"), 3.0f);
            return;
        }
        [[UserService defaultService] executeLogout:YES viewController:self];
    }else{
        [UserManager deleteUserFromHistoryList:user.userId];
        self.dataList = [UserManager historyUsers];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    PBGameUser *user = self.dataList[indexPath.row];
    if ([[UserManager defaultManager] isMe:user.userId]) {
        return NSLS(@"kLogout");
    }
    return NSLS(@"kDelete");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [AccountCell getCellHeight];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBGameUser *user = self.dataList[indexPath.row];
    if ([[UserManager defaultManager] isMe:user.userId]) {
        return;
    }

    if ([[[UserManager defaultManager] password] length] == 0){
        POSTMSG2(NSLS(@"kCannotLogoutWithoutPasswordSet"), 3.0f);
        return;
    }

    
    [self loginWithNumber:user.xiaojiNumber passWord:user.password forSelected:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end




//////////

@implementation AccountCell


+ (id)createCell:(id)delegate
{
    AccountCell *cell = [self createViewWithXibIdentifier:[AccountCell getCellIdentifier] ofViewIndex:(ISIPAD)];
    cell.delegate = delegate;
    [cell updateView];
    return cell;
}

- (void)updateView
{
    [self.nickName setTextColor:COLOR_BROWN];
    [self.xjNumber setTextColor:COLOR_GREEN];
    
}

- (void)updateCellWithAccount:(PBGameUser *)user
{
    self.user = user;
    [self.avatarView setAvatarUrl:user.avatar gender:user.gender];
    [self.nickName setText:user.nickName];
    [self.xjNumber setText:[NSString stringWithFormat:@"%@:%@", NSLS(@"kXiaoji"), user.xiaojiNumber]];
}

+ (NSString *)getCellIdentifier
{
    return @"AccountCell";
}

+ (CGFloat)getCellHeight
{
    return (ISIPAD?132:66);
}

- (void)dealloc
{
    [_avatarView release];
    [_nickName release];
    [_xjNumber release];
    PPRelease(_user);
    [super dealloc];
}

@end
