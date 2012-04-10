//
//  UFPController.m
//  Draw
//
//  Created by Orange on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UFPController.h"
#import "UMTableViewCell.h"

@interface UFPController ()

@end

@implementation UFPController
@synthesize mTableView = _mTableView;
@synthesize mPromoterDatas = _mPromoterDatas;
- (void)dealloc
{
    [_mTableView release];
    [_mPromoterDatas release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mTableView = [[UMUFPTableView alloc] initWithFrame:CGRectMake(0, 50, 320, 460-50) style:UITableViewStylePlain appkey:@"4e2d3cc0431fe371c3000029" slotId:@"" currentViewController:self]; 
    self.mTableView.dataSource = self;
    self.mTableView.delegate = self;
    self.mTableView.dataLoadDelegate = self; 
    [self.view addSubview:self.mTableView]; 
    //[self.view insertSubview:maskView aboveSubview:self.mTableView]; 
    [self showActivityWithText:@"loading"];
    [self.mTableView requestPromoterDataInBackground];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDataSource Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.mPromoterDatas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UMUFPTableViewCell";
    
    UMTableViewCell *cell = (UMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *promoter = [self.mPromoterDatas objectAtIndex:indexPath.row];
    cell.textLabel.text = [promoter valueForKey:@"title"];
    cell.detailTextLabel.text = [promoter valueForKey:@"ad_words"];
    [cell setImageURL:[promoter valueForKey:@"icon"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *promoter = [self.mPromoterDatas objectAtIndex:indexPath.row];
    [self.mTableView didClickPromoterAtIndex:promoter index:indexPath.row];
}

#pragma mark - UMTableViewDataLoadDelegate methods

- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview promoters:(NSArray *)promoters {
    [self hideActivity];
    if ([promoters count] > 0)
    {
        self.mPromoterDatas = promoters;
        [self.mTableView reloadData];
    }  
}

- (void)UMUFPTableViewActionDidFinish:(UMUFPTableView *)tableview promoterIndex:(NSInteger)promoterIndex {
    
    NSLog(@"%s, clicked:%d", __PRETTY_FUNCTION__, promoterIndex);
}

- (void)UMUFPTableView:(UMUFPTableView *)tableview didLoadDataFailWithError:(NSError *)error {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}


@end
