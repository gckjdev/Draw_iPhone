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
#import "PassWordDialog.h"
#import "StringUtil.h"
#import "DeviceDetection.h"
#import "AudioManager.h"
#import "DeviceDetection.h"
#import "LevelService.h"
#import "MyWordsController.h"
#import "StringUtil.h"
#import "GameNetworkConstants.h"
#import "AdService.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSCommonService.h"
#import "PPSNSConstants.h"
#import "GameSNSService.h"
#import "MKBlockActionSheet.h"
#import "GCDatePickerView.h"
#import "TimeUtils.h"
#import "UIImageView+WebCache.h"
#import "CommonMessageCenter.h"
#import "GeographyService.h"
#import "UserSettingCell.h"


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


#define DIALOG_TAG_NICKNAME         201204071
#define DIALOG_TAG_PASSWORD         201204072
#define DIALOG_TAG_EMAIL            201206271
#define DIALOG_TAG_REBIND_QQ        201206281
#define DIALOG_TAG_REBIND_SINA      201206282
#define DIALOG_TAG_REBIND_FACEBOOK  201206283
#define DIALOG_TAG_SIGNATURE  201206284

@interface UserSettingController()<PassWordDialogDelegate>

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

- (void)dealloc {
    PPRelease(_pbUserBuilder);
    PPRelease(titleLabel);
    PPRelease(tableViewBG);
    PPRelease(avatarButton);
    PPRelease(saveButton);
    PPRelease(_avatarImageView);
    PPRelease(imageUploader);
    PPRelease(nicknameLabel);
    PPRelease(expAndLevelLabel);
    PPRelease(backgroundImage);
    [super dealloc];
}

- (NSArray*)getPrivacyPublicTypeNameArray
{
    return @[ NSLS(@"kPrivacyToFriend"), NSLS(@"kPrivacyToNone"), NSLS(@"kPrivacyToAll") ];
}

- (NSString*)nameForPrivacyPublicType:(PBOpenInfoType)type
{
    NSArray* array = [self getPrivacyPublicTypeNameArray];
    if (type < [array count]) {
        return [array objectAtIndex:type];
    }
    return nil;
}

