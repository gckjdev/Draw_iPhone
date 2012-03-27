//
//  FeedbackController.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedbackController.h"

#define NSLS(x) NSLocalizedString(x, @"")

@implementation FeedbackController
@synthesize dataTableView;



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
            [aCell.textLabel setText:NSLS(@"share to friends")];
        }
            break;
        case REPORT_BUG: {
            [aCell.textLabel setText:NSLS(@"report problems")];
        }
            break;
        case FEEDBACK: {
            [aCell.textLabel setText:NSLS(@"give some advice")];
        }
            break;
        case ABOUT: {
            [aCell.textLabel setText:NSLS(@"about us")];
        }
            break;
        case MORE_APP: {
            [aCell.textLabel setText:NSLS(@"more apps")];
        }
            break;
        case GIVE_REVIEW: {
            [aCell.textLabel setText:NSLS(@"give a 5-star review")];
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
            
        }
            break;
        case REPORT_BUG: {
            
        }
            break;
        case FEEDBACK: {
            
        }
            break;
        case ABOUT: {
            
        }
            break;
        case MORE_APP: {
            
        }
            break;
        case GIVE_REVIEW: {
            
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setDataTableView:nil];
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
    [super dealloc];
}
@end
