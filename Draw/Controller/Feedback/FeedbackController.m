//
//  FeedbackController.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedbackController.h"
#import "ReportController.h"
#import "CommonDialog.h"
#import "DrawAppDelegate.h"
#import "AboutUsController.h"
#import "UserManager.h"
//#import "UFPController.h"
#import "PPDebug.h"
#import "DeviceDetection.h"
#import "PPConfigManager.h"
#import "CommonMessageCenter.h"
#import "AccountService.h"
//#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"
//#import "UMGridViewController.h"
#import "UIUtils.h"
#import "ShareImageManager.h"
#import "CacheManager.h"
#import "CommonDialog.h"
#import "UserSettingCell.h"
#import "PPTableViewController.h"
#import "GameSNSService.h"

#define HEIGHT_FOR_IPHONE   50
#define HEIGHT_FOR_IPHONE5  60
#define HEIGHT_FOR_IPAD     100


@interface FeedbackController()

@property (assign, nonatomic) int rowOfShare;
@property (assign, nonatomic) int rowOfAddWords;
@property (assign, nonatomic) int rowOfReportBug;
@property (assign, nonatomic) int rowOfFeedback;
@property (assign, nonatomic) int rowOfMoreApp;
@property (assign, nonatomic) int rowOfGiveReview;
@property (assign, nonatomic) int rowOfAbout;
@property (assign, nonatomic) int rowOfAppUpdate;
@property (assign, nonatomic) int numberOfRows;
@property (assign, nonatomic) int rowOfFollowSina;
@property (assign, nonatomic) int rowOfFollowTencent;
@property (assign, nonatomic) int rowOfCleanCache;

@end


@implementation FeedbackController

@synthesize TitleLabel;
@synthesize backgroundImageView;

@synthesize rowOfShare;
@synthesize rowOfFollowSina;
@synthesize rowOfFollowTencent;
@synthesize rowOfAddWords;
@synthesize rowOfReportBug;
@synthesize rowOfFeedback;
@synthesize rowOfMoreApp;
@synthesize rowOfGiveReview;
@synthesize rowOfAbout;
@synthesize rowOfAppUpdate;
@synthesize numberOfRows;
@synthesize rowOfCleanCache;
@synthesize qqGroupLabel = _qqGroupLabel;

#pragma mark - Table dataSource ,table view delegate

#define DRAW_TABLE_HEIGHT   ([DeviceDetection isIPAD] ? 790 : 380)
#define DICE_TABLE_HEIGHT   ([DeviceDetection isIPAD] ? 790 : 350)



- (void)initRowNumber
{
    rowOfMoreApp = -1;
    rowOfShare = -1;
    rowOfFollowSina = -1;
    rowOfFollowTencent = -1;
    rowOfAddWords = -1;
    rowOfReportBug = -1;
    rowOfFeedback = -1;
    rowOfMoreApp = -1;
    rowOfGiveReview = -1;
    rowOfAbout = -1;
    rowOfAppUpdate = -1;
    numberOfRows = -1;
    rowOfCleanCache = -1;
    
    int count = 0;
    if (isDrawApp()) {
//        rowOfShare = count++;
        rowOfShare = -1;
        if ([LocaleUtils isChina] || [LocaleUtils isOtherChina]) {
            rowOfFollowSina = count++;
            rowOfFollowTencent = count++;
        }
        rowOfCleanCache = count++;
        if (!isLittleGeeAPP()) {
            rowOfAddWords = count++;
        }
        rowOfReportBug = count++;
        rowOfFeedback = count++;
        
//        if ([PPConfigManager isInReviewVersion] == NO){
//            rowOfAppUpdate = count++;
//        }
//        else{
            rowOfAppUpdate = -1;
//        }
        
//        if ([PPConfigManager isInReviewVersion] == NO){
//            rowOfGiveReview = count++;
//        }
//        else{
            rowOfGiveReview = -1;
//        }
        rowOfAbout = count++;
//        rowOfMoreApp = count++;
        numberOfRows = count;
        
        dataTableView.frame = CGRectMake(dataTableView.frame.origin.x, dataTableView.frame.origin.y, dataTableView.frame.size.width, DRAW_TABLE_HEIGHT);
    }else{ 
        rowOfShare = count++;
        rowOfFollowSina = count++;
        rowOfFollowTencent = count++;
        rowOfReportBug = count++;
        rowOfFeedback = count++;
//        rowOfMoreApp = count++;
        rowOfAppUpdate = count++;
//        if ([PPConfigManager isInReviewVersion] == NO){
//            rowOfGiveReview = count++;
//            rowOfAppUpdate = count++;
//        }
//        else{
//            rowOfGiveReview = -1;
//            rowOfAppUpdate = -1;
//        }
        rowOfGiveReview = -1;
        rowOfAppUpdate = -1;

        rowOfCleanCache = count++;
        rowOfAbout = count++;
        numberOfRows = count;
        
        rowOfAddWords = -1;
        dataTableView.frame = CGRectMake(dataTableView.frame.origin.x, dataTableView.frame.origin.y, dataTableView.frame.size.width, DICE_TABLE_HEIGHT);
    }
}