- (void)updateRowIndexs
{
    //section user
    rowOfPassword = 0;
    rowOfGender = 1;
    rowOfNickName = 2;
    rowOfLocation = 3;
    rowOfBirthday = 4;
    rowOfBloodGroup = 5;
    rowOfZodiac = 6;
    rowOfSignature = 7;
    rowOfPrivacy = 8;
    rowOfCustomBg = 9;
    rowOfCustomBBSBg = 10,
    rowsInSectionUser = 11;
    
    //section guessword
    if (isDrawApp()) {
        //no matter what the language is, the level is normal.
        if (_pbUserBuilder.guessWordLanguage == ChineseType ||
            _pbUserBuilder.guessWordLanguage == UnknowType) {
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
    }/* else if (isDiceApp()) {
        rowsInSectionGuessWord = 0;
        rowOfCustomDice = 3;
        rowsInSectionUser = 4; //add custom dice
    } else if  (isZhajinhuaApp()) {
        rowsInSectionGuessWord = 0;
        rowsInSectionUser = 9;
    }
*/
    
    //section sound
    rowOfSoundSwitcher = 0;
    rowOfVolumeSetting = 1;
    rowOfMusicSettings = 2;
    //rowOfChatVoice = 3;
    rowsInSectionSound = isLittleGeeAPP()?1:2;//isDrawApp()?3:2;//TODO:hide background music in dice, fix it later
    
    rowsInSectionAccount = ROW_ACCOUNT_COUNT;
}

- (void)updateAvatar:(UIImage *)image
{
    [_avatarImageView setImage:image];
}

- (void)updateBackground:(UIImage*)image
{
}

- (void)updateNicknameLabel
{
    [self.nicknameLabel setText:_pbUserBuilder.nickName];
}

- (void)askInputEmail:(NSString*)text
{
    
    CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kInputEmail") delegate:self]; 
    dialog.tag = DIALOG_TAG_EMAIL;
    dialog.inputTextField.text = text;
    [dialog.inputTextField setPlaceholder:NSLS(@"kInputEmail")];
    
    [dialog showInView:self.view];
}

- (void)updateInfoFromUserManager
{

}

- (void)resetEditStatus
{
    hasEdited = NO;
}

- (void)displayAvatarView
{
    NSURL* url = [NSURL URLWithString:[_userManager avatarURL]];
    UIImage* defaultImage = [[UserManager defaultManager] defaultAvatarImage];
    [_avatarImageView setImageWithURL:url
                     placeholderImage:defaultImage
                              success:^(UIImage *image, BOOL cached) {
        
    } failure:^(NSError *error) {
        
    }];
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
    // set data for table view
    _userManager = [UserManager defaultManager];
    self.pbUserBuilder = [PBGameUser builderWithPrototype:[_userManager pbUser]];
    isSoundOn = [AudioManager defaultManager].isSoundOn;
    isMusicOn = [AudioManager defaultManager].isMusicOn;
    
    [super viewDidLoad];
    
    // set background
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.backgroundImage setImage:[UIImage imageNamed:[GameApp background]]];
    
    // init SAVE button
    [titleLabel setText:NSLS(@"kSettings")];
    [tableViewBG setImage:[imageManager whitePaperImage]];
    [saveButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
    
    // init avatar image view and button
    self.avatarImageView = [[[UIImageView alloc] initWithFrame:avatarButton.bounds] autorelease];
    [avatarButton addSubview:_avatarImageView];
    [self displayAvatarView];
    
    // init table view row and section
    [self updateRowIndexs];
    
    // init nick name
    [self updateNicknameLabel];
    
    // init level and exp info label
    LevelService* svc = [LevelService defaultService];
    [self.expAndLevelLabel setText:[NSString stringWithFormat:NSLS(@"kLevelInfo"), svc.level, svc.experience, svc.expRequiredForNextLevel]];
    
    // init table view
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
    return [UserSettingCell getCellHeight];
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
//    isAutoSave = !btn.selected;
//    [ConfigManager setAutoSave:isAutoSave];
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

#define SW_FONT (ISIPAD?24:12)
#define SW_FRAME (ISIPAD?CGRectMake(246*2, 3.5*2, 70*2, 37*2):CGRectMake(210, 3.5, 70, 37))

- (UIButton *)addSwitchButtonWithTag:(NSInteger)tag toCell:(UserSettingCell *)cell
{
    [self clearSwitchInCell:cell];
    [cell.customAccessory setHidden:YES];
    UIButton* btn = [[UIButton alloc] initWithFrame:SW_FRAME];
    [cell.contentView addSubview:btn];
    [self initSwitcher:btn];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:SW_FONT]];
    [btn setCenter:CGPointMake(cell.customAccessory.center.x - btn.frame.size.width/2, cell.customAccessory.center.y)];
    [btn setTag:tag];
    [btn release];
    return btn;
}


//- (UITableViewCell*)createCellByIdentifier:(NSString*)cellIdentifier
//{
//    UITableViewCell* cell;
//    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier]autorelease];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    
//    int fontSize = 15;
//    if ([DeviceDetection isIPAD]) {
//        [cell.textLabel setFont:[UIFont systemFontOfSize:fontSize*2]];
//        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:fontSize*2]];
//    }else {
//        [cell.textLabel setFont:[UIFont systemFontOfSize:fontSize]];
//        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
//    }
//    [cell.textLabel setTextColor:[UIColor brownColor]];
//    return cell;
//}

//- (void)initCell:(UserSettingCell*)cell withIndexPath:(NSIndexPath*)indexPath
//{
//    int rowNumber = [self tableView:self.dataTableView numberOfRowsInSection:indexPath.section];
//    
//    if (rowNumber == 1) {
//        [cell.backgroundImageView setImage:[UIImage imageNamed:@"user_setting_cell_one.png"]];
//        return;
//    }
//    if (indexPath.row == 0) {
//        [cell.backgroundImageView setImage:[UIImage imageNamed:@"user_setting_cell_up.png"]];
//        return;
//    } else if (indexPath.row == rowNumber-1) {
//        [cell.backgroundImageView setImage:[UIImage imageNamed:@"user_setting_cell_down.png"]];
//        return;
//    } else {
//        [cell.backgroundImageView setImage:[UIImage imageNamed:@"user_setting_cell_middle.png"]];
//        return;
//    }
//    
//    
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [UserSettingCell getCellIdentifier];
    UserSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [UserSettingCell createCell:self];
        
    }else{
        [self clearSwitchInCell:cell];
    }
