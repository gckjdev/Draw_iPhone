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
#import "UFPController.h"
#import "PPDebug.h"
#import "DeviceDetection.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"
#import "AccountService.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"

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
@property (assign, nonatomic) int numberOfRows;
@property (assign, nonatomic) int rowOfFollow;

@end


@implementation FeedbackController
@synthesize dataTableView;
@synthesize TitleLabel;
@synthesize backgroundImageView;

@synthesize rowOfShare;
@synthesize rowOfFollow;
@synthesize rowOfAddWords;
@synthesize rowOfReportBug;
@synthesize rowOfFeedback;
@synthesize rowOfMoreApp;
@synthesize rowOfGiveReview;
@synthesize rowOfAbout;
@synthesize numberOfRows;
@synthesize qqGroupLabel = _qqGroupLabel;

#pragma mark - Table dataSource ,table view delegate
//enum {
//    SHARE = 0,
//    ADD_WORDS,
//    REPORT_BUG,
//    FEEDBACK,
//    MORE_APP,
//    GIVE_REVIEW,
//    ABOUT,
//    FEEDBACK_COUNT
//};

#define DRAW_TABLE_HEIGHT   ([DeviceDetection isIPAD] ? 790 : 350)
#define DICE_TABLE_HEIGHT   ([DeviceDetection isIPAD] ? 790 : 350)

- (void)initRowNumber
{
    int count = 0;
    if (isDrawApp()) {
        rowOfShare = count++;
        rowOfFollow = count++;
        rowOfAddWords = count++;
        rowOfReportBug = count++;
        rowOfFeedback = count++;
        rowOfMoreApp = count++;
        rowOfGiveReview = count++;
        rowOfAbout = count++;
        numberOfRows = count;
        
        dataTableView.frame = CGRectMake(dataTableView.frame.origin.x, dataTableView.frame.origin.y, dataTableView.frame.size.width, DRAW_TABLE_HEIGHT);
    }else{ 
        rowOfShare = count++;
        rowOfFollow = count++;
        rowOfReportBug = count++;
        rowOfFeedback = count++;
        rowOfMoreApp = count++;
        rowOfGiveReview = count++;
        rowOfAbout = count++;
        numberOfRows = count;
        
        rowOfAddWords = -1;
        dataTableView.frame = CGRectMake(dataTableView.frame.origin.x, dataTableView.frame.origin.y, dataTableView.frame.size.width, DICE_TABLE_HEIGHT);
    }
}

