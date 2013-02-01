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
@synthesize bgImageView;
@synthesize controllerTitle;


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
    
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[GameApp background]]]];
    
    [self.bgImageView setImage:[UIImage imageNamed:[GameApp background]]];
    
    [self.dataTableView setBackgroundView:nil];

    [self.controllerTitle.titleLabel setText:NSLS(@"kCustomDice")];
    
}

- (void)viewDidUnload
{
    [self setBgImageView:nil];
    [self setControllerTitle:nil];
    [self setControllerTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        if ([[CustomDiceManager defaultManager] getMyDiceType] == CustomDiceTypeDefault) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    if (indexPath.row-1 < self.dataList.count && indexPath.row > 0) {
        Item* item = (Item*)[self.dataList objectAtIndex:(indexPath.row-1)];
        [cell setCellInfo:item];
        if ([[CustomDiceManager defaultManager] getMyDiceType] == [CustomDiceManager itemTypeToCustomDiceType:item.type]) {
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
        [[CustomDiceManager defaultManager] setMyDiceTypeByItemType:ItemTypeCustomDiceStart];
    } else {
        if (indexPath.row-1 < self.dataList.count) {
            Item* item = (Item*)[self.dataList objectAtIndex:(indexPath.row-1)];
            [[CustomDiceManager defaultManager] setMyDiceTypeByItemType:item.type];
        }
    }
    [self.dataTableView reloadData];
}

- (void)dealloc {
    [bgImageView release];

    [controllerTitle release];
    [super dealloc];
}
@end
