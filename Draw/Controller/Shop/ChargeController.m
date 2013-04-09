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
#import "MobClickUtils.h"
#import "ConfigManager.h"



@interface ChargeController ()

@end

@implementation ChargeController

- (void)dealloc {
    [_ingotCountLabel release];
    [_taobaoLinkView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setIngotCountLabel:nil];
    [self setTaobaoLinkView:nil];
    [super viewDidUnload];
}

- (id)init
{
    if (self = [super init]) {
        _saleCurrency = PBGameCurrencyIngot;
    }
    
    return self;
}


- (id)initWithSaleCurrency:(PBGameCurrency)saleCurrency
{
    if (self = [super init]) {
        _saleCurrency = saleCurrency;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateBalance];
    
    [self updateTaobaoLinkView];
    
    __block typeof(self) bself = self;
    [[IngotService defaultService] syncData:^(BOOL success, NSArray *ingotsList){
        bself.dataList = ingotsList;
        [bself.dataTableView reloadData];
    }];
}


- (void)updateBalance
{
    self.ingotCountLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyIngot]];
}

- (void)updateTaobaoLinkView
{
    if ([LocaleUtils isChina] && [ConfigManager isInReviewVersion] == NO) {
        self.taobaoLinkView.hidden = NO;
    } else {
        self.taobaoLinkView.hidden = YES;
    }
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickTaoBaoButton:(id)sender {
    NSString *urlString = [ConfigManager getTaobaoChargeURL];
    
    TaoBaoController *controller = [[TaoBaoController alloc] initWithURL:urlString title:NSLS(@"kTaoBaoChargeTitle")];
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
        [self showActivityWithText:NSLS(@"kCharging")];
    }
}

- (void)didFinishChargeIngot:(int)resultCode
{
    [self hideActivity];
    if (resultCode == ERROR_SUCCESS) {
        [self updateBalance];
        [self popupMessage:NSLS(@"kChargSuccess") title:nil];
    }else{
        [self popupMessage:NSLS(@"kChargFailure") title:nil];
    }
}

- (void)didProcessingBuyProduct
{
    [self hideActivity];
    [self showActivityWithText:NSLS(@"kProcessingIAP")];
}

@end
