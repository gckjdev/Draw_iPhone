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

@implementation FeedbackController
@synthesize dataTableView;
@synthesize TitleLabel;



#pragma mark - Table dataSource ,table view delegate
enum {
    SHARE = 0,
    REPORT_BUG,
    FEEDBACK,
    ABOUT,
    MORE_APP,
    GIVE_REVIEW,
    FEEDBACK_COUNT
};

- (void)initCell:(UITableViewCell*)aCell withIndex:(int)anIndex
{
    [aCell.textLabel setTextColor:[UIColor colorWithRed:0x6c/255.0 green:0x31/255.0 blue:0x08/255.0 alpha:1.0]];
    switch (anIndex) {
        case SHARE: {
            [aCell.textLabel setText:NSLS(@"kShare_to_friends")];
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
        default:
            break;
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
#ifdef DEBUG
    PPDebug(@"publish weibo result : %d", result);
#endif
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case SHARE_VIA_SMS: {
            [self sendSms:nil body:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:APP_ID]]];
        } break;
        case SHARE_VIA_EMAIL: {
            [self sendEmailTo:nil ccRecipients:nil bccRecipients:nil subject:NSLS(@"kEmail_subject") body:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:APP_ID]] isHTML:YES delegate:self];
        } break;
        case SHARE_VIA_FACEBOOK: {
            if ([[UserManager defaultManager] hasBindSinaWeibo]){
                [[SinaSNSService defaultService] publishWeibo:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:APP_ID]] delegate:self];
            }
            
            if ([[UserManager defaultManager] hasBindQQWeibo]){
                [[QQWeiboService defaultService] publishWeibo:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:APP_ID]] delegate:self];
            }
            
            if ([[UserManager defaultManager] hasBindFacebook]){
                [[FacebookSNSService defaultService] publishWeibo:[NSString stringWithFormat:NSLS(@"kShare_message_body"), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @""),[UIUtils getAppLink:APP_ID]] delegate:self];
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
            
            if ([[UserManager defaultManager] hasBindSinaWeibo]){
                [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Sina_weibo")];
            }
            
            if ([[UserManager defaultManager] hasBindQQWeibo]){
                [shareOptions addButtonWithTitle:NSLS(@"kShare_via_tencent_weibo")];
            }
            
            if ([[UserManager defaultManager] hasBindFacebook]){
                [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Facebook")];
            } 
            [shareOptions addButtonWithTitle:NSLS(@"kCancel")];
            [shareOptions setCancelButtonIndex:SHARE_COUNT];
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
            [UIUtils gotoReview:APP_ID];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [dataTableView release];
    [TitleLabel release];
    [super dealloc];
}
@end