- (void)initCell:(UserSettingCell*)aCell withIndex:(int)anIndex
{
    CGRect rect = aCell.customTextLabel.frame;
    rect.size.width = aCell.bounds.size.width;
    [aCell.customTextLabel setFrame:rect];
    [aCell.customTextLabel setTextColor:[UIColor colorWithRed:0x6c/255.0 green:0x31/255.0 blue:0x08/255.0 alpha:1.0]];
    
    if (anIndex == rowOfShare) {
        NSString* message = [NSString stringWithFormat:NSLS(@"kCoinsForShareToFriends"), [PPConfigManager getShareFriendReward]];
        message = [NSString stringWithFormat:@"%@ (%@)", NSLS(@"kShare_to_friends"), message];
        [aCell.customTextLabel setText:message];
    } 
    else if (anIndex == rowOfFollowSina) {
        NSString* message = [NSString stringWithFormat:NSLS(@"kCoinsForFollowUs"), [PPConfigManager getFollowReward]];            
        message = [NSString stringWithFormat:@"%@ (%@)", NSLS(@"kFollowSinaWeibo"), message];
        [aCell.customTextLabel setText:message];
    }
    else if (anIndex == rowOfFollowTencent) {
        NSString* message = [NSString stringWithFormat:NSLS(@"kCoinsForFollowUs"), [PPConfigManager getFollowReward]];
        message = [NSString stringWithFormat:@"%@ (%@)", NSLS(@"kFollowTencentWeibo"), message];
        [aCell.customTextLabel setText:message];
    }
    else if (anIndex == rowOfAddWords) {
        [aCell.customTextLabel setText:NSLS(@"kAddWords")];
    } 
    else if (anIndex == rowOfReportBug) {
        [aCell.customTextLabel setText:NSLS(@"kReport_problems")];
    } else if (anIndex == rowOfFeedback) {
        [aCell.customTextLabel setText:NSLS(@"kGive_some_advice")];
    } else if (anIndex == rowOfMoreApp) {
        [aCell.customTextLabel setText:NSLS(@"kMore_apps")];
    } else if (anIndex == rowOfGiveReview) {
        [aCell.customTextLabel setText:NSLS(@"kGive_a_5-star_review")];
    } else if (anIndex == rowOfAbout) {
        [aCell.customTextLabel setText:NSLS(@"kAbout_us")];
    } else if (anIndex == rowOfAppUpdate){
        [aCell.customTextLabel setText:[NSString stringWithFormat:NSLS(@"kAppUpdate"), [UIUtils getAppVersion]]];
        if ([UIUtils checkAppHasUpdateVersion]) {
            [aCell.badgeHolderView addSubview:[self badgeView]];
        }else{
            [aCell.badgeHolderView removeAllSubviews];
        }
    } else if (anIndex == rowOfCleanCache) {
        [aCell.customTextLabel setText:NSLS(@"kCleanCache")];
    }
    
//    if ([DeviceDetection isIPAD]) {
//        [aCell.customTextLabel setFont:[UIFont systemFontOfSize:32]];
//    } else {
//        [aCell.customTextLabel setFont:[UIFont systemFontOfSize:17]];
//    }
}
enum {
    SHARE_VIA_SMS = 0,
    SHARE_VIA_EMAIL,
    SHARE_VIA_SINA = 2,
    SHARE_VIA_QQ = 2,
    SHARE_VIA_FACEBOOK = 2,
    SHARE_COUNT
};
                 