//    [self initCell:cell withIndexPath:indexPath];
    int rowNumber = [self tableView:self.dataTableView numberOfRowsInSection:indexPath.section];
    [cell setCellWithRow:indexPath.row inSectionRowCount:rowNumber];
    
    [cell.customDetailLabel setText:nil];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == SECTION_USER) {
        if (row == rowOfPassword) {
            [cell.customTextLabel setText:NSLS(@"kPassword")];      
            if ([_pbUserBuilder.password length] == 0) {
                [cell.customDetailLabel setText:NSLS(@"kUnset")];
            }
            else{
                [cell.customDetailLabel setText:NSLS(@"kPasswordSet")];
            }
        }else if (row == rowOfGender){
            [cell.customTextLabel setText:NSLS(@"kGender")];
            if ([_pbUserBuilder gender]) {
                [cell.customDetailLabel setText:NSLS(@"kMale")];
            }else{
                [cell.customDetailLabel setText:NSLS(@"kFemale")];
            }
            [cell.customDetailLabel setHidden:NO];
        }else if(row == rowOfNickName)
        {
            [cell.customTextLabel setText:NSLS(@"kNickname")];           
            [cell.customDetailLabel setText:nicknameLabel.text];            
        } else if (row == rowOfCustomDice) {
            [cell.customTextLabel setText:NSLS(@"kCustomDice")];
        } else if (row == rowOfLocation) {
            [cell.customTextLabel setText:NSLS(@"kLocation")];
            [cell.customDetailLabel setText:[_pbUserBuilder location]];
        }else if (row == rowOfZodiac) {
            [cell.customTextLabel setText:NSLS(@"kZodiac")];
            NSString* zodiac = [LocaleUtils getZodiacWithIndex:([_pbUserBuilder zodiac]-1)];
            [cell.customDetailLabel setText:((zodiac == nil)?NSLS(@"kUnknown"):zodiac)];
        }else if (row == rowOfBirthday) {
            [cell.customTextLabel setText:NSLS(@"kBirthday")];
            if ([_pbUserBuilder hasBirthday]) {
                [cell.customDetailLabel setText:_pbUserBuilder.birthday];
            }
        }else if (row == rowOfBloodGroup) {
            [cell.customTextLabel setText:NSLS(@"kBloodGroup")];
            NSString* bloodGroup = _pbUserBuilder.bloodGroup;
            [cell.customDetailLabel setText:((bloodGroup == nil || bloodGroup.length <= 0)?NSLS(@"kUnknown"):bloodGroup)];
        } else if (row == rowOfSignature) {
            [cell.customTextLabel setText:NSLS(@"kSignature")];
            [cell.customDetailLabel setText:_pbUserBuilder.signature];
        } else if (row == rowOfPrivacy) {
            [cell.customTextLabel setText:NSLS(@"kPrivacy")];
            [cell.customDetailLabel setText:[self nameForPrivacyPublicType:_pbUserBuilder.openInfoType]];
        } else if (row == rowOfCustomBg) {
            [cell.customTextLabel setText:NSLS(@"kCustomBg")];
        } else if (row == rowOfCustomBBSBg) {
            [cell.customTextLabel setText:NSLS(@"kCustomBBSBg")];
        }
    }else if (section == SECTION_GUESSWORD) {
        if(row == rowOfLanguage)
        {
            [cell.customTextLabel setText:NSLS(@"kLanguageSettings")];
            switch (_pbUserBuilder.guessWordLanguage){
                case EnglishType:
                    [cell.customDetailLabel setText:NSLS(@"kEnglish")];
                    break;
                case ChineseType:
                default:
                    [cell.customDetailLabel setText:NSLS(@"kChinese")];
                    break;
            }
        }else if(row == rowOfLevel){
            [cell.customTextLabel setText:NSLS(@"kLevelSettings")];     
            if (guessLevel == EasyLevel) {
                [cell.customDetailLabel setText:NSLS(@"kEasyLevel")];
            }else if(guessLevel == NormalLevel){
                [cell.customDetailLabel setText:NSLS(@"kNormalLevel")];
            }else{
                [cell.customDetailLabel setText:NSLS(@"kHardLevel")];
            }
            [cell.customDetailLabel setHidden:NO];
        }else if(row == rowOfCustomWord){
            [cell.customTextLabel setText:NSLS(@"kCustomWordManage")]; 
        }else if(row == rowOfAutoSave){
            [cell.customTextLabel setText:NSLS(@"kAutoSave")]; 
            [cell.customDetailLabel setText:nil];
            UIButton *btn = [self addSwitchButtonWithTag:DRAW_AUTOSAVE_TAG toCell:cell];
            [btn addTarget:self action:@selector(clickAutoSaveSwitcher:) forControlEvents:UIControlEventTouchUpInside];
//            [btn setSelected:!isAutoSave];            

        }
    } else if (section == SECTION_SOUND) {
        if(row == rowOfSoundSwitcher) 
        {
            [cell.customTextLabel setText:NSLS(@"kSound")];
            [cell.customDetailLabel setText:nil];
            UIButton *btn = [self addSwitchButtonWithTag:SOUND_SWITCHER_TAG toCell:cell];
            [btn addTarget:self action:@selector(clickSoundSwitcher:) forControlEvents:UIControlEventTouchUpInside];
            [btn setSelected:!isSoundOn];            

        }else if (row == rowOfMusicSettings) {
            [cell.customTextLabel setText:NSLS(@"kCustomMusic")];
            [cell.customDetailLabel setHidden:YES];
        } else if (row == rowOfVolumeSetting) {
            [cell.customTextLabel setText:NSLS(@"kBackgroundMusic")];
            [cell.customDetailLabel setText:nil];
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
                        
        [cell.customDetailLabel setHidden:NO];
        switch (row) {
            case ROW_EMAIL:
            {
                [cell.customTextLabel setText:NSLS(@"kSetEmail")];
                if ([_pbUserBuilder.email length] > 0){
                    [cell.customDetailLabel setText:_pbUserBuilder.email];
                }
                else{
                    [cell.customDetailLabel setText:NSLS(@"kEmailNotSet")];
                }
            }
                break;
            case ROW_SINA_WEIBO:
            {
                [cell.customTextLabel setText:NSLS(@"kSetSinaWeibo")];
                if ([_userManager hasBindSinaWeibo]){
                    if ([[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]){
                        [cell.customDetailLabel setText:NSLS(@"kWeiboExpired")];
                    }
                    else{
                        [cell.customDetailLabel setText:NSLS(@"kWeiboSet")];
                    }
                }
                else{
                    [cell.customDetailLabel setText:NSLS(@"kNotSet")];
                }                
            }
                break;
                
            case ROW_QQ_WEIBO:
            {
                [cell.customTextLabel setText:NSLS(@"kSetQQWeibo")];
                if ([_userManager hasBindQQWeibo]){
                    if ([[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]){
                        [cell.customDetailLabel setText:NSLS(@"kWeiboExpired")];
                    }
                    else{
                        [cell.customDetailLabel setText:NSLS(@"kWeiboSet")];
                    }
                }
                else{
                    [cell.customDetailLabel setText:NSLS(@"kNotSet")];
                }                
            }
                break;
                
            case ROW_FACEBOOK:
            {
                [cell.customTextLabel setText:NSLS(@"kSetFacebook")];
                if ([_userManager hasBindFacebook]){
                    if ([[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]){
                        [cell.customDetailLabel setText:NSLS(@"kWeiboExpired")];
                    }
                    else{
                        [cell.customDetailLabel setText:NSLS(@"kWeiboSet")];
                    }
                }
                else{
                    [cell.customDetailLabel setText:NSLS(@"kNotSet")];
                }                
            }
                break;
                
            default:
                break;
        }
    }
//    else if (section == SECTION_REMOVE_AD) {
//        cell.textLabel.text = NSLS(@"kRemoveAd");
//        cell.detailTextLabel.hidden = NO;
//        if ([ConfigManager isProVersion]){
//            cell.detailTextLabel.text = @"N/A";
//        }
//        else{
//            cell.detailTextLabel.text = ([[AdService defaultService] isShowAd] ? NSLS(@"kAdNotRemoved") : NSLS(@"kAdRemoved"));
//        }
//    }
    
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

- (ChangeAvatar*)backgroundPicker
{
    if (imageUploader == nil) {
        imageUploader = [[ChangeAvatar alloc] init];
        imageUploader.autoRoundRect = NO;
        imageUploader.isCompressImage = NO;
    }
    return imageUploader;
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
            
            PassWordDialog *infoView = [PassWordDialog create];
            infoView.delegate = self;
            CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kPassword") customView:infoView style:CommonDialogStyleDoubleButton];
            dialog.tag = DIALOG_TAG_PASSWORD;
            dialog.delegate = self;
            [dialog showInView:self.view];
            
        }else if (row == rowOfGender){
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kGender" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kMale") otherButtonTitles:NSLS(@"kFemale"), nil];
            int index = (_pbUserBuilder.gender) ? INDEX_OF_MALE : INDEX_OF_FEMALE;
            [actionSheet setDestructiveButtonIndex:index];
            [actionSheet showInView:self.view];
            actionSheet.tag = GENDER_TAG;
            [actionSheet release];
            
        }else if(row == rowOfNickName){
            CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kNickname") delegate:self];
            dialog.tag = DIALOG_TAG_NICKNAME;
            dialog.inputTextField.text = nicknameLabel.text;
            [dialog setMaxInputLen:[ConfigManager getNicknameMaxLen]];
            
            [dialog showInView:self.view];
        } else if (row == rowOfCustomDice){
            Class class = NSClassFromString(@"CustomDiceSettingViewController");
            if (class && [class isSubclassOfClass:[UIViewController class]]) {
                UIViewController* controller = [[[class alloc] init] autorelease];
                [self.navigationController pushViewController:controller animated:YES];
            }
            
        } else if (row == rowOfLocation) {
            [self askUpdateLocation];
            
        }else if (row == rowOfZodiac) {
            [self askSetZodiac];
        }else if (row == rowOfBirthday) {
            [self askSetBirthday];
        }else if (row == rowOfBloodGroup) {
            [self askSetBloodGroup];
        } else if (row == rowOfSignature) {
            
            CommonDialog *dialog = [CommonDialog createInputViewDialogWith:NSLS(@"kInputSignature")];
            dialog.inputTextView.text = _pbUserBuilder.signature;
            dialog.delegate = self;
            [dialog setMaxInputLen:[ConfigManager getSignatureMaxLen]];
            [dialog showInView:self.view];
            dialog.tag = DIALOG_TAG_SIGNATURE;
            
        }else if (row == rowOfPrivacy) {
            [self askSetPrivacy];
        }else if (row == rowOfCustomBg) {
            __block UserSettingController* uc = self;
            [[self backgroundPicker] showSelectionView:self selectedImageBlock:^(UIImage *image) {
                [uc uploadCustomBg:image];
            } didSetDefaultBlock:^{
                [uc uploadCustomBg:nil];
            } title:NSLS(@"kCustomBg") hasRemoveOption:YES];
        }else if (row == rowOfCustomBBSBg) {            
            [[self backgroundPicker] showSelectionView:self selectedImageBlock:^(UIImage *image) {
                if ([[UserManager defaultManager] setBbsBackground:image]) {
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCustomBBSBgSucc") delayTime:2];
                }
            } didSetDefaultBlock:^{
                if ([[UserManager defaultManager] resetBbsBackground]) {
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kResetCustomBBSBgSucc") delayTime:2];
                }
            } title:NSLS(@"kCustomBBSBg") hasRemoveOption:YES];
        }
    }
    else if (section == SECTION_GUESSWORD) {
        if(row == rowOfLanguage){
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kLanguageSelection" ) delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kChinese") otherButtonTitles:NSLS(@"kEnglish"), nil];
            [actionSheet setDestructiveButtonIndex:_pbUserBuilder.guessWordLanguage - 1];
            [actionSheet showInView:self.view];
            actionSheet.tag = LANGUAGE_TAG;
            [actionSheet release]; 
        }else if(row == rowOfLevel){

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
    }
    else if (section == SECTION_SOUND) {
        
        if(row == rowOfSoundSwitcher) {
            //no action
        }else if (row == rowOfMusicSettings) {
        } else if (row == rowOfVolumeSetting) {
            //no action
        } 
    }
    else if (section == SECTION_ACCOUNT){
        
        switch (row) {
            case ROW_EMAIL:
            {
                [self askInputEmail:_pbUserBuilder.email];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)askUpdateLocation
{
    __block UserSettingController* uc = self;
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGetLocationTitle") message:NSLS(@"kGetLocationMsg") style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(UILabel *label){
            [uc startUpdatingLocation];
            [uc showActivityWithText:NSLS(@"kGetingLocation")];
            
    }];
    
    [dialog showInView:self.view];
}

