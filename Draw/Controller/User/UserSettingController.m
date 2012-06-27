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
#import "LevelService.h"
#import "MyWordsController.h"
#import "StringUtil.h"

enum{
    SECTION_USER = 0,
    SECTION_ACCOUNT,
    SECTION_GUESSWORD,
    SECTION_SOUND,
    SECTION_COUNT
};

enum{
    ROW_EMAIL = 0,
    ROW_SINA_WEIBO,
    ROW_QQ_WEIBO,
    ROW_FACEBOOK,
    ROW_ACCOUNT_COUNT
};

enum {
    INDEX_OF_MALE = 0,
    INDEX_OF_FEMALE = 1
};


#define DIALOG_TAG_NICKNAME 201204071
#define DIALOG_TAG_PASSWORD 201204072
#define DIALOG_TAG_EMAIL    201206271

@implementation UserSettingController
@synthesize expAndLevelLabel;
@synthesize saveButton;
@synthesize titleLabel;
@synthesize avatarButton;
@synthesize tableViewBG;
@synthesize nicknameLabel;
@synthesize updatePassword = _updatePassword;
@synthesize gender = _gender;
@synthesize tempEmail = _tempEmail;

- (void)dealloc {
    PPRelease(_tempEmail);
    PPRelease(titleLabel);
    PPRelease(tableViewBG);
    PPRelease(avatarButton);
    PPRelease(saveButton);
    PPRelease(imageView);
    PPRelease(changeAvatar);
    PPRelease(nicknameLabel);
    PPRelease(_gender);
    [expAndLevelLabel release];
    [super dealloc];
}

- (void)updateRowIndexs
{
    //section user
    rowOfPassword = 0;
    rowOfGender = 1;
    rowOfNickName = 2;
    rowsInSectionUser = 3;
    
    //section guessword
    rowOfLanguage = 0;
    if (languageType == ChineseType) {
        rowOfLevel = 1;
        rowOfCustomWord = 2;
        rowsInSectionGuessWord = 3;
    }else {
        rowOfLevel = -1;
        rowOfCustomWord = -1;
        rowsInSectionGuessWord = 1;
    }
    
    //section sound
    rowOfSoundSwitcher = 0;
    rowOfMusicSettings = 1;
    rowOfVolumeSetting = 2;
    //rowOfChatVoice = 3;
    rowsInSectionSound = 3;
    
    rowsInSectionAccount = ROW_ACCOUNT_COUNT;
}

- (void)updateAvatar:(UIImage *)image
{
    [imageView setImage:image];
}

- (void)updateNickname:(NSString *)nick
{
    [self.nicknameLabel setText:nick];
}

- (void)askInputEmail:(NSString*)text
{
    InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kInputEmail") delegate:self];
    dialog.tag = DIALOG_TAG_EMAIL;
    [dialog setTargetText:text];
    [dialog.targetTextField setPlaceholder:NSLS(@"kInputEmail")];
    [dialog showInView:self.view];                    
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
    //chatVoice = [ConfigManager getChatVoiceEnable];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _userManager = [UserManager defaultManager];
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
    self.tempEmail = [userManager email];
    isSoundOn = [AudioManager defaultManager].isSoundOn;


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
    LevelService* svc = [LevelService defaultService];
    [self.expAndLevelLabel setText:[NSString stringWithFormat:NSLS(@"kLevelInfo"), svc.level, svc.experience, svc.expRequiredForNextLevel]];
    
    [dataTableView setBackgroundView:nil];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setTableViewBG:nil];
    [self setAvatarButton:nil];
    [self setSaveButton:nil];
    [self setNicknameLabel:nil];
    [self setExpAndLevelLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DeviceDetection isIPAD]) {
        return 96;
    }
    else {
        return 48;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_USER) {
        return rowsInSectionUser;
    } else if (section == SECTION_GUESSWORD) {
        return rowsInSectionGuessWord;
    } else if (section == SECTION_SOUND) {
        return rowsInSectionSound;
    } else if (section == SECTION_ACCOUNT){
        return rowsInSectionAccount;
    }
    else{
        return 0;
    }
}
#define SWITCHER_TAG 20120505
#define SLIDER_TAG 20120528
- (void)clickSoundSwitcher:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    isSoundOn = !btn.selected;
}

- (int)guessLevelToButtonIndex:(GuessLevel)level
{
    return level - 2;
}

