//
//  CustomDiceSettingViewController.m
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomDiceSettingViewController.h"
#import "CustomDiceSettingCell.h"
#import "CustomDiceManager.h"

@interface CustomDiceSettingViewController ()

@end

@implementation CustomDiceSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataList = [[CustomDiceManager defaultManager] myCustomDiceList]; 
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

#pragma mark - TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomDiceSettingCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomDiceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:[CustomDiceSettingCell getCellIdentifier]];
    if (cell == nil) {
        cell = [CustomDiceSettingCell createCell:[CustomDiceSettingCell getCellIdentifier]];
    }
    
    if (indexPath.row < self.dataList.count) {
        Item* item = (Item*)[self.dataList objectAtIndex:indexPath.row];
        [cell setCellInfo:item];
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

@end
