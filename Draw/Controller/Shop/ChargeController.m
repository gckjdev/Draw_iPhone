//
//  ChargeController.m
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import "ChargeController.h"
#import "IAPProductService.h"
#import "AccountManager.h"
#import "TaoBaoController.h"
#import "MobClickUtils.h"
#import "ConfigManager.h"
#import "ShareImageManager.h"
#import "UIViewUtils.h"
#import "MKBlockActionSheet.h"
#import "AliPayManager.h"
#import "StringUtil.h"

@interface ChargeController ()

@end

@implementation ChargeController

- (void)dealloc {
    [[AccountService defaultService] setDelegate:nil];
    [_countLabel release];
    [_taobaoLinkView release];
    [_currencyImageView release];
    [_countBgImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setCountLabel:nil];
    [self setTaobaoLinkView:nil];
    [self setCurrencyImageView:nil];
    [self setCountBgImageView:nil];
    [super viewDidUnload];
}

- (id)init
{
    if (self = [super init]) {
        _saleCurrency = [GameApp saleCurrency];
    }
    
    return self;
}

#define COIN_COUNT_LABEL_WIDTH (ISIPAD ? 120 : 60)
#define COIN_COUNT_BG_IMAGE_VIEW_WIDTH (ISIPAD ? 128 : 64)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currencyImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:_saleCurrency];
    
    if (_saleCurrency == PBGameCurrencyCoin) {
        [self.countLabel updateWidth:COIN_COUNT_LABEL_WIDTH];
        [self.countBgImageView updateWidth:COIN_COUNT_BG_IMAGE_VIEW_WIDTH];
        self.countLabel.center = self.countBgImageView.center;
        self.countBgImageView.image = [UIImage imageNamed:@"coin_count_bg@2x.png"];
    }

    [self updateBalance];
    
    [self updateTaobaoLinkView];
    
    __block typeof(self) bself = self;
    [[IAPProductService defaultService] syncData:^(BOOL success, NSArray *ingotsList){
        bself.dataList = ingotsList;
        [bself.dataTableView reloadData];
    }];
    
#ifdef DEBUG
    [IAPProductService createTestDataFile];
#endif
}

- (void)updateBalance
{
    self.countLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:_saleCurrency]];
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
    
    PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
    [cell setCellWith:product indexPath:indexPath];
    
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
    MKBlockActionSheet *sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kSelectPaymentWay") delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kPayViaZhiFuBao"), NSLS(@"kPayViaAppleAccount"),nil];
    [sheet showInView:self.view];
    

    __block typeof (self)bself = self;
    PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
    
//    @property(nonatomic, copy) NSString * partner;
//    @property(nonatomic, copy) NSString * seller;
//    @property(nonatomic, copy) NSString * tradeNO;
//    @property(nonatomic, copy) NSString * productName;
//    @property(nonatomic, copy) NSString * productDescription;
//    @property(nonatomic, copy) NSString * amount;
//    @property(nonatomic, copy) NSString * notifyURL;
    
    
    AlixPayOrder *order = [[[AlixPayOrder alloc] init] autorelease];
    order.partner = [ConfigManager getAlipayPartner];
    order.seller = [ConfigManager getAlipaySeller];
    order.tradeNO = [NSString GetUUID];

    
    
    [sheet setActionBlock:^(NSInteger buttonIndex){
        switch (buttonIndex) {
            case 0:
                // TODO: pay via zhifubao
                
                break;
                
            case 1:
                // pay via apple account
                [bself showActivityWithText:NSLS(@"kBuying")];
                [[AccountService defaultService] setDelegate:bself];
                [[AccountService defaultService] buyProduct:product];
                
            default:
                break;
        }
    }];
    
    [sheet release];
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

- (void)didFinishChargeCurrency:(PBGameCurrency)currency resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode == ERROR_SUCCESS) {
        [self updateBalance];
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