- (GuessLevel)buttonIndexToGuessLevel:(int)buttonIndex
{
    return buttonIndex + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier]autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        int fontSize = 15;
        if ([DeviceDetection isIPAD]) {
            [cell.textLabel setFont:[UIFont systemFontOfSize:fontSize*2]];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:fontSize*2]];
        }else {
            [cell.textLabel setFont:[UIFont systemFontOfSize:fontSize]];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
        }
        [cell.textLabel setTextColor:[UIColor brownColor]];
        
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(220, 3.5, 70, 37)];
        [cell addSubview:btn];
        [btn setTag:SWITCHER_TAG];
        [btn setHidden:YES];
        [btn release];
        
        UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(100, 5, 184, 37)];
        [slider setValue:[[AudioManager defaultManager] volume]];
        [cell addSubview:slider];
        [slider setTag:SLIDER_TAG];
        [slider setHidden:YES];
        [slider release];
        
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UIView* btn = [cell viewWithTag:SWITCHER_TAG];
    if (btn) {
        [btn setHidden:YES];   
    }        
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UISlider* slider = (UISlider*)[cell viewWithTag:SLIDER_TAG];
    [slider setHidden:YES];
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    if (section == SECTION_USER) {
        if (row == rowOfPassword) {
            [cell.textLabel setText:NSLS(@"kPassword")];      
            if ([userManager isPasswordEmpty] && [self.updatePassword length] == 0) {
                [cell.detailTextLabel setText:NSLS(@"kUnset")];
            }else{
                [cell.detailTextLabel setText:nil];            
            }
        }else if (row == rowOfGender){
            [cell.textLabel setText:NSLS(@"kGender")];
            if ([self.gender isEqualToString:MALE]) {
                [cell.detailTextLabel setText:NSLS(@"kMale")];
            }else{
                [cell.detailTextLabel setText:NSLS(@"kFemale")];
            }
            [cell.detailTextLabel setHidden:NO];
        }else if(row == rowOfNickName)
        {
            [cell.textLabel setText:NSLS(@"kNickname")];           
            [cell.detailTextLabel setText:nicknameLabel.text];            
        }
    }else if (section == SECTION_GUESSWORD) {
        if(row == rowOfLanguage)
        {
            [cell.textLabel setText:NSLS(@"kLanguageSettings")];     
            if (languageType == ChineseType) {
                [cell.detailTextLabel setText:NSLS(@"kChinese")];
            }else{
                [cell.detailTextLabel setText:NSLS(@"kEnglish")];
            }
        }else if(row == rowOfLevel){
            [cell.textLabel setText:NSLS(@"kLevelSettings")];     
            if (guessLevel == EasyLevel) {
                [cell.detailTextLabel setText:NSLS(@"kEasyLevel")];
            }else if(guessLevel == NormalLevel){
                [cell.detailTextLabel setText:NSLS(@"kNormalLevel")];
            }else{
                [cell.detailTextLabel setText:NSLS(@"kHardLevel")];
            }
            [cell.detailTextLabel setHidden:NO];
        }else if(row == rowOfCustomWord){
            [cell.textLabel setText:NSLS(@"kCustomWordManage")]; 
        }
    } else if (section == SECTION_SOUND) {
        if(row == rowOfSoundSwitcher) 
        {
            [cell.textLabel setText:NSLS(@"kSound")];
            UIButton* btn = (UIButton*)[cell viewWithTag:SWITCHER_TAG];
            if (btn) {
                [btn setHidden:NO];   
            }
            [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
            if ([DeviceDetection isIPAD]) {
                btn.frame = CGRectMake(266*2, 3.5*2, 70*2, 37*2);
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
            
            [btn setSelected:!isSoundOn];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.detailTextLabel setText:nil];
        }else if (row == rowOfMusicSettings) {
            [cell.textLabel setText:NSLS(@"kBackgroundMusic")];
            [cell.detailTextLabel setHidden:YES];
        } else if (row == rowOfVolumeSetting) {
            [cell.textLabel setText:NSLS(@"kVolume")];
            [cell.detailTextLabel setHidden:YES];
            UISlider* slider = (UISlider*)[cell viewWithTag:SLIDER_TAG];
            [slider addTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [slider setHidden:NO];
            if ([DeviceDetection isIPAD]) {
                [slider setFrame:CGRectMake(148*2, 5*2, 184*2, 37*2)];
            }
        } 
//        else if (row == rowOfChatVoice) {
//            [cell.textLabel setText:NSLS(@"kChatVoice")];
//            if (chatVoice == EnableAlways) {
//                [cell.detailTextLabel setText:NSLS(@"kEnableAlways")];
//            } else if (chatVoice == EnableWifi) {
//                [cell.detailTextLabel setText:NSLS(@"kEnableWifi")];
//            }else if (chatVoice == EnableNot){
//                [cell.detailTextLabel setText:NSLS(@"kEnableNot")];
//            }
//            [cell.detailTextLabel setHidden:NO];
//        }
    }
    else if (section == SECTION_ACCOUNT){
                        
        [cell.detailTextLabel setHidden:NO];
        switch (row) {
            case ROW_EMAIL:
            {
                [cell.textLabel setText:NSLS(@"kSetEmail")];
                if ([_tempEmail length] > 0){
                    [cell.detailTextLabel setText:_tempEmail];
                }
                else{
                    [cell.detailTextLabel setText:NSLS(@"kEmailNotSet")];
                }
            }
                break;
            case ROW_SINA_WEIBO:
            {
                [cell.textLabel setText:NSLS(@"kSetSinaWeibo")];
                if ([_userManager hasBindSinaWeibo]){
                    [cell.detailTextLabel setText:NSLS(@"kWeiboSet")];
                }
                else{
                    [cell.detailTextLabel setText:NSLS(@"kNotSet")];
                }                
            }
                break;
                
            case ROW_QQ_WEIBO:
            {
                [cell.textLabel setText:NSLS(@"kSetQQWeibo")];
                if ([_userManager hasBindQQWeibo]){
                    [cell.detailTextLabel setText:NSLS(@"kWeiboSet")];
                }
                else{
                    [cell.detailTextLabel setText:NSLS(@"kNotSet")];
                }                
            }
                break;
                
            case ROW_FACEBOOK:
            {
                [cell.textLabel setText:NSLS(@"kSetFacebook")];
                if ([_userManager hasBindFacebook]){
                    [cell.detailTextLabel setText:NSLS(@"kWeiboSet")];
                }
                else{
                    [cell.detailTextLabel setText:NSLS(@"kNotSet")];
                }                
            }
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

- (void)changeVolume:(id)sender
{
    UISlider* slider = (UISlider*)sender;
    float volume = slider.value;
    [[AudioManager defaultManager] setVolume:volume];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}


#define LANGUAGE_TAG 123
#define LEVEL_TAG 124
#define GENDER_TAG 125
#define CHAT_VOICE_TAG 126

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (section == SECTION_USER) {
        if (row == rowOfPassword) {
            PassWordDialog *dialog = [PassWordDialog dialogWith:NSLS(@"kPassword") delegate:self];
            dialog.tag = DIALOG_TAG_PASSWORD;
            [dialog showInView:self.view];
            
        }else if (row == rowOfGender){
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kGender" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kMale") otherButtonTitles:NSLS(@"kFemale"), nil];
            int index = ([self.gender isEqualToString:MALE]) ? INDEX_OF_MALE : INDEX_OF_FEMALE;
            [actionSheet setDestructiveButtonIndex:index];
            [actionSheet showInView:self.view];
            actionSheet.tag = GENDER_TAG;
            [actionSheet release];
            
        }else if(row == rowOfNickName){
            InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kNickname") delegate:self];
            dialog.tag = DIALOG_TAG_NICKNAME;
            [dialog setTargetText:nicknameLabel.text];
            [dialog showInView:self.view];
        }
    
    }else if (section == SECTION_GUESSWORD) {
        if(row == rowOfLanguage){
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kLanguageSelection" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kChinese") otherButtonTitles:NSLS(@"kEnglish"), nil];
            //        LanguageType type = [userManager getLanguageType];
            [actionSheet setDestructiveButtonIndex:languageType - 1];
            [actionSheet showInView:self.view];
            actionSheet.tag = LANGUAGE_TAG;
            [actionSheet release]; 
        }else if(row == rowOfLevel){
//       UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kLevelSelection" ) 
//                                                                delegate:self 
//                                                       cancelButtonTitle:NSLS(@"kCancel") 
//                                                  destructiveButtonTitle:NSLS(@"kEasyLevel") 
//                                                       otherButtonTitles:NSLS(@"kNormalLevel"),NSLS(@"kHardLevel"), nil];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kLevelSelection" ) 
                                                                     delegate:self 
                                                            cancelButtonTitle:NSLS(@"kCancel") 
                                                       destructiveButtonTitle:NSLS(@"kNormalLevel") 
                                                            otherButtonTitles:NSLS(@"kHardLevel"), nil];
            
            [actionSheet setDestructiveButtonIndex:[self guessLevelToButtonIndex:guessLevel]];
            [actionSheet showInView:self.view];
            actionSheet.tag = LEVEL_TAG;
            [actionSheet release];    
        }else if(row == rowOfCustomWord){
            MyWordsController *controller = [[MyWordsController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
    }else if (section == SECTION_SOUND) {
        if(row == rowOfSoundSwitcher) {
            //no action
        }else if (row == rowOfMusicSettings) {
            MusicSettingController *controller = [[MusicSettingController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        } else if (row == rowOfVolumeSetting) {
            //no action
        } 
        
//        else if (row == rowOfChatVoice) {
//            UIActionSheet *selectChatVoiceSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kChatVoice") 
//                                                                              delegate:self 
//                                                                     cancelButtonTitle:NSLS(@"kCancel") 
//                                                                destructiveButtonTitle:NSLS(@"kEnableAlways") 
//                                                                     otherButtonTitles:NSLS(@"kEnableWifi"), NSLS(@"kEnableNot"), nil];
//            selectChatVoiceSheet.tag = CHAT_VOICE_TAG;
//            [selectChatVoiceSheet setDestructiveButtonIndex:chatVoice - 1];
//            [selectChatVoiceSheet showInView:self.view];
//            [selectChatVoiceSheet release];
//        }
    }
    else if (section == SECTION_ACCOUNT){
        
        switch (row) {
            case ROW_EMAIL:
            {
                [self askInputEmail:_tempEmail];
            }
                break;
            case ROW_SINA_WEIBO:
            {
                if ([_userManager hasBindSinaWeibo]){
                    
                }
            }
                break;
                
            case ROW_QQ_WEIBO:
            {
            }
                break;
                
            case ROW_FACEBOOK:
            {
            }
                break;
                
            default:
                break;
        }
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
            guessLevel = [self buttonIndexToGuessLevel:buttonIndex];
        } else  if (actionSheet.tag == GENDER_TAG) {
            if (buttonIndex != actionSheet.destructiveButtonIndex) {
                hasEdited = YES;
            }
            self.gender = (buttonIndex == INDEX_OF_MALE) ? MALE : FEMALE;
        }
        
//        else if (actionSheet.tag == CHAT_VOICE_TAG) {
//            chatVoice = buttonIndex + 1;
//        }
    }
    [self updateRowIndexs];
    [self.dataTableView reloadData];
}

- (BOOL)isLocalChanged
{    
    BOOL localChanged = (languageType != [userManager getLanguageType]) 
    || (guessLevel != [ConfigManager guessDifficultLevel] || ([userManager gender] != nil && ![self.gender isEqualToString:[userManager gender]]) || [AudioManager defaultManager].isSoundOn != isSoundOn);
    return localChanged;
}

- (IBAction)clickSaveButton:(id)sender {
    
    BOOL localChanged = [self isLocalChanged];

    if (localChanged) {
        [userManager setLanguageType:languageType];
        [ConfigManager setGuessDifficultLevel:guessLevel];
        [userManager setGender:self.gender];
        [[AudioManager defaultManager] setIsSoundOn:isSoundOn];
        //[ConfigManager setChatVoiceEnable:chatVoice];
        if (!hasEdited) {
            [self popupHappyMessage:NSLS(@"kUpdateUserSucc") title:@""];            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if (hasEdited) {
        UIImage *image = avatarChanged ?  imageView.image : nil;
        [[UserService defaultService] updateUserAvatar:image 
                                              nickName:nicknameLabel.text 
                                                gender:self.gender 
                                              password:self.updatePassword          
                                                 email:_tempEmail
                                        viewController:self];               
        
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
        hasEdited = YES;
    }
    else if(dialog.tag == DIALOG_TAG_PASSWORD)
    {
        self.updatePassword = [targetText encodeMD5Base64:PASSWORD_KEY];        
        hasEdited = YES;
    }
    else if (dialog.tag == DIALOG_TAG_EMAIL){
        if (NSStringIsValidEmail(targetText)){
            self.tempEmail = targetText;            
            hasEdited = YES;
        }
        else{
            [self popupMessage:NSLS(@"kEmailNotValid") title:@""];
            [self askInputEmail:targetText];
        }
    }
    
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
