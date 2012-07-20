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
#import "SinaSNSService.h"
#import "QQWeiboService.h"
#import "FacebookSNSService.h"
#import "UFPController.h"
#import "PPDebug.h"
#import "DeviceDetection.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"
#import "AccountService.h"

@implementation FeedbackController
@synthesize dataTableView;
@synthesize TitleLabel;



#pragma mark - Table dataSource ,table view delegate
enum {
    SHARE = 0,
    ADD_WORDS,
    REPORT_BUG,
    FEEDBACK,
    MORE_APP,
    GIVE_REVIEW,
    ABOUT,
    FEEDBACK_COUNT
};

- (void)initCell:(UITableViewCell*)aCell withIndex:(int)anIndex
{
    [aCell.textLabel setTextColor:[UIColor colorWithRed:0x6c/255.0 green:0x31/255.0 blue:0x08/255.0 alpha:1.0]];
    switch (anIndex) {
        case SHARE: {
            
            NSString* message = [NSString stringWithFormat:NSLS(@"kCoinsForShareToFriends"), [ConfigManager getShareFriendReward]];            
            message = [NSString stringWithFormat:@"%@ (%@)", NSLS(@"kShare_to_friends"), message];
            [aCell.textLabel setText:message];
        }
            break;
        case REPORT_BUG: {
            [aCell.textLabel setText:NSLS(@"kReport_problems")];
        }
            break;
        case FEEDBACK: {
            [aCell.textLabel setText:NSLS(@"kGive_some_advice")];
        }
            break;
        case ABOUT: {
            [aCell.textLabel setText:NSLS(@"kAbout_us")];
        }
            break;
        case MORE_APP: {
            [aCell.textLabel setText:NSLS(@"kMore_apps")];
        }
            break;
        case GIVE_REVIEW: {
            [aCell.textLabel setText:NSLS(@"kGive_a_5-star_review")];
        }
            break;
        case ADD_WORDS: {
            [aCell.textLabel setText:NSLS(@"kAddWords")];
        }
            break;
        default:
            break;
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
        [[AccountService defaultService] chargeAccount:[ConfigManager getShareFriendReward] source:ShareAppReward];        
        
        // show message
        NSString* message = [NSString stringWithFormat:NSLS(@"kGetCoinsByShareToFriends"), [ConfigManager getShareFriendReward]];
        [[CommonMessageCenter defaultCenter] postMessageWithText:message delayTime:2.0 isHappy:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    switch (buttonIndex) {
        case SHARE_VIA_SMS: {
            [self sendSms:nil body:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:[ConfigManager appId]]]];
        } break;
        case SHARE_VIA_EMAIL: {
            [self sendEmailTo:nil ccRecipients:nil bccRecipients:nil subject:NSLS(@"kEmail_subject") body:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:[ConfigManager appId]]] isHTML:NO delegate:self];
        } break;
        case SHARE_VIA_FACEBOOK: {
            if ([[UserManager defaultManager] hasBindSinaWeibo]){
                [[SinaSNSService defaultService] publishWeibo:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:[ConfigManager appId]]] delegate:self];
            }
            
            if ([[UserManager defaultManager] hasBindQQWeibo]){
                [[QQWeiboService defaultService] publishWeibo:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:[ConfigManager appId]]] delegate:self];
            }
            
            if ([[UserManager defaultManager] hasBindFacebook]){
                [[FacebookSNSService defaultService] publishWeibo:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:[ConfigManager appId]]] delegate:self];
            } 
        } break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case SHARE: {
            UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_Options") 
                                                                      delegate:self 
                                                             cancelButtonTitle:nil 
                                                        destructiveButtonTitle:NSLS(@"kShare_via_SMS") 
                                                             otherButtonTitles:NSLS(@"kShare_via_Email"), 
                                           nil];
            
            int shareCount = 2;
            
            if ([[UserManager defaultManager] hasBindSinaWeibo]){
                shareCount ++;
                [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Sina_weibo")];
            }
            
            if ([[UserManager defaultManager] hasBindQQWeibo]){
                shareCount ++;
                [shareOptions addButtonWithTitle:NSLS(@"kShare_via_tencent_weibo")];
            }
            
            if ([[UserManager defaultManager] hasBindFacebook]){
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
            break;
        case FEEDBACK: {
            ReportController* rc = [[ReportController alloc] initWithType:SUBMIT_FEEDBACK];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
        } break;
        case REPORT_BUG: {
            ReportController* rc = [[ReportController alloc] initWithType:SUBMIT_BUG];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
        }
            break;
        case ABOUT: {
            AboutUsController* rc = [[AboutUsController alloc] init];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
        }
            break;
        case MORE_APP: {
            UFPController* rc = [[UFPController alloc] init];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
        }
            break;
        case GIVE_REVIEW: {
            [UIUtils gotoReview:[ConfigManager appId]];
        }
            break;
        case ADD_WORDS: {
            ReportController* rc = [[ReportController alloc] initWithType:ADD_WORD];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return FEEDBACK_COUNT;
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
    [super viewDidLoad];
    [self.TitleLabel setText:NSLS(@"kFeedback")];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setDataTableView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [dataTableView release];
    [TitleLabel release];
    [super dealloc];
}
@end
