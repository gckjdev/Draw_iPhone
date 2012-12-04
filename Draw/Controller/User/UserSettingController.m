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
#import "GameNetworkConstants.h"
#import "AdService.h"
#import "CustomDiceSettingViewController.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSCommonService.h"
#import "PPSNSConstants.h"
#import "GameSNSService.h"

enum{
    SECTION_USER = 0,
    SECTION_REMOVE_AD,
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


#define DIALOG_TAG_NICKNAME         201204071
#define DIALOG_TAG_PASSWORD         201204072
#define DIALOG_TAG_EMAIL            201206271
#define DIALOG_TAG_REBIND_QQ        201206281
#define DIALOG_TAG_REBIND_SINA      201206282
#define DIALOG_TAG_REBIND_FACEBOOK  201206283

@interface UserSettingController()

- (void)bindFacebook;
- (void)bindSina;
- (void)bindQQ;
- (void)askRebindFacebook;
- (void)askRebindQQ;
- (void)askRebindSina;

@end

@implementation UserSettingController

@synthesize backgroundImage;
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
    PPRelease(expAndLevelLabel);
    PPRelease(backgroundImage);
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
    if (isDrawApp()) {
        //no matter what the language is, the level is normal.
        if (languageType == ChineseType) {
            rowOfLanguage = 0;
            rowOfLevel = -1;
            rowOfCustomWord = 1;
            rowOfAutoSave = 2,
            rowsInSectionGuessWord = 2;//hide autosave --kira
        }else {
            rowOfLanguage = 0;
            rowOfLevel = -1;
            rowOfCustomWord = -1;
            rowOfAutoSave = 1,
            rowsInSectionGuessWord = 1;//hide autosave--kira
        }
    } else if (isDiceApp()) {
        rowsInSectionGuessWord = 0;
        rowOfCustomDice = 3;
        rowsInSectionUser = 4; //add custom dice 
    }

    
    //section sound
    rowOfSoundSwitcher = 0;
    rowOfVolumeSetting = 1;
    rowOfMusicSettings = 2;
    //rowOfChatVoice = 3;
    rowsInSectionSound = isDrawApp()?3:2;//TODO:hide custom music in dice, fix it later
    
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
    isMusicOn = [AudioManager defaultManager].isMusicOn;
    isAutoSave = [ConfigManager isAutoSave];

    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    
    
//    [self.backgroundImage setImage:[UIImage imageNamed:@"gameroom_bg.png"]];
//    if ([ConfigManager isLiarDice]){
//        
//    }
    
    [self.backgroundImage setImage:[UIImage imageNamed:[GameApp background]]];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setTableViewBG:nil];
    [self setAvatarButton:nil];
    [self setSaveButton:nil];
    [self setNicknameLabel:nil];
    [self setExpAndLevelLabel:nil];
    [self setBackgroundImage:nil];
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
    else if (section == SECTION_REMOVE_AD){
        return 1;
    }
    else{
        return 0;
    }
}
#define SOUND_SWITCHER_TAG 20120505
#define MUSIC_SWITCHER_TAG 20120528
#define DRAW_AUTOSAVE_TAG 20120926
- (void)clickSoundSwitcher:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    isSoundOn = !btn.selected;
    [[AudioManager defaultManager] setIsSoundOn:isSoundOn];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (void)clickMusicSwitcher:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    isMusicOn = !btn.selected;
    [[AudioManager defaultManager] setIsMusicOn:isMusicOn];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (void)clickAutoSaveSwitcher:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    isAutoSave = !btn.selected;
    [ConfigManager setAutoSave:isAutoSave];
}


- (int)guessLevelToButtonIndex:(GuessLevel)level
{
    return level - 2;
}

- (GuessLevel)buttonIndexToGuessLevel:(int)buttonIndex
{
    return buttonIndex + 2;
}

- (void)initSwitcher:(UIButton*)btn
{
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

- (UIButton *)addSwitchButtonWithTag:(NSInteger)tag toCell:(UITableViewCell *)cell
{
    [self clearSwitchInCell:cell];
    cell.accessoryType = UITableViewCellAccessoryNone;
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(220, 3.5, 70, 37)];
    [cell.contentView addSubview:btn];
    [self initSwitcher:btn];
    [btn setTag:tag];
    [btn release];
    return btn;
}


