//
//  ChargeController.m
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import "ChargeController.h"
#import "IngotService.h"
#import "AccountManager.h"
#import "TaoBaoController.h"

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
    self.ingotCountLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyIngot]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateIngot];
    
    __block typeof(self) bself = self;
    [[IngotService defaultService] syncData:^(BOOL success, NSArray *ingotsList){
        bself.dataList = ingotsList;
        [bself.dataTableView reloadData];
    }];
    
    [IngotService createTestDataFile];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickTaoBaoButton:(id)sender {
    TaoBaoController *controller = [[TaoBaoController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
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
    [self showActivityWithText:NSLS(@"kBuying")];
    [[AccountService defaultService] setDelegate:self];
    [[AccountService defaultService] buyIngot:saleIngot];
}

- (void)didFinishBuyProduct:(int)resultCode
{
    [self hideActivity];
    
    if (resultCode != ERROR_SUCCESS && resultCode != PAYMENT_CANCEL){
        [self popupMessage:NSLS(@"kFailToConnectIAPServer") title:nil];
        return;
    }
    else if (resultCode == PAYMENT_CANCEL){
        return;
    }
    
    if (resultCode == ERROR_SUCCESS){
        [self showActivityWithText:NSLS(@"kChargingIngot")];
    }
}

- (void)didFinishChargeIngot:(int)resultCode
{
    [self hideActivity];
    if (resultCode == ERROR_SUCCESS) {
        [self updateIngot];
        [self popupMessage:NSLS(@"kChargIngotSuccess") title:nil];
    }else{
        [self popupMessage:NSLS(@"kChargIngotFailure") title:nil];
    }
}

- (void)didProcessingBuyProduct
{
    [self hideActivity];
    [self showActivityWithText:NSLS(@"kProcessingIAP")];
}

@end
