//
//  SecureSmsUserSettingController.m
//  Draw
//
//  Created by haodong on 13-5-23.
//
//

#import "SecureSmsUserSettingController.h"
#import "UserManager.h"
#import "UIButton+WebCache.h"
#import "UserService.h"
#import "PPNetworkRequest.h"
#import "GameBasic.pb.h"
#import "CommonMessageCenter.h"
#import "UserService.h"
#import "ShareImageManager.h"
#import "UserSettingCell.h"
#import "StringUtil.h"
#import "ConfigManager.h"

@interface SecureSmsUserSettingController()
{
    UserManager *_userManager;
}

@property (retain, nonatomic) ChangeAvatar *imageUploader;
@property (retain, nonatomic) PBGameUser_Builder *pbUserBuilder;
@property (assign, nonatomic) BOOL hasEdited;

@end

@implementation SecureSmsUserSettingController

- (void)dealloc {
    [_backgroundImage release];
    [_saveButton release];
    [_titleLabel release];
    [_avatarButton release];
    [_nicknameLabel release];
    [_imageUploader release];
    [_pbUserBuilder release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setBackgroundImage:nil];
    [self setSaveButton:nil];
    [self setTitleLabel:nil];
    [self setAvatarButton:nil];
    [self setNicknameLabel:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userManager = [UserManager defaultManager];
    self.pbUserBuilder = [PBGameUser builderWithPrototype:[_userManager pbUser]];
    
    //
    [self.backgroundImage setImage:[UIImage imageNamed:[GameApp background]]];
    [self.titleLabel setText:NSLS(@"kSettings")];
    [self.saveButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
    [self updateNicknameLabel];
    
    
    //show avatar
    [self showAvatar];
}

- (void)updateNicknameLabel
{
    [self.nicknameLabel setText:_pbUserBuilder.nickName];
}

- (void)showAvatar
{
    NSURL* url = [NSURL URLWithString:[_userManager avatarURL]];
    UIImage* defaultImage = [[UserManager defaultManager] defaultAvatarImage];
    
    _avatarButton.alpha = 0;
    [_avatarButton setImageWithURL:url placeholderImage:defaultImage success:^(UIImage *image, BOOL cached) {
        [UIView animateWithDuration:1 animations:^{
                _avatarButton.alpha = 1.0;
            }];
    } failure:^(NSError *error) {
        _avatarButton.alpha = 1.0;
    }];
}

- (void)updateAvatar:(UIImage *)image
{
    [_avatarButton setImage:image forState:UIControlStateNormal];
}

- (void)uploadUserAvatar:(UIImage*)image
{
    [self showActivityWithText:NSLS(@"kSaving")];
    [[UserService defaultService] uploadUserAvatar:image resultBlock:^(int resultCode, NSString *imageRemoteURL) {
        [self hideActivity];
        if (resultCode == ERROR_SUCCESS && [imageRemoteURL length] > 0){
            [_pbUserBuilder setAvatar:imageRemoteURL];
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateAvatarSucc") delayTime:1.5];
            [self updateAvatar:image];
        }
        else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateAvatarFail") delayTime:1.5];
        }
    }];
}

- (IBAction)clickBackButton:(id)sender {
    
    if (_hasEdited) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotice") message:NSLS(@"kInfoUnSaved") style:CommonDialogStyleDoubleButton delegate:self];
        [dialog showInView:self.view];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)clickSaveButton:(id)sender {
    
    if (_pbUserBuilder.nickName.length > [ConfigManager getNicknameMaxLen]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kNicknameOutofRange"), [ConfigManager getNicknameMaxLen], [ConfigManager getNicknameMaxLen]/2] delayTime:1.5];
        return;
    }
    
    if (_hasEdited) {
        PBGameUser* user = [_pbUserBuilder build];
        self.pbUserBuilder = [PBGameUser builderWithPrototype:user];
        
        [self showActivityWithText:NSLS(@"kSaving")];
        [[UserService defaultService] updateUser:user resultBlock:^(int resultCode) {
            [self hideActivity];
            if (resultCode == ERROR_SUCCESS){
                
                // clear edit flag
                _hasEdited = NO;
                
                // show message
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateUserSucc") delayTime:1.5];
                
                // reload user and table view
                self.pbUserBuilder = [PBGameUser builderWithPrototype:_userManager.pbUser];
                [self updateNicknameLabel];
                [self.dataTableView reloadData];
            }
            else{
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateUserFail") delayTime:1.5];
            }
        }];
        
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNoUpdate") delayTime:1.5];
    }
}

- (IBAction)clickAvatar:(id)sender
{
    __block typeof(self) beself = self;
    if (_imageUploader == nil) {
        self.imageUploader = [[[ChangeAvatar alloc] init] autorelease];
        _imageUploader.autoRoundRect = NO;
    }
    [_imageUploader showSelectionView:self
                  selectedImageBlock:^(UIImage *image) {
                      [beself uploadUserAvatar:image];
                  }
                  didSetDefaultBlock:nil
                               title:nil
                     hasRemoveOption:NO];
}


#pragma mark - UITableViewDataSource methods
enum {
    RowNickname = 0,
    RowEmail = 1,
    RowPassword = 2,
    RowCount = 3
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return RowCount;
}

- (void)clearSwitchInCell:(UITableViewCell *)cell
{
    //clear the buttons
    for (UIView *view in [[cell contentView] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [UserSettingCell getCellIdentifier];
    UserSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [UserSettingCell createCell:self];
    }else{
        [self clearSwitchInCell:cell];
    }
    
    [cell setCellWithRow:indexPath.row inSectionRowCount:RowCount];
    
    if (indexPath.row == RowNickname) {
        [cell.customTextLabel setText:NSLS(@"kNickname")];
        [cell.customDetailLabel setText:_pbUserBuilder.nickName];
        
    } else if (indexPath.row == RowEmail) {
        [cell.customTextLabel setText:NSLS(@"kSetEmail")];
        if ([_pbUserBuilder.email length] > 0){
            [cell.customDetailLabel setText:_pbUserBuilder.email];
        }
        else{
            [cell.customDetailLabel setText:NSLS(@"kEmailNotSet")];
        }
    } else if (indexPath.row == RowPassword) {
        [cell.customTextLabel setText:NSLS(@"kPassword")];
        if ([_pbUserBuilder.password length] == 0) {
            [cell.customDetailLabel setText:NSLS(@"kUnset")];
        }
        else{
            [cell.customDetailLabel setText:NSLS(@"kPasswordSet")];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UserSettingCell getCellHeight];
}

#define DIALOG_TAG_NICKNAME 2013052701
#define DIALOG_TAG_EMAIL    2013052702
#define DIALOG_TAG_PASSWORD 2013052703

- (void)askInputEmail:(NSString*)text
{
    InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kInputEmail") delegate:self];
    dialog.tag = DIALOG_TAG_EMAIL;
    [dialog setTargetText:text];
    [dialog.targetTextField setPlaceholder:NSLS(@"kInputEmail")];
    [dialog showInView:self.view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == RowNickname) {
        InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kNickname") delegate:self];
        dialog.tag = DIALOG_TAG_NICKNAME;
        [dialog setTargetText:self.nicknameLabel.text];
        [dialog setMaxInputLen:[ConfigManager getNicknameMaxLen]];
        [dialog showInView:self.view];
    } else if (indexPath.row == RowEmail) {
        [self askInputEmail:_pbUserBuilder.email];
    } else if (indexPath.row == RowPassword) {
        PassWordDialog *dialog = [PassWordDialog dialogWith:NSLS(@"kPassword") delegate:self];
        dialog.tag = DIALOG_TAG_PASSWORD;
        [dialog showInView:self.view];
    }
}

- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    if (dialog.tag == DIALOG_TAG_NICKNAME) {
        if ([targetText length] > 0){
            [_pbUserBuilder setNickName:targetText];
            [self updateNicknameLabel];
            _hasEdited = YES;
        }
    } else if (dialog.tag == DIALOG_TAG_EMAIL){
        if (NSStringIsValidEmail(targetText)){
            [_pbUserBuilder setEmail:targetText];
            _hasEdited = YES;
        }
        else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEmailNotValid") delayTime:1.5];
            [self askInputEmail:targetText];
        }
        
    } else if(dialog.tag == DIALOG_TAG_PASSWORD){
        if ([targetText length] > 0){
            [_pbUserBuilder setPassword:[targetText encodeMD5Base64:PASSWORD_KEY]];
            _hasEdited = YES;
        }
    }
    
    [self.dataTableView reloadData];
}

#pragma mark - ChangeAvatarDelegate methods
- (void)didImageSelected:(UIImage *)image
{
}

#pragma mark - Password Dialog Delegate
- (void)passwordIsWrong:(NSString *)password
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPasswordWrong") delayTime:1.5];
    
}

- (void)twoInputDifferent
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPasswordDifferent") delayTime:1.5];
}

- (void)passwordIsIllegal:(NSString *)password
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPasswordIllegal") delayTime:1.5];
}

@end