- (void)initCell:(UITableViewCell*)aCell withIndex:(int)anIndex
{
    [aCell.textLabel setTextColor:[UIColor colorWithRed:0x6c/255.0 green:0x31/255.0 blue:0x08/255.0 alpha:1.0]];
    
    if (anIndex == rowOfShare) {
        NSString* message = [NSString stringWithFormat:NSLS(@"kCoinsForShareToFriends"), [ConfigManager getShareFriendReward]];            
        message = [NSString stringWithFormat:@"%@ (%@)", NSLS(@"kShare_to_friends"), message];
        [aCell.textLabel setText:message];
    } 
    else if (anIndex == rowOfFollow) {
        NSString* message = [NSString stringWithFormat:NSLS(@"kCoinsForFollowUs"), [ConfigManager getFollowReward]];            
        message = [NSString stringWithFormat:@"%@ (%@)", NSLS(@"kFollowUs"), message];
        [aCell.textLabel setText:message];
    } 
    else if (anIndex == rowOfAddWords) {
        [aCell.textLabel setText:NSLS(@"kAddWords")];
    } 
    else if (anIndex == rowOfReportBug) {
        [aCell.textLabel setText:NSLS(@"kReport_problems")];
    } else if (anIndex == rowOfFeedback) {
        [aCell.textLabel setText:NSLS(@"kGive_some_advice")];
    } else if (anIndex == rowOfMoreApp) {
        [aCell.textLabel setText:NSLS(@"kMore_apps")];
    } else if (anIndex == rowOfGiveReview) {
        [aCell.textLabel setText:NSLS(@"kGive_a_5-star_review")];
    } else if (anIndex == rowOfAbout) {
        [aCell.textLabel setText:NSLS(@"kAbout_us")];
    } 
    
    
    if ([DeviceDetection isIPAD]) {
        [aCell.textLabel setFont:[UIFont systemFontOfSize:32]];
    } else {
        [aCell.textLabel setFont:[UIFont systemFontOfSize:17]];
    }
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
            NSString* message = [NSString stringWithFormat:NSLS(@"kGetCoinsByShareToFriends"), [ConfigManager getShareFriendReward]];
            [[CommonMessageCenter defaultCenter] postMessageWithText:message delayTime:2.0 isHappy:YES];
        }
        
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    
    NSString *shareBodyModel =nil;
    
    shareBodyModel = [GameApp shareMessageBody];
    

    NSString *shareBody = [NSString stringWithFormat:shareBodyModel, NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:[ConfigManager appId]]];
    
    if (buttonIndex == buttonIndexSMS) {
        [self sendSms:nil body:shareBody];
    } else if (buttonIndex == buttonIndexEmail) {
        NSString *emailSubject = [GameApp shareEmailSubject];

        [self sendEmailTo:nil ccRecipients:nil bccRecipients:nil subject:emailSubject body:shareBody isHTML:NO delegate:self];
    } else if (buttonIndex == buttonIndexSinaWeibo) {
        
        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] publishWeibo:shareBody
                                                                               imageFilePath:nil
                                                                                successBlock:NULL
                                                                                failureBlock:NULL];
        

    } else if (buttonIndex == buttonIndexQQWeibo) {
        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] publishWeibo:shareBody
                                                                               imageFilePath:nil
                                                                                successBlock:NULL
                                                                                failureBlock:NULL];
        

    } else if (buttonIndex == buttonIndexFacebook) {
        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] publishWeibo:shareBody
                                                                               imageFilePath:nil
                                                                                successBlock:NULL
                                                                                failureBlock:NULL];

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
                                                    destructiveButtonTitle:NSLS(@"kShare_via_SMS") 
                                                         otherButtonTitles:NSLS(@"kShare_via_Email"), 
                                       nil];
        
        int shareCount = 2;
        
        if ([[UserManager defaultManager] hasBindSinaWeibo]){
            buttonIndexSinaWeibo = shareCount;
            shareCount ++;
            [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Sina_weibo")];
        }
        
        if ([[UserManager defaultManager] hasBindQQWeibo]){
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
    
    else if (indexPath.row == rowOfFollow){
        if ([[UserManager defaultManager] hasBindQQWeibo]){
            
            [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] followUser:nil
                                                                                      userId:[GameApp qqWeiboId]
                                                                                successBlock:^(NSDictionary *userInfo) {
            } failureBlock:^(NSError *error) {
                
            }];
            
//            [[QQWeiboService defaultService] followUser:[GameApp qqWeiboId] delegate:self];
        }
        
        if ([[UserManager defaultManager] hasBindSinaWeibo]){
            
            [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] followUser:[GameApp sinaWeiboId]
                                                                                        userId:nil
                                                                                  successBlock:^(NSDictionary *userInfo) {
            } failureBlock:^(NSError *error) {
                if (error.code == 20506){
                    //already follow
                    [self popupMessage:@"谢谢，你已经成功关注了官方微博" title:nil];
                }
            }];
            
//            [[SinaSNSService defaultService] followUser:[GameApp sinaWeiboId] delegate:self];
        }
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
        UFPController* rc = [[UFPController alloc] init];
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
    } 
    
    else if (indexPath.row  == rowOfGiveReview) {
        PPDebug(@"<FeedbackController>appId :%@", [ConfigManager appId]);
        [UIUtils gotoReview:[ConfigManager appId]];
    } 
    
    else if (indexPath.row  == rowOfAbout) {
        AboutUsController* rc = [[AboutUsController alloc] init];
        [self.navigationController pushViewController:rc animated:YES];
        [rc release];
    } 
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return FEEDBACK_COUNT;
    return  numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DeviceDetection isIPhone5]) {
        return HEIGHT_FOR_IPHONE5;
    }
    if ([DeviceDetection isIPAD]) {
        return HEIGHT_FOR_IPAD;
    }
    return HEIGHT_FOR_IPHONE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedBackCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FeedBackCell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self initCell:cell withIndex:indexPath.row];
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
    [self.TitleLabel setText:NSLS(@"kFeedback")];
    
    
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
    [dataTableView release];
    [TitleLabel release];
    [backgroundImageView release];
    [_qqGroupLabel release];
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
        [[AccountService defaultService] chargeAccount:[ConfigManager getFollowReward] source:FollowReward];
        [userDefaults setBool:YES forKey:FOLLOW_SINA_KEY];
        [userDefaults synchronize];
    }
    
    if ([[UserManager defaultManager] hasBindQQWeibo] && hasRewardFollowQQ == NO){
        [[AccountService defaultService] chargeAccount:[ConfigManager getFollowReward] source:FollowReward];        
        [userDefaults setBool:YES forKey:FOLLOW_QQ_KEY];
        [userDefaults synchronize];
    }
    
}

@end