- (void)didPublishWeibo:(int)result
{
    PPDebug(@"publish weibo result : %d", result);
    
    if (result == 0){
        
        // reward
        if ([[AccountService defaultService] rewardForShareWeibo] > 0){
            // show message
            NSString* message = [NSString stringWithFormat:NSLS(@"kGetCoinsByShareToFriends"), [PPConfigManager getShareFriendReward]];
            [[CommonMessageCenter defaultCenter] postMessageWithText:message delayTime:2.0 isHappy:YES];
        }
        
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSString *shareBodyModel = [GameApp shareMessageBody];

    NSString* weiboId = @"";
    if (buttonIndex == buttonIndexQQWeibo){
        weiboId = [NSString stringWithFormat:@"@%@", [GameApp qqWeiboId]];
    }
    else if (buttonIndex == buttonIndexSinaWeibo) {
        weiboId = [NSString stringWithFormat:@"@%@", [GameApp sinaWeiboId]];
    }

    NSString *shareBody = [NSString stringWithFormat:shareBodyModel,
                           NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),
                           [UIUtils getAppLink:[PPConfigManager appId]],
                           weiboId];
    
    if (buttonIndex == buttonIndexSMS) {
        [self sendSms:nil body:shareBody];
    } else if (buttonIndex == buttonIndexEmail) {
        NSString *emailSubject = [GameApp shareEmailSubject];

        [self sendEmailTo:nil ccRecipients:nil bccRecipients:nil subject:emailSubject body:shareBody isHTML:NO delegate:self];
    } else if (buttonIndex == buttonIndexSinaWeibo) {
        
        [[GameSNSService defaultService] publishWeibo:TYPE_SINA
                                                 text:shareBody
                                               inView:self.view         
                                           awardCoins:[PPConfigManager getShareFriendReward]
                                       successMessage:NSLS(@"kSentWeiboSucc")
                                       failureMessage:NSLS(@"kSentWeiboFailure")];
        
//        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] publishWeibo:shareBody
//                                                                               imageFilePath:nil
//                                                                                successBlock:NULL
//                                                                                failureBlock:NULL];
        

    } else if (buttonIndex == buttonIndexQQWeibo) {
        
        [[GameSNSService defaultService] publishWeibo:TYPE_QQSPACE
                                                 text:shareBody
                                               inView:self.view
                                           awardCoins:[PPConfigManager getShareFriendReward]
                                       successMessage:NSLS(@"kSentWeiboSucc")
                                       failureMessage:NSLS(@"kSentWeiboFailure")];

        
//        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] publishWeibo:shareBody
//                                                                               imageFilePath:nil
//                                                                                successBlock:NULL
//                                                                                failureBlock:NULL];
        

    } else if (buttonIndex == buttonIndexFacebook) {
        
        [[GameSNSService defaultService] publishWeibo:TYPE_FACEBOOK
                                                 text:shareBody
                                               inView:self.view
                                           awardCoins:[PPConfigManager getShareFriendReward]
                                       successMessage:NSLS(@"kSentWeiboSucc")
                                       failureMessage:NSLS(@"kSentWeiboFailure")];

        
//        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] publishWeibo:shareBody
//                                                                               imageFilePath:nil
//                                                                                successBlock:NULL
//                                                                                failureBlock:NULL];

    }
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    buttonIndexSMS = 0;
    buttonIndexEmail = 1;
    buttonIndexSinaWeibo = -1;
    buttonIndexQQWeibo = -1;
    buttonIndexFacebook = -1;
    if (indexPath.row == rowOfShare) {
        UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_Options") 
                                                                  delegate:self 
                                                         cancelButtonTitle:nil 
                                                    destructiveButtonTitle:nil//NSLS(@"kShare_via_SMS")
                                                         otherButtonTitles:nil,//NSLS(@"kShare_via_Email"),
                                       nil];
        
//        int shareCount = 2;
        int shareCount = 0;
        
//        if ([[UserManager defaultManager] hasBindSinaWeibo]){
            buttonIndexSinaWeibo = shareCount;
            shareCount ++;
            [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Sina_weibo")];
//        }
        
        if ([[UserManager defaultManager] hasBindQQSpace]){
            buttonIndexQQWeibo = shareCount;
            shareCount ++;
            [shareOptions addButtonWithTitle:NSLS(@"kShare_via_tencent_weibo")];
        }
        
        if ([[UserManager defaultManager] hasBindFacebook]){
            buttonIndexFacebook = shareCount;
            shareCount ++;
            [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Facebook")];
        } 
        
        if (![DeviceDetection isIPAD]) {
            [shareOptions addButtonWithTitle:NSLS(@"kCancel")];
            [shareOptions setCancelButtonIndex:shareCount];
        }
        [shareOptions showInView:self.view];
        [shareOptions release];
    } 
    
    else if (indexPath.row  == rowOfAddWords) {
        ReportController* rc = [[ReportController alloc] initWithType:ADD_WORD];
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
    } 
    
    else if (indexPath.row == rowOfFollowSina){
        
        [[GameSNSService defaultService] followUser:TYPE_SINA weiboId:nil weiboName:[GameApp sinaWeiboId]];

    }else if (indexPath.row == rowOfFollowTencent){
        
        [[GameSNSService defaultService] followUser:TYPE_QQSPACE
                                            weiboId:nil
                                          weiboName:[GameApp qqWeiboId]];
        
    }
    
    else if (indexPath.row  == rowOfReportBug) {
        ReportController* rc = [[ReportController alloc] initWithType:SUBMIT_BUG];
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
    }
    
    else if (indexPath.row  == rowOfFeedback) {
        ReportController* rc = [[ReportController alloc] initWithType:SUBMIT_FEEDBACK];
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
    } 
    
    else if (indexPath.row  == rowOfMoreApp) {
        
        // useless now
        
//        UFPController* rc = [[UFPController alloc] init];
//        [self.navigationController pushViewController:rc animated:YES];
//        [rc release];
//        UMGridViewController *controller = [[UMGridViewController alloc] init];
//        [self.navigationController pushViewController:controller animated:YES];
//        [controller release];
    }
    
    else if (indexPath.row  == rowOfGiveReview) {
        PPDebug(@"<FeedbackController>appId :%@", [PPConfigManager appId]);
        [UIUtils gotoReview:[PPConfigManager appId]];
    } 
    
    else if (indexPath.row  == rowOfAbout) {
        AboutUsController* rc = [[AboutUsController alloc] init];
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
    }
    
    else if (indexPath.row  == rowOfAppUpdate) {
        if ([UIUtils checkAppHasUpdateVersion]) {
            [UIUtils openApp:[GameApp appId]];
        }else{
            POSTMSG(NSLS(@"kAlreadLastVersion"));
        }
    }
    
    else if (indexPath.row == rowOfCleanCache) {
        [self showActivityWithText:NSLS(@"kCleaning")];
       
        [self performSelector:@selector(cleanCache) withObject:nil afterDelay:0.1];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)cleanCache
{
    __block FeedbackController* fc = self;
    
    NSMutableArray* array = [NSMutableArray arrayWithArray:[GameApp cacheArray]];
    [array addObject:NSTemporaryDirectory()];
    
    [[CacheManager defaultManager] removeCachePathsArray:array succBlock:^(long long fileSize) {
        [fc hideActivity];
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCleanCache")
                                                           message:[NSString stringWithFormat:NSLS(@"kCleanCacheSucc"), fileSize/(1024.0*1024)]
                                                             style:CommonDialogStyleSingleButton];
        [dialog showInView:self.view];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return FEEDBACK_COUNT;
    return  numberOfRows;
}

SET_CELL_BG_IN_CONTROLLER;


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([DeviceDetection isIPhone5]) {
//        return HEIGHT_FOR_IPHONE5;
//    }
//    if ([DeviceDetection isIPAD]) {
//        return HEIGHT_FOR_IPAD;
//    }
//    return HEIGHT_FOR_IPHONE;
    
    return [UserSettingCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserSettingCell* cell = [tableView dequeueReusableCellWithIdentifier:[UserSettingCell getCellIdentifier]];
    if (cell == nil) {
        cell = [UserSettingCell createCell:self];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    [self initCell:cell withIndex:indexPath.row];
    NSInteger rowNumber = [self tableView:self.dataTableView numberOfRowsInSection:indexPath.section];
    [cell setCellWithRow:indexPath.row inSectionRowCount:rowNumber];
    return cell;
}



- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [self.backgroundImageView setImage:[UIImage imageNamed:[GameApp background]]];
    
    [super viewDidLoad];
    [self.TitleLabel setText:NSLS(@"kMore")];
    
    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:NSLS(@"kMore")];
    [titleView setTarget:self];
    
    
    [self initRowNumber];
    if ([LocaleUtils isChina]) {
        if (isDrawApp()) {
            [self.qqGroupLabel setText:NSLS(@"kQQGroup")];
        }
        [self.qqGroupLabel setTextColor:[UIColor colorWithRed:0x6c/255.0 green:0x31/255.0 blue:0x08/255.0 alpha:1.0]];
    } else {
        [self.qqGroupLabel setText:nil];
    }

    // Do any additional setup after loading the view from its nib.
    self.dataTableView.separatorColor = [UIColor clearColor];
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    SET_NORMAL_TABLE_VIEW_Y(self.dataTableView);
}



- (void)viewDidUnload
{
    [self setDataTableView:nil];
    [self setTitleLabel:nil];
    [self setBackgroundImageView:nil];
    [self setQqGroupLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
//    [dataTableView release];
//    [TitleLabel release];
//    [backgroundImageView release];
//    [_qqGroupLabel release];
    
    PPRelease(dataTableView);
    PPRelease(TitleLabel);
    PPRelease(backgroundImageView);
    PPRelease(_qqGroupLabel);
    
    [super dealloc];
}

#pragma mark - SNS Delegate

#define FOLLOW_SINA_KEY @"FOLLOW_SINA_KEY"
#define FOLLOW_QQ_KEY   @"FOLLOW_QQ_KEY"

- (void)didFollowUser:(int)result
{
    if (result != 0)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasRewardFollowSina = [userDefaults boolForKey:FOLLOW_SINA_KEY];
    BOOL hasRewardFollowQQ = [userDefaults boolForKey:FOLLOW_QQ_KEY];
    
    if ([[UserManager defaultManager] hasBindSinaWeibo] && hasRewardFollowSina == NO){
        [[AccountService defaultService] chargeCoin:[PPConfigManager getFollowReward] source:FollowReward];
        [userDefaults setBool:YES forKey:FOLLOW_SINA_KEY];
        [userDefaults synchronize];
    }
    
    if ([[UserManager defaultManager] hasBindQQSpace] && hasRewardFollowQQ == NO){
        [[AccountService defaultService] chargeCoin:[PPConfigManager getFollowReward] source:FollowReward];        
        [userDefaults setBool:YES forKey:FOLLOW_QQ_KEY];
        [userDefaults synchronize];
    }
}

#define BADGE_VIEW_WIDTH ([DeviceDetection isIPAD] ?  36 : 18)
#define BADGE_VIEW_HEIGHT ([DeviceDetection isIPAD] ?  38 : 19)
#define BADGE_LABEL_FONT [UIFont systemFontOfSize:([DeviceDetection isIPAD] ?  18 : 11)]

- (UIView *)badgeView{
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BADGE_VIEW_WIDTH, BADGE_VIEW_HEIGHT)] autorelease];
    imageView.image = [[ShareImageManager defaultManager] badgeImage];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:imageView.bounds] autorelease];
    label.font = BADGE_LABEL_FONT;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"1";
    label.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:label];
    return imageView;
}

@end