- (UITableViewCell*)createCellByIdentifier:(NSString*)cellIdentifier
{
    UITableViewCell* cell;
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
    return cell;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [self createCellByIdentifier:cellIdentifier];        
    }else{
        [self clearSwitchInCell:cell];
    }
    [cell.detailTextLabel setText:nil];  
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == SECTION_USER) {
        if (row == rowOfPassword) {
            [cell.textLabel setText:NSLS(@"kPassword")];      
            if ([userManager isPasswordEmpty] && [self.updatePassword length] == 0) {
                [cell.detailTextLabel setText:NSLS(@"kUnset")];
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
        } else if (row == rowOfCustomDice) {
            [cell.textLabel setText:NSLS(@"kCustomDice")];
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
        }else if(row == rowOfAutoSave){
            [cell.textLabel setText:NSLS(@"kAutoSave")]; 
            [cell.detailTextLabel setText:nil];
            UIButton *btn = [self addSwitchButtonWithTag:DRAW_AUTOSAVE_TAG toCell:cell];
            [btn addTarget:self action:@selector(clickAutoSaveSwitcher:) forControlEvents:UIControlEventTouchUpInside];
            [btn setSelected:!isAutoSave];            

        }
    } else if (section == SECTION_SOUND) {
        if(row == rowOfSoundSwitcher) 
        {
            [cell.textLabel setText:NSLS(@"kSound")];
            [cell.detailTextLabel setText:nil];
            UIButton *btn = [self addSwitchButtonWithTag:SOUND_SWITCHER_TAG toCell:cell];
            [btn addTarget:self action:@selector(clickSoundSwitcher:) forControlEvents:UIControlEventTouchUpInside];
            [btn setSelected:!isSoundOn];            

        }else if (row == rowOfMusicSettings) {
            [cell.textLabel setText:NSLS(@"kCustomMusic")];
            [cell.detailTextLabel setHidden:YES];
        } else if (row == rowOfVolumeSetting) {
            [cell.textLabel setText:NSLS(@"kBackgroundMusic")];
            [cell.detailTextLabel setText:nil];
            UIButton *btn = [self addSwitchButtonWithTag:MUSIC_SWITCHER_TAG toCell:cell];
            [btn addTarget:self action:@selector(clickMusicSwitcher:) forControlEvents:UIControlEventTouchUpInside];
            [btn setSelected:!isMusicOn];            
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
                    if ([[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]){
                        [cell.detailTextLabel setText:NSLS(@"kWeiboExpired")];
                    }
                    else{
                        [cell.detailTextLabel setText:NSLS(@"kWeiboSet")];
                    }
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
                    if ([[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]){
                        [cell.detailTextLabel setText:NSLS(@"kWeiboExpired")];
                    }
                    else{
                        [cell.detailTextLabel setText:NSLS(@"kWeiboSet")];
                    }
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
                    if ([[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]){
                        [cell.detailTextLabel setText:NSLS(@"kWeiboExpired")];
                    }
                    else{
                        [cell.detailTextLabel setText:NSLS(@"kWeiboSet")];
                    }
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
    else if (section == SECTION_REMOVE_AD) {
        cell.textLabel.text = NSLS(@"kRemoveAd");
        cell.detailTextLabel.hidden = NO;
        if ([ConfigManager isProVersion]){
            cell.detailTextLabel.text = @"N/A";
        }
        else{
            cell.detailTextLabel.text = ([[AdService defaultService] isShowAd] ? NSLS(@"kAdNotRemoved") : NSLS(@"kAdRemoved"));
        }
    }
    
    return cell;
}

- (void)changeVolume:(id)sender
{
    UISlider* slider = (UISlider*)sender;
    float volume = slider.value;
    [[AudioManager defaultManager] setVolume:volume];
    [[AudioManager defaultManager] saveSoundSettings];
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
        } else if (row == rowOfCustomDice){
            CustomDiceSettingViewController* controller = [[[CustomDiceSettingViewController alloc] init] autorelease];
            [self.navigationController pushViewController:controller animated:YES];
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
                if ([_userManager hasBindSinaWeibo] == NO || [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]){
                    [self bindSina];
                }
                else{
                    [self askRebindSina];                                        
                }
            }
                break;
                
            case ROW_QQ_WEIBO:
            {
                if ([_userManager hasBindQQWeibo]){
                    [self askRebindQQ];                    
                }
                else{
                    [self bindQQ];                    
                }
            }
                break;
                
            case ROW_FACEBOOK:
            {
                
                if ([_userManager hasBindFacebook] == NO || [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]){
                    [self bindFacebook];
                }
                else{
                    [self askRebindFacebook];
                }
            }
                break;
                
            default:
                break;
        }
    }    
    else if (section == SECTION_REMOVE_AD) {
        if ([ConfigManager isProVersion]){            
        }
        else{
            [[AdService defaultService] requestRemoveAd:self];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#define FOLLOW_SINA_KEY @"FOLLOW_SINA_KEY"
#define FOLLOW_QQ_KEY   @"FOLLOW_QQ_KEY"

- (void)askFollow
{
    switch (_currentLoginType){
        case REGISTER_TYPE_QQ:
        {
//            [[QQWeiboService defaultService] askFollow];
        }
            break;
        case REGISTER_TYPE_SINA:
        {
//            [[SinaSNSService defaultService] askFollow];
            break;
        }
        default:
            break;
    }
    
}



#pragma mark - SNS Delegate

- (void)didLogin:(int)result userInfo:(NSDictionary*)userInfo
{        
    if (result == 0){
        [[UserService defaultService] updateUserWithSNSUserInfo:[userManager userId] userInfo:userInfo viewController:self];
        
        // ask to follow user
        [self askFollow];
    }

    self.navigationController.navigationBarHidden = YES;        
}

- (void)didUserRegistered:(int)resultCode
{
    if (resultCode == 0){
        [self popupMessage:NSLS(@"kUserBindSucc") title:nil];
    }
    else{
        [self popupMessage:NSLS(@"kUserBindFail") title:nil];
    }
    
    self.navigationController.navigationBarHidden = YES;    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)bindSNS:(int)snsType
{
    PPSNSCommonService* service = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    NSString* name = [service snsName];
    
    [service login:^(NSDictionary *userInfo) {
        PPDebug(@"%@ Login Success", name);
        
        [self showActivityWithText:NSLS(@"Loading")];
        
        [service readMyUserInfo:^(NSDictionary *userInfo) {
            [self hideActivity];
            PPDebug(@"%@ readMyUserInfo Success, userInfo=%@", name, [userInfo description]);
            [[UserService defaultService] updateUserWithSNSUserInfo:[userManager userId] userInfo:userInfo viewController:self];
            
            // ask follow official weibo account here
            [GameSNSService askFollow:snsType snsWeiboId:[service officialWeiboId]];
            
        } failureBlock:^(NSError *error) {
            [self hideActivity];
            PPDebug(@"%@ readMyUserInfo Failure", name);
        }];
        
    } failureBlock:^(NSError *error) {
        PPDebug(@"%@ Login Failure", name);
    }];
}

- (void)bindQQ
{
    [self bindSNS:TYPE_QQ];
}

- (void)bindSina
{   
    [self bindSNS:TYPE_SINA];
}

- (void)bindFacebook
{
    /*
    _currentLoginType = REGISTER_TYPE_FACEBOOK;
    [[FacebookSNSService defaultService] startLogin:self];                        
    */

    // TODO facebook not tested
    [self bindSNS:TYPE_FACEBOOK];
}

- (void)askRebindQQ
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindQQ") style:CommonDialogStyleDoubleButton delegate:self];
    dialog.tag = DIALOG_TAG_REBIND_QQ;
    [dialog showInView:self.view];
}

- (void)askRebindSina
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindSina") style:CommonDialogStyleDoubleButton delegate:self];
    dialog.tag = DIALOG_TAG_REBIND_SINA;
    [dialog showInView:self.view];    
}

- (void)askRebindFacebook
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindFacebook") style:CommonDialogStyleDoubleButton delegate:self];
    dialog.tag = DIALOG_TAG_REBIND_FACEBOOK;
    [dialog showInView:self.view];    
}

#pragma mark - SNS End

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
//    UISlider* slider = (UISlider*)[self.view viewWithTag:SLIDER_TAG];
    BOOL localChanged = (languageType != [userManager getLanguageType]) 
    || (guessLevel != [ConfigManager guessDifficultLevel] || ([userManager gender] != nil && ![self.gender isEqualToString:[userManager gender]]));
    return localChanged;
}

- (IBAction)clickSaveButton:(id)sender {
    
    BOOL localChanged = [self isLocalChanged];

    if (localChanged) {
        [userManager setLanguageType:languageType];
        [ConfigManager setGuessDifficultLevel:guessLevel];
        [userManager setGender:self.gender];
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
//    [[AudioManager defaultManager] saveSoundSettings];
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
    switch (dialog.tag) {
        case DIALOG_TAG_REBIND_FACEBOOK:
            [self bindFacebook];
            return;

        case DIALOG_TAG_REBIND_QQ:
            [self bindQQ];
            return;
            
        case DIALOG_TAG_REBIND_SINA:
            [self bindSina];
            return;
            
        default:
            break;
    }
    
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
