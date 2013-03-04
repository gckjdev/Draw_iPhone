//
//  StoreController.m
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "StoreController.h"
#import "GameItemService.h"
#import "StoreCell.h"

@interface StoreController ()

@end

@implementation StoreController

- (void)dealloc {
    [_titleLabel release];
    [_backButton release];
    [_chargeButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setBackButton:nil];
    [self setChargeButton:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLS(@"kStore");
    [self.chargeButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];
    
    [[GameItemService sharedGameItemService] getItemsListWithType:PBDrawItemTypeNomal resultHandler:^(BOOL success, NSArray *itemsList) {
            self.dataList = itemsList;
    }];
    
    [self.dataTableView reloadData];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickChargeButton:(id)sender {
}

- (IBAction)clickNormalItemsButton:(id)sender {
    [[GameItemService sharedGameItemService] getItemsListWithType:PBDrawItemTypeNomal resultHandler:^(BOOL success, NSArray *itemsList) {
        self.dataList = itemsList;
    }];
    
    [self.dataTableView reloadData];
}

- (IBAction)clickToolItemsButton:(id)sender {
    [[GameItemService sharedGameItemService] getItemsListWithType:PBDrawItemTypeTool resultHandler:^(BOOL success, NSArray *itemsList) {
        self.dataList = itemsList;
    }];
    
    [self.dataTableView reloadData];
}

- (IBAction)clickPromotionItemsButton:(id)sender {
    [[GameItemService sharedGameItemService] getPromotingItemsList:^(BOOL success, NSArray *itemsList) {
        self.dataList = itemsList;
    }];
    
    [self.dataTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [StoreCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreCell *cell = [tableView dequeueReusableCellWithIdentifier:[StoreCell getCellIdentifier]];
    
    if (cell == nil) {
        cell = [StoreCell createCell:self];
    }
    
    [cell setCellInfo:[dataList objectAtIndex:indexPath.row]];
    
    return cell;
}



@end
