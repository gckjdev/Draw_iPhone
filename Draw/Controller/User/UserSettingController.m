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
#import "DeviceDetection.h"
#import "AudioManager.h"
#import "DeviceDetection.h"
#import "MusicSettingController.h"

enum{
    SECTION_LANGUAGE = 0,
    SECTION_COUNT
};

enum {
    INDEX_OF_MALE = 0,
    INDEX_OF_FEMALE = 1
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
@synthesize gender = _gender;

- (void)dealloc {
    PPRelease(titleLabel);
    PPRelease(tableViewBG);
    PPRelease(avatarButton);
    PPRelease(saveButton);
    PPRelease(imageView);
    PPRelease(changeAvatar);
    PPRelease(nicknameLabel);
    PPRelease(_gender);
    [super dealloc];
}

- (void)updateRowIndexs
{
    rowOfPassword = 0;
    rowOfGender = 1;
    rowOfNickName = 2;
    rowOfLanguage = 3;
    
    if (languageType == ChineseType) {
        rowOfLevel = 4;
        rowOfSoundSwitcher = 5;
        rowOfMusicSettings = 6;
        rowOfVolumeSetting = 7;
        rowNumber = 8;        
    }else{
        rowOfLevel = -1;
        rowOfSoundSwitcher = 4;
        rowOfMusicSettings = 5;
        rowOfVolumeSetting = 6;
        rowNumber = 7;
    }
    
    
    
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
    userManager = [UserManager defaultManager];
    [imageView clear];
    if ([userManager.avatarURL length] > 0){
        [imageView setUrl:[NSURL URLWithString:[userManager avatarURL]]];
    }
    else{
        [imageView setImage:[UIImage imageNamed:[userManager defaultAvatar]]];
    }
    [GlobalGetImageCache() manage:imageView];
    [self updateNickname:[userManager nickName]];
    self.updatePassword = nil;
    hasEdited = NO;
    avatarChanged = NO;
    languageType = [userManager getLanguageType];
    self.gender = [userManager gender];
    guessLevel = [ConfigManager guessDifficultLevel];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    [saveButton setBackgroundImage:[imageManager orangeImage] 
                          forState:UIControlStateNormal];
    [saveButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
    imageView = [[HJManagedImageV alloc] initWithFrame:avatarButton.bounds];
    [avatarButton addSubview:imageView];
    
    [self updateInfoFromUserManager];
    [self updateRowIndexs];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DeviceDetection isIPAD]) {
        return 98;
    }
    else {
        return 49;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rowNumber;
}
#define SWITCHER_TAG 20120505
#define SLIDER_TAG 20120528
- (void)clickSoundSwitcher:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    isSoundOn = !btn.selected;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier]autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if ([DeviceDetection isIPAD]) {
            [cell.textLabel setFont:[UIFont systemFontOfSize:36]];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:36]];
        }else {
            [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:18]];
        }
        [cell.textLabel setTextColor:[UIColor brownColor]];
        
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(194, 3.5, 70, 37)];
        [cell addSubview:btn];
        [btn setTag:SWITCHER_TAG];
        [btn setHidden:YES];
        [btn release];
        
        UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(64, 5, 180, 37)];
        [slider setValue:[[AudioManager defaultManager] volume]];
        [cell addSubview:slider];
        [slider setTag:SLIDER_TAG];
        [slider setHidden:YES];
        [slider release];
        
    }
    NSInteger row = indexPath.row;
    UIView* btn = [cell viewWithTag:SWITCHER_TAG];
    if (btn) {
        [btn setHidden:YES];   
    }        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (row == rowOfPassword) {
        [cell.textLabel setText:NSLS(@"kPassword")];      
        if ([userManager isPasswordEmpty] && [self.updatePassword length] == 0) {
            [cell.detailTextLabel setText:NSLS(@"kUnset")];
        }else{
            [cell.detailTextLabel setText:nil];            
        }
        UISlider* slider = (UISlider*)[cell viewWithTag:SLIDER_TAG];
        [slider setHidden:YES];
        [cell.detailTextLabel setHidden:NO];
    }else if (row == rowOfGender){
        [cell.textLabel setText:NSLS(@"kGender")];
        if ([self.gender isEqualToString:MALE]) {
            [cell.detailTextLabel setText:NSLS(@"kMale")];
        }else{
            [cell.detailTextLabel setText:NSLS(@"kFemale")];
        }
        UISlider* slider = (UISlider*)[cell viewWithTag:SLIDER_TAG];
        [slider setHidden:YES];
        [cell.detailTextLabel setHidden:NO];
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
    }else if(row == rowOfSoundSwitcher) 
    {
        [cell.textLabel setText:NSLS(@"kSound")];
        UIButton* btn = (UIButton*)[cell viewWithTag:SWITCHER_TAG];
        if (btn) {
            [btn setHidden:NO];   
        }
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        if ([DeviceDetection isIPAD]) {
            btn.frame = CGRectMake(194*2, 3.5*2, 70*2, 37*2);
            [btn.titleLabel setFont:[UIFont systemFontOfSize:24]];
        }
        [btn setBackgroundImage:[UIImage imageNamed:@"volume_on.png"] forState:UIControlStateNormal];
        [btn setTitle:NSLS(@"kON") forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"volume_off.png"] forState:UIControlStateSelected];
        [btn setTitle:NSLS(@"kOFF") forState:UIControlStateSelected];
        [btn.titleLabel setTextAlignment:UITextAlignmentCenter];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];        
        [btn addTarget:self action:@selector(clickSoundSwitcher:) forControlEvents:UIControlEventTouchUpInside];
        isSoundOn = [AudioManager defaultManager].isSoundOn;
        [btn setSelected:!isSoundOn];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.detailTextLabel setText:nil];
    }else if(row == rowOfLevel){
        [cell.textLabel setText:NSLS(@"kLevelSettings")];     
        if (guessLevel == EasyLevel) {
            [cell.detailTextLabel setText:NSLS(@"kEasyLevel")];
        }else if(guessLevel == NormalLevel){
            [cell.detailTextLabel setText:NSLS(@"kNormalLevel")];
        }else{
            [cell.detailTextLabel setText:NSLS(@"kHardLevel")];
        }
        UISlider* slider = (UISlider*)[cell viewWithTag:SLIDER_TAG];
        [slider setHidden:YES];
        [cell.detailTextLabel setHidden:NO];
    }else if (row == rowOfMusicSettings) {
        [cell.textLabel setText:NSLS(@"kBackgroundMusic")];
        UISlider* slider = (UISlider*)[cell viewWithTag:SLIDER_TAG];
        [slider setHidden:YES];
        [cell.detailTextLabel setHidden:YES];
    } else if (row == rowOfVolumeSetting) {
        [cell.textLabel setText:NSLS(@"kVolume")];
        [cell.detailTextLabel setHidden:YES];
        UISlider* slider = (UISlider*)[cell viewWithTag:SLIDER_TAG];
        [slider addTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [slider setHidden:NO];
        if ([DeviceDetection isIPAD]) {
            [slider setFrame:CGRectMake(64*2, 5*2, 180*2, 37*2)];
        }
        
    }
    return cell;
}

