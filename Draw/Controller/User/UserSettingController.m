//
//  UserSettingController.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserSettingController.h"
#import "PPDebug.h"
#import "UserManager.h"
#import "LocaleUtils.h"
#import "ShareImageManager.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "InputDialog.h"
#import "PassWordDialog.h"
#import "StringUtil.h"

enum{
    SECTION_LANGUAGE = 0,
    SECTION_COUNT
};

#define DIALOG_TAG_NICKNAME 201204071
#define DIALOG_TAG_PASSWORD 201204072

@implementation UserSettingController
@synthesize saveButton;
@synthesize titleLabel;
@synthesize avatarButton;
@synthesize tableViewBG;
@synthesize nicknameLabel;
@synthesize updatePassword = _updatePassword;


- (void)updateRowIndexs
{
    rowOfPassword = 0;
    rowOfNickName = 1;
    rowOfLanguage = 2;
    rowNumber = 3;
    
    /*
    if ([LocaleUtils isChina]) {
        rowOfSinaWeibo = 3;
        rowOfQQWeibo = 4;
        rowOfFacebook = -1;
        rowNumber = 5;
    }else{
        rowOfSinaWeibo = rowOfQQWeibo = -1;        
        rowOfFacebook = 3;
        rowNumber = 4;
    }
     */
}
- (void)updateAvatar:(UIImage *)image
{
    [imageView setImage:image];
}

- (void)updateNickname:(NSString *)nick
{
    [self.nicknameLabel setText:nick];
}

- (void)updateInfoFromUserManager
{
    [imageView clear];
    if ([userManager.avatarURL length] > 0){
        [imageView setUrl:[NSURL URLWithString:[userManager avatarURL]]];
    }
    else{
        [imageView setImage:[UIImage imageNamed:DEFAULT_AVATAR_BUNDLE]];
    }
    [GlobalGetImageCache() manage:imageView];
    [self updateNickname:[userManager nickName]];
    hasEdited = NO;
    avatarChanged = NO;
    languageChanged = NO;
    languageType = [userManager getLanguageType];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.updatePassword = nil;
        [self updateRowIndexs];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    userManager = [UserManager defaultManager];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [titleLabel setText:NSLS(@"kSettings")];
    [tableViewBG setImage:[imageManager whitePaperImage]];
    [saveButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [saveButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
    
    imageView = [[HJManagedImageV alloc] initWithFrame:avatarButton.bounds];
    [avatarButton addSubview:imageView];

    [self updateInfoFromUserManager];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setTableViewBG:nil];
    [self setAvatarButton:nil];
    [self setSaveButton:nil];
    [self setNicknameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rowNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier]autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
        [cell.textLabel setTextColor:[UIColor brownColor]];
    }
    NSInteger row = indexPath.row;
    if (row == rowOfPassword) {
        [cell.textLabel setText:NSLS(@"kPassword")];      
        if ([userManager isPasswordEmpty] && [self.updatePassword length] == 0) {
            [cell.detailTextLabel setText:NSLS(@"kUnset")];
        }else{
            [cell.detailTextLabel setText:nil];            
        }
    }else if(row == rowOfNickName)
    {
        [cell.textLabel setText:NSLS(@"kNickname")];           
        [cell.detailTextLabel setText:nicknameLabel.text];            
    }else if(row == rowOfLanguage)
    {
        [cell.textLabel setText:NSLS(@"kLanguageSettings")];     
        if (languageType == ChineseType) {
            [cell.detailTextLabel setText:NSLS(@"kChinese")];
        }else{
            [cell.detailTextLabel setText:NSLS(@"kEnglish")];
        }
    }else if(row == rowOfSinaWeibo)
    {
        [cell.textLabel setText:NSLS(@"kSinaWeibo")];              
        if ([userManager hasBindSinaWeibo]) {
            [cell.detailTextLabel setText:NSLS(@"kBind")];            
        }
    }else if(row == rowOfQQWeibo)
    {
        [cell.textLabel setText:NSLS(@"kQQWeibo")];    
        if ([userManager hasBindQQWeibo]) {
            [cell.detailTextLabel setText:NSLS(@"kBind")];            
        }
    }else if(row == rowOfFacebook)
    {
        [cell.textLabel setText:NSLS(@"kFacebook")];     
        if ([userManager hasBindFacebook]) {
            [cell.detailTextLabel setText:NSLS(@"kBind")];            
        }
    }
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    if (row == rowOfLanguage) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kLanguageSelection" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kChinese") otherButtonTitles:NSLS(@"kEnglish"), nil];
        LanguageType type = [userManager getLanguageType];
        [actionSheet setDestructiveButtonIndex:type - 1];
        [actionSheet showInView:self.view];
        [actionSheet release];        
    }else if(row == rowOfNickName)
    {
        InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kNickname") delegate:self];
        dialog.tag = DIALOG_TAG_NICKNAME;
        [dialog setTargetText:nicknameLabel.text];
        [dialog showInView:self.view];
    }else if(row == rowOfPassword)
    {
        PassWordDialog *dialog = [PassWordDialog dialogWith:NSLS(@"kPassword") delegate:self];
        dialog.tag = DIALOG_TAG_PASSWORD;
        [dialog showInView:self.view];
    }else if(row == rowOfSinaWeibo){
        //TODO bind Sina weibo
    }else if(row == rowOfQQWeibo){
        //TODO bind QQ Weibo
    }else if(row == rowOfFacebook){
        //TODO bind Facebook
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == [actionSheet cancelButtonIndex] || buttonIndex == [actionSheet destructiveButtonIndex]) {
        return;
    }else {
        languageType = buttonIndex + 1;
        languageChanged = YES;
    }
    [self.dataTableView reloadData];
}

