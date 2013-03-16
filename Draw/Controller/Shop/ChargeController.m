//
//  ChargeController.m
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import "ChargeController.h"
#import "IngotService.h"
#import "AccountService.h"

@interface ChargeController ()

@end

@implementation ChargeController

- (void)dealloc {
    [_ingotCountLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setIngotCountLabel:nil];
    [super viewDidUnload];
}

- (void)updateIngot
{
    self.ingotCountLabel.text = [NSString stringWithFormat:@"%d", [[AccountService defaultService] getBalanceWithCurrency:PBGameCurrencyIngot]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateIngot];
    
    __block typeof(self) bself = self;
    [[IngotService sharedIngotService] getIngotsList:^(BOOL success, NSArray *ingotsList){
        bself.dataList = ingotsList;
        [bself.dataTableView reloadData];
    }];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:[ChargeCell getCellIdentifier]];
    if (cell == nil) {
        cell = [ChargeCell createCell:self];
    }
    
    PBSaleIngot *saleIngot = [dataList objectAtIndex:indexPath.row];
    [cell setCellWith:saleIngot indexPath:indexPath];
    
    return cell;
}

#pragma mark -
#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChargeCell getCellHeight];
}

#pragma mark -
#pragma ChargeCellDelegate method
- (void)didClickBuyButton:(NSIndexPath *)indexPath
{
    PBSaleIngot *saleIngot = [dataList objectAtIndex:indexPath.row];
    
    //[self showActivityWithText:NSLS(@"kBuying")];
    [[AccountService defaultService] buyIngot:saleIngot];
}

@end
