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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case SHARE: {
            ReportController* rc = [[ReportController alloc] init];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
        }
            break;
        case FEEDBACK:
        case REPORT_BUG: {
            ReportController* rc = [[ReportController alloc] init];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
        }
            break;
        case ABOUT: {
            
        }
            break;
        case MORE_APP: {
            
        }
            break;
        case GIVE_REVIEW: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/cn/app/tuan-gou/id456494464?l=en&mt=8"]];
        }
            break;
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return FEEDBACK_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedBackCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FeedBackCell"];
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