- (IBAction)clickSaveButton:(id)sender {
    
    if (languageChanged) {
        [userManager setLanguageType:languageType];
        languageChanged = NO;
    }
    if (hasEdited) {
        UIImage *image = avatarChanged ?  imageView.image : nil;
        [[UserService defaultService] updateUserAvatar:image nickName:nicknameLabel.text gender:nil password:self.updatePassword viewController:self];        
    }else{
        [self popupHappyMessage:NSLS(@"kNoUpdate") title:nil];
    }
}

- (IBAction)clickAvatar:(id)sender {
    if (changeAvatar == nil) {
        changeAvatar = [[ChangeAvatar alloc] init];
        changeAvatar.autoRoundRect = NO;
    }
    [changeAvatar showSelectionView:self];
}

- (IBAction)clickBackButton:(id)sender {
    if (hasEdited) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotice") message:NSLS(@"kInfoUnSaved") style:CommonDialogStyleDoubleButton deelegate:self];
        [dialog showInView:self.view];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)clickOk:(CommonDialog *)dialog
{
    [dialog removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)clickBack:(CommonDialog *)dialog
{
    [dialog removeFromSuperview];    
}



- (void)didImageSelected:(UIImage*)image
{
    [self updateAvatar:image];
    avatarChanged = YES;
    hasEdited = YES;
}
- (void)dealloc {
    [titleLabel release];
    [tableViewBG release];
    [avatarButton release];
    [saveButton release];
    [imageView release];
    [changeAvatar release];
    [nicknameLabel release];
    [super dealloc];
}


- (void)clickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    if (dialog.tag == DIALOG_TAG_NICKNAME) {
        [self updateNickname:targetText];
        [self.dataTableView reloadData];
    }else if(dialog.tag == DIALOG_TAG_PASSWORD)
    {
        self.updatePassword = [targetText encodeMD5Base64:PASSWORD_KEY];        
        NSLog(@"password = %@", self.updatePassword);
    }
    hasEdited = YES;
    [self.dataTableView reloadData];

}
- (void)clickCancel:(InputDialog *)dialog
{
    [self.dataTableView reloadData];
}

#pragma mark - Password Dialog Delegate
- (void)passwordIsWrong:(NSString *)password
{
    [self popupHappyMessage:NSLS(@"kPasswordWrong") title:nil];    
}
- (void)twoInputDifferent
{
    [self popupHappyMessage:NSLS(@"kPasswordDifferent") title:nil];    
}
- (void)passwordIsIllegal:(NSString *)password
{
    [self popupHappyMessage:NSLS(@"kPasswordIllegal") title:nil];    
}

- (void)didUserUpdated:(int)resultCode
{
    if(resultCode == 0){
        [self updateInfoFromUserManager];
        [self.dataTableView reloadData];
    }else{

    }
}

@end
