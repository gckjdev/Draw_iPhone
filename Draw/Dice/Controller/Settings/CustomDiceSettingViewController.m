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
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == 0) {
        [cell setDefault];
        if ([[CustomDiceManager defaultManager] getMyDiceType] == ItemTypeCustomDiceStart) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    if (indexPath.row-1 < self.dataList.count && indexPath.row > 0) {
        Item* item = (Item*)[self.dataList objectAtIndex:(indexPath.row-1)];
        [cell setCellInfo:item];
        if ([[CustomDiceManager defaultManager] getMyDiceType] == item.type) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }

    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count+1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [[CustomDiceManager defaultManager] setMyDiceType:ItemTypeCustomDiceStart];
    } else {
        if (indexPath.row-1 < self.dataList.count) {
            Item* item = (Item*)[self.dataList objectAtIndex:(indexPath.row-1)];
            [[CustomDiceManager defaultManager] setMyDiceType:item.type];
        }
    }
    [self.dataTableView reloadData];
}

@end