- (void)askSetZodiac
{
    NSString* defaultZodiac = nil;
    if ([_pbUserBuilder hasZodiac]) {
        defaultZodiac = [LocaleUtils getZodiacWithIndex:_pbUserBuilder.zodiac-1];
    }
    MKBlockActionSheet* actionSheet = [[[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kZodiac") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:defaultZodiac otherButtonTitles:nil] autorelease];
    for (int i = 0; i < [LocaleUtils getZodiacArray].count ; i++) {
        NSString* zodiacStr = [LocaleUtils getZodiacWithIndex:i];
        if (i != _pbUserBuilder.zodiac - 1) {
            [actionSheet addButtonWithTitle:zodiacStr];
        }
    }
    int index = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
    [actionSheet setCancelButtonIndex:index];
    __block UserSettingController* bc = self;
    [actionSheet setActionBlock:^(NSInteger buttonIndex) {
        PPDebug(@"destruction index = %d", actionSheet.destructiveButtonIndex);
        if (buttonIndex != actionSheet.cancelButtonIndex && buttonIndex != actionSheet.destructiveButtonIndex){
            if (buttonIndex < _pbUserBuilder.zodiac) {
                [_pbUserBuilder setZodiac:buttonIndex];
            } else {
                [_pbUserBuilder setZodiac:buttonIndex+1];
            }
            
            hasEdited = YES;
        }
        PPDebug(@"did click index --%d", buttonIndex);
        [bc.dataTableView reloadData];
    }];

    [actionSheet showInView:self.view];
}

- (void)askSetBirthday
{
    __block UserSettingController* bc = self;
    NSString* defaultDateStr = [_pbUserBuilder hasBirthday]?_pbUserBuilder.birthday:@"1990-06-15";
    GCDatePickerView* view = [GCDatePickerView DatePickerViewWithMode:UIDatePickerModeDate
                                                          defaultDate:dateFromStringByFormat(defaultDateStr, DATE_FORMAT)
                                                          finishBlock:^(NSDate *date) {
                                                              
                                                              if (date != nil){
                                                                  
                                                                  [_pbUserBuilder setBirthday:dateToStringByFormat(date, DATE_FORMAT)];
                                                                  if (![_pbUserBuilder hasBirthday]) {
                                                                      [_pbUserBuilder setZodiac:dateToZodiac(date)];
                                                                  }
                                                                  hasEdited = YES;
                                                              }
                                                              
                                                              [bc.dataTableView reloadData];
                                                          }];
    [view.datePicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [view showInView:self.view];
}

- (void)askSetBloodGroup
{
    MKBlockActionSheet* actionSheet = [[[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kBloodGroup") delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"A") otherButtonTitles:NSLS(@"B"), NSLS(@"AB"), NSLS(@"O"), nil] autorelease];
    __block UserSettingController* bc = self;
    [actionSheet setActionBlock:^(NSInteger buttonIndex) {
        if(buttonIndex != actionSheet.cancelButtonIndex){
            [_pbUserBuilder setBloodGroup:[actionSheet buttonTitleAtIndex:buttonIndex]];
            hasEdited = YES;
        }
        [bc.dataTableView reloadData];
    }];
    if ([_pbUserBuilder hasBloodGroup]) {
        for (int i = 0; i < [actionSheet numberOfButtons]; i ++) {
            NSString* buttonTitle = [actionSheet buttonTitleAtIndex:i];
            if ([_pbUserBuilder.bloodGroup isEqualToString:buttonTitle]) {
                [actionSheet setDestructiveButtonIndex:i];
            }
        }
    
    }
    [actionSheet showInView:self.view];
}

- (void)askSetPrivacy
{
    MKBlockActionSheet* actionSheet = [[[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kPrivacy") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    for (NSString* privacyTypeStr in [self getPrivacyPublicTypeNameArray]) {
        [actionSheet addButtonWithTitle:privacyTypeStr];
    }
    int index = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
    [actionSheet setCancelButtonIndex:index];
    __block UserSettingController* bc = self;
    [actionSheet setActionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex != actionSheet.cancelButtonIndex){
            
            [_pbUserBuilder setOpenInfoType:buttonIndex];
            hasEdited = YES;
        }
        [bc.dataTableView reloadData];
    }];
    if ([_pbUserBuilder hasOpenInfoType]) {
        [actionSheet setDestructiveButtonIndex:_pbUserBuilder.openInfoType];
    }
    [actionSheet showInView:self.view];
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
        [[UserService defaultService] updateUserWithSNSUserInfo:[_pbUserBuilder userId] userInfo:userInfo viewController:self];
        
        // ask to follow user
        [self askFollow];
    }

    self.navigationController.navigationBarHidden = YES;        
}

- (void)didUserRegistered:(int)resultCode
{
    if (resultCode == 0){
//        [self popupMessage:NSLS(@"kUserBindSucc") title:nil];
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUserBindSucc") delayTime:1.5];
        
    }
    else{
//        [self popupMessage:NSLS(@"kUserBindFail") title:nil];
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUserBindFail") delayTime:1.5];
    }
    
    self.navigationController.navigationBarHidden = YES;    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)bindSNS:(int)snsType
{
    PPSNSCommonService* service = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    NSString* name = [service snsName];

    [service logout];
    
    [service login:^(NSDictionary *userInfo) {
        PPDebug(@"%@ Login Success", name);
        
        [self showActivityWithText:NSLS(@"Loading")];
        
        [service readMyUserInfo:^(NSDictionary *userInfo) {
            [self hideActivity];
            PPDebug(@"%@ readMyUserInfo Success, userInfo=%@", name, [userInfo description]);
            [[UserService defaultService] updateUserWithSNSUserInfo:[_pbUserBuilder userId] userInfo:userInfo viewController:self];
            
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
            _pbUserBuilder.guessWordLanguage = buttonIndex + 1;
            hasEdited = YES;
        }else if(actionSheet.tag == LEVEL_TAG){
            guessLevel = [self buttonIndexToGuessLevel:buttonIndex];
        } else  if (actionSheet.tag == GENDER_TAG) {
            if (buttonIndex != actionSheet.destructiveButtonIndex) {
                hasEdited = YES;
            }
            BOOL gender = (buttonIndex == INDEX_OF_MALE) ? YES : NO;
            [_pbUserBuilder setGender:gender];
        }
        
//        else if (actionSheet.tag == CHAT_VOICE_TAG) {
//            chatVoice = buttonIndex + 1;
//        }
    }
    [self updateRowIndexs];
    [self.dataTableView reloadData];
}

//- (BOOL)isLocalChanged
//{ 
////    UISlider* slider = (UISlider*)[self.view viewWithTag:SLIDER_TAG];
//        
//    BOOL localChanged = (languageType != [userManager getLanguageType]) 
//    || (guessLevel != [ConfigManager guessDifficultLevel] || ([userManager gender] != nil && ![self.gender isEqualToString:[userManager gender]]));
//    return localChanged;
//}

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

- (void)uploadCustomBg:(UIImage*)image
{
    [self showActivityWithText:NSLS(@"kSaving")];
    [[UserService defaultService] uploadUserBackground:image resultBlock:^(int resultCode, NSString *imageRemoteURL) {
        [self hideActivity];
        if (resultCode == ERROR_SUCCESS && [imageRemoteURL length] > 0){
            [_pbUserBuilder setBackgroundUrl:imageRemoteURL];
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateBackgroundSucc") delayTime:1.5];
            [self updateBackground:image];
        }
        else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateBackgroundFail") delayTime:1.5];
        }
    }];
}

- (IBAction)clickSaveButton:(id)sender {
    
    if (_pbUserBuilder.nickName.length > [ConfigManager getNicknameMaxLen]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kNicknameOutofRange"), [ConfigManager getNicknameMaxLen], [ConfigManager getNicknameMaxLen]/2] delayTime:1.5];
        return;
    }
    if (_pbUserBuilder.signature.length > [ConfigManager getSignatureMaxLen]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kSignatureOutofRange"), [ConfigManager getSignatureMaxLen], [ConfigManager getSignatureMaxLen]/2] delayTime:1.5];
        return;
    }
    
    if (hasEdited) {
        PBGameUser* user = [_pbUserBuilder build];
        self.pbUserBuilder = [PBGameUser builderWithPrototype:user];
        
        [self showActivityWithText:NSLS(@"kSaving")];
        [[UserService defaultService] updateUser:user resultBlock:^(int resultCode) {
            [self hideActivity];
            if (resultCode == ERROR_SUCCESS){
                
                // clear edit flag
                hasEdited = NO;
                
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

- (IBAction)clickAvatar:(id)sender {
    
    __block UserSettingController* uc = self;
    if (imageUploader == nil) {
        imageUploader = [[ChangeAvatar alloc] init];
        imageUploader.autoRoundRect = NO;
    }
    [imageUploader showSelectionView:self
                  selectedImageBlock:^(UIImage *image) {
                      [uc uploadUserAvatar:image];
                  }
                  didSetDefaultBlock:nil
                               title:nil
                     hasRemoveOption:NO];
    
    
}

- (IBAction)clickBackButton:(id)sender {
    
    if (hasEdited) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotice") message:NSLS(@"kInfoUnSaved") style:CommonDialogStyleDoubleButton delegate:self];
        [dialog showInView:self.view];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView
{
    switch (dialog.tag) {
        case DIALOG_TAG_REBIND_FACEBOOK:
            [self bindFacebook];
            [self.navigationController popViewControllerAnimated:YES];
            return;
            
        case DIALOG_TAG_REBIND_QQ:
            [self bindQQ];
            [self.navigationController popViewControllerAnimated:YES];
            return;
            
        case DIALOG_TAG_REBIND_SINA:
            [self bindSina];
            [self.navigationController popViewControllerAnimated:YES];
            return;
            
        case DIALOG_TAG_NICKNAME:
            if ([((UITextField *)infoView).text length] > 0){
                [_pbUserBuilder setNickName:((UITextField *)infoView).text];
                [self updateNicknameLabel];
                hasEdited = YES;
            }
            [self.dataTableView reloadData];
            break;
            
        case DIALOG_TAG_PASSWORD:
                
                if ([(PassWordDialog *)infoView isPasswordWrong])
                {
                    [[(PassWordDialog *)infoView oldPasswordTextField] becomeFirstResponder];
                    [self passwordIsWrong];
                    
                }else if([(PassWordDialog *)infoView isPasswordIllegal])
                {
                    [[(PassWordDialog *)infoView anotherPasswordTextField] becomeFirstResponder];
                    [self passwordIsIllegal];
                    
                }else if([(PassWordDialog *)infoView isTwoInputDifferent])
                {
                    [[(PassWordDialog *)infoView passwordTextField] becomeFirstResponder];
                    [self twoInputDifferent];
                    
                }else{
                    
                    if ([((PassWordDialog *)infoView).passwordTextField.text length] > 0){
                        [_pbUserBuilder setPassword:[((PassWordDialog *)infoView).passwordTextField.text encodeMD5Base64:PASSWORD_KEY]];
                        hasEdited = YES;
                    }
                    [self.dataTableView reloadData];
                }
            
            break;
            
        case DIALOG_TAG_EMAIL:
            
            if (NSStringIsValidEmail(((UITextField *)infoView).text)){
                [_pbUserBuilder setEmail:((UITextField *)infoView).text];
                hasEdited = YES;
            }else{
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEmailNotValid") delayTime:1.5];
                [self askInputEmail:((UITextField *)infoView).text];
            }
            [self.dataTableView reloadData];
            break;
            
        case DIALOG_TAG_SIGNATURE:
            
            [_pbUserBuilder setSignature:dialog.inputTextView.text];
            hasEdited = YES;
            [self.dataTableView reloadData];
            break;

            
        default:
            break;
    }
}

- (void)didClickCancel:(CommonDialog *)dialog
{
    [self.dataTableView reloadData];
}

- (void)passwordIsWrong
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPasswordWrong") delayTime:1.5];
}
- (void)twoInputDifferent
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPasswordDifferent") delayTime:1.5];
}

- (void)passwordIsIllegal
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPasswordIllegal") delayTime:1.5];
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

#pragma mark - location delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self hideActivity];
    [super locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
    [self reverseGeocodeCurrentLocation:self.currentLocation];
}
#pragma mark reverseGeocoder

- (void)reverseGeocodeCurrentLocation:(CLLocation *)location
{
    [[GeographyService defaultService] findCityWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude delegate:self];
    [_pbUserBuilder setLatitude:location.coordinate.latitude];
    [_pbUserBuilder setLongitude:location.coordinate.longitude];
    
}


- (void)didImageSelected:(UIImage *)image
{
    
}

- (void)findCityDone:(int)result cityName:(NSString*)city provinceName:(NSString*)provinceName countryCode:(int)countryCode
{

    [self hideActivity];
    if (result == 0) {
        NSString* provinceStr = (provinceName != nil)?provinceName:@"";
        NSString* cityStr = (city != nil)?city:@"";
        
        [_pbUserBuilder setLocation:[NSString stringWithFormat:@"%@ %@", provinceStr, cityStr]];
        hasEdited = YES;
        PPDebug(@"<UserSettingController>update location succ, new location is %@", cityStr);
    }
    [self.dataTableView reloadData];
}

/*
 
功能
 1）位置：使用CoreLoation自动获取并且自动转换为城市，而不是输入，点击该行，获取位置并且转换为城市后，询问用户是否确认，是则设置，否则不设置
 2）生日：默认值为1990-06-15
 3）血型：其他修改为“未知”，送空字符串即可（或者去掉最后一项）
 4）星座：取值为1-12，而不是0-11，否则默认用户都是白羊座，0表示未设置
 5）个性签名：输入框应该是一个TextView，可以换行等等（未国际化），因为个性化签名可以更长一些
 6）新增 信息公开设置 openInfoType
 
 
 */


@end