- (void)changeVolume:(id)sender
{
    UISlider* slider = (UISlider*)sender;
    float volume = slider.value;
    [[AudioManager defaultManager] setBGMVolume:volume];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}


#define LANGUAGE_TAG 123
#define LEVEL_TAG 124
#define GENDER_TAG 125

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    if (row == rowOfLanguage) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kLanguageSelection" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kChinese") otherButtonTitles:NSLS(@"kEnglish"), nil];
//        LanguageType type = [userManager getLanguageType];
        [actionSheet setDestructiveButtonIndex:languageType - 1];
        [actionSheet showInView:self.view];
        actionSheet.tag = LANGUAGE_TAG;
        [actionSheet release];        
    }else if (row == rowOfLevel) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kLevelSelection" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kEasyLevel") otherButtonTitles:NSLS(@"kNormalLevel"),NSLS(@"kHardLevel"), nil];
        [actionSheet setDestructiveButtonIndex:guessLevel - 1];
        [actionSheet showInView:self.view];
        actionSheet.tag = LEVEL_TAG;
        [actionSheet release];        
    } else if (row == rowOfGender) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kGender" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kMale") otherButtonTitles:NSLS(@"kFemale"), nil];
        int index = ([self.gender isEqualToString:MALE]) ? INDEX_OF_MALE : INDEX_OF_FEMALE;
        [actionSheet setDestructiveButtonIndex:index];
        [actionSheet showInView:self.view];
        actionSheet.tag = GENDER_TAG;
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
    }else if (row == rowOfMusicSettings) {
        MusicSettingController *controller = [[MusicSettingController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == [actionSheet cancelButtonIndex] || buttonIndex == [actionSheet destructiveButtonIndex]) {
        
    }else {
        if (actionSheet.tag == LANGUAGE_TAG) {
            languageType = buttonIndex + 1;
        }else if(actionSheet.tag == LEVEL_TAG){
            guessLevel = buttonIndex + 1;
        } else  if (actionSheet.tag == GENDER_TAG) {
            if (buttonIndex != actionSheet.destructiveButtonIndex) {
                hasEdited = YES;
            }
            self.gender = (buttonIndex == INDEX_OF_MALE) ? MALE : FEMALE;
        }
    }
    [self updateRowIndexs];
    [self.dataTableView reloadData];
}

- (BOOL)isLocalChanged
{    
    BOOL localChanged = (languageType != [userManager getLanguageType]) 
    || (guessLevel != [ConfigManager guessDifficultLevel] || ![self.gender isEqualToString:[userManager gender]] || [AudioManager defaultManager].isSoundOn != isSoundOn);
    return localChanged;
}

- (IBAction)clickSaveButton:(id)sender {
    
    BOOL localChanged = [self isLocalChanged];

    if (localChanged) {
        [userManager setLanguageType:languageType];
        [ConfigManager setGuessDifficultLevel:guessLevel];
        [userManager setGender:self.gender];
        [[AudioManager defaultManager] setIsSoundOn:isSoundOn];
        if (!hasEdited) {
            [self popupHappyMessage:NSLS(@"kUpdateUserSucc") title:@""];            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if (hasEdited) {
        UIImage *image = avatarChanged ?  imageView.image : nil;
        [[UserService defaultService] updateUserAvatar:image nickName:nicknameLabel.text gender:self.gender password:self.updatePassword viewController:self];        
    }else if(!localChanged){
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
    BOOL localChanged = [self isLocalChanged];
    if (localChanged || hasEdited) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotice") message:NSLS(@"kInfoUnSaved") style:CommonDialogStyleDoubleButton delegate:self];
        [dialog showInView:self.view];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)clickOk:(CommonDialog *)dialog
{
//    [dialog removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)clickBack:(CommonDialog *)dialog
{
//    [dialog removeFromSuperview];    
}



- (void)didImageSelected:(UIImage*)image
{
    [self updateAvatar:image];
    avatarChanged = YES;
    hasEdited = YES;
}


- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
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
- (void)didClickCancel:(InputDialog *)dialog
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
        [self.navigationController popViewControllerAnimated:YES];
    }else{

    }
}

@end
