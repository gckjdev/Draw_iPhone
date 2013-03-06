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
#import "GameItemDetailView.h"

@interface StoreController ()

@property (retain, nonatomic) UIButton *selectedButton;

@end

@implementation StoreController

- (void)dealloc {
    [_selectedButton release];
    [_titleLabel release];
    [_backButton release];
    [_chargeButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setSelectedButton:nil];
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
    
    [self clickNormalItemsButton:nil];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickChargeButton:(id)sender {
}

- (IBAction)clickNormalItemsButton:(id)sender {
    self.selectedButton.selected = NO;
    self.selectedButton = (UIButton *)sender;
    self.selectedButton.selected = YES;
    
    [[GameItemService sharedGameItemService] getItemsListWithType:PBDrawItemTypeNomal resultHandler:^(BOOL success, NSArray *itemsList) {
        self.dataList = itemsList;
        [self.dataTableView reloadData];
    }];
}

- (IBAction)clickToolItemsButton:(id)sender {
    self.selectedButton.selected = NO;
    self.selectedButton = (UIButton *)sender;
    self.selectedButton.selected = YES;
    
    [[GameItemService sharedGameItemService] getItemsListWithType:PBDrawItemTypeTool resultHandler:^(BOOL success, NSArray *itemsList) {
        self.dataList = itemsList;
        [self.dataTableView reloadData];
    }];
}

- (IBAction)clickPromotionItemsButton:(id)sender {
    self.selectedButton.selected = NO;
    self.selectedButton = (UIButton *)sender;
    self.selectedButton.selected = YES;
    
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    [[GameItemService sharedGameItemService] getPromotingItemsList:^(BOOL success, NSArray *itemsList) {
        bself.dataList = itemsList;
        [bself.dataTableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PPDebug(@"dataList : %@", dataList);
    return [self.dataList count];
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
    
    [cell setCellInfo:[self.dataList objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameItemDetailView *view = [GameItemDetailView createWithItem:[dataList objectAtIndex:indexPath.row]];
    [view showInView:self.view];
}



@end
