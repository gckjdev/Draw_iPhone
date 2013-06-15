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
#import "AlixPayOrderManager.h"
#import "NotificationCenterManager.h"
#import "NotificationName.h"
#import "StringUtil.h"
#import "IAPProductManager.h"
#import "PPNetworkConstants.h"
#import "CommonDialog.h"
#import "PBIAPProduct+Utils.h"

#define ALIPAY_EXTRA_PARAM_KEY_IAP_PRODUCT @"ALIPAY_EXTRA_PARAM_KEY_IAP_PRODUCT"

@interface ChargeController ()

@end

@implementation ChargeController

- (void)dealloc {
    [_countLabel release];
    [_taobaoLinkView release];
    [_currencyImageView release];
    [_countBgImageView release];
    [_restoreButton release];
    [super dealloc];
}

- (void)handleAlipayCallBack:(NSNotification *)note
{
    PPDebug(@"receive message: %@", NOTIFICATION_ALIPAY_PAY_CALLBACK);
    NSDictionary *userInfo = note.userInfo;
    int resultCode = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_CODE] intValue];
    NSString *msg = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_MESSAGE] intValue];
    AlixPayOrder *order = [userInfo objectForKey:ALIPAY_CALLBACK_RESULT_ORDER];
    NSString *alipayProductId = [AlixPayOrderManager productIdFromTradeNo:order.tradeNO];
    PBIAPProduct *product = [[IAPProductManager defaultManager] productWithAlipayProductId:alipayProductId];
    
    if (resultCode == ERROR_SUCCESS) {
        [self showActivityWithText:NSLS(@"kCharging")];
        PBGameCurrency currency = [IAPProductManager currencyWithIAPProductType:product.type];
        [[AccountService defaultService] chargeBalance:currency count:product.count source:ChargeViaAlipay order:order];
    }else{
        [CommonDialog createDialogWithTitle:NSLS(@"kGifTips") message:msg style:CommonDialogStyleSingleButton delegate:nil];
    }
}

- (void)handleJumpToAlipayClient:(NSNotification *)note
{
    PPDebug(@"receive message: %@", NOTIFICATION_JUMP_TO_ALIPAY_CLIENT);
    NSDictionary *userInfo = note.userInfo;
    int resultCode = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_CODE] intValue];
//    NSString *msg = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_MESSAGE] intValue];
    AlixPayOrder *order = [userInfo objectForKey:ALIPAY_CALLBACK_RESULT_ORDER];
    NSString *alipayProductId = [AlixPayOrderManager productIdFromTradeNo:order.tradeNO];
    PBIAPProduct *product = [[IAPProductManager defaultManager] productWithAlipayProductId:alipayProductId];
    
    if (resultCode != ERROR_SUCCESS) {
        [self pushTaobao:product.taobaoUrl];
    }
}

- (id)init
{
    if (self = [super init]) {
        _saleCurrency = [GameApp saleCurrency];
        __block typeof (self)bself = self;
        [[NotificationCenterManager defaultManager] registerNotificationWithName:NOTIFICATION_ALIPAY_PAY_CALLBACK usingBlock:^(NSNotification *note) {
            [bself handleAlipayCallBack:note];
        }];
        
        [[NotificationCenterManager defaultManager] registerNotificationWithName:NOTIFICATION_JUMP_TO_ALIPAY_CLIENT usingBlock:^(NSNotification *note) {
            [bself handleJumpToAlipayClient:note];
        }];
    }
    
    return self;
}

#define COIN_COUNT_LABEL_WIDTH (ISIPAD ? 120 : 60)
#define COIN_COUNT_BG_IMAGE_VIEW_WIDTH (ISIPAD ? 128 : 64)


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([ConfigManager showRestoreButton]) {
        self.restoreButton.hidden = NO;
    } else {
        self.restoreButton.hidden = YES;
    }
    [self.restoreButton setTitle:NSLS(@"kRestore") forState:UIControlStateNormal];
    
    self.currencyImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:_saleCurrency];
    
    if (_saleCurrency == PBGameCurrencyCoin) {
        [self.countLabel updateWidth:COIN_COUNT_LABEL_WIDTH];
        [self.countBgImageView updateWidth:COIN_COUNT_BG_IMAGE_VIEW_WIDTH];
        self.countLabel.center = self.countBgImageView.center;
        self.countBgImageView.image = [UIImage imageNamed:@"coin_count_bg@2x.png"];
    }

    [self updateBalance];
    
    [self updateTaobaoLinkView];
    
    [self showActivityWithText:NSLS(@"kLoading")];
    __block typeof(self) bself = self;
    [[IAPProductService defaultService] syncData:^(BOOL success, NSArray *ingotsList){
        [bself hideActivity];
        bself.dataList = ingotsList;
        [bself.dataTableView reloadData];
    }];
    
    [[AccountService defaultService] setDelegate:self];
    
#ifdef DEBUG
    [IAPProductService createTestDataFile];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    __block typeof(self) bself = self;
    [[AccountService defaultService] syncAccountWithResultHandler:^(int resultCode) {
        [bself updateBalance];
    }];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    [self setCountLabel:nil];
    [self setTaobaoLinkView:nil];
    [self setCurrencyImageView:nil];
    [self setCountBgImageView:nil];
    [self setRestoreButton:nil];
    [super viewDidUnload];
}

- (void)updateBalance
{
    self.countLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:_saleCurrency]];
}

- (void)updateTaobaoLinkView
{
    if (([LocaleUtils isChina] || [LocaleUtils isChinese])
        && [ConfigManager isInReviewVersion] == NO) {
        self.taobaoLinkView.hidden = NO;
    } else {
        self.taobaoLinkView.hidden = YES;
    }
}

- (IBAction)clickBackButton:(id)sender {
    [[AccountService defaultService] setDelegate:nil];
    [[NotificationCenterManager defaultManager] unregisterNotificationWithName:NOTIFICATION_ALIPAY_PAY_CALLBACK];
    [[NotificationCenterManager defaultManager] unregisterNotificationWithName:NOTIFICATION_JUMP_TO_ALIPAY_CLIENT];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushTaobao:(NSString *)taobaoUrl
{    
    TaoBaoController *controller = [[TaoBaoController alloc] initWithURL:taobaoUrl title:NSLS(@"kTaoBaoChargeTitle")];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)clickTaoBaoButton:(id)sender {
    
    NSString *taobaoUrl = nil;
    if ([dataList count] > 0) {
        PBIAPProduct *product = [dataList objectAtIndex:0];
        taobaoUrl = product.taobaoUrl;
    }
    
    if (taobaoUrl == nil || [taobaoUrl length] == 0) {
        taobaoUrl = [ConfigManager getTaobaoHomeUrl];
    }
    [self pushTaobao:taobaoUrl];
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
    BOOL isChina = [LocaleUtils isChina];
    BOOL isChinese = [LocaleUtils isChinese];
    BOOL isInReviewVersion = [ConfigManager isInReviewVersion];
    if ((isChina || isChinese) && isInReviewVersion == NO && [GameApp canPayWithAlipay]) {
        [self showBuyActionSheetWithIndex:indexPath];
    }else{
        PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
        [self applePayForProduct:product];
    }
}


- (void)showBuyActionSheetWithIndex:(NSIndexPath *)indexPath
{
    MKBlockActionSheet *sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kSelectPaymentWay")
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLS(@"kCancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:
                                                                NSLS(@"kPayViaZhiFuBaoWeb"),
                                                                NSLS(@"kPayViaZhiFuBao"),
                                                                NSLS(@"kPayViaAppleAccount"),
                                                                nil];
    [sheet showInView:self.view];
    
    __block typeof (self)bself = self;
    PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
    AlixPayOrder *order = [[[AlixPayOrder alloc] init] autorelease];
    order.partner = [ConfigManager getAlipayPartner];
    order.seller = [ConfigManager getAlipaySeller];
    order.tradeNO = [AlixPayOrderManager tradeNoWithProductId:product.alipayProductId];
    order.productName = [NSString stringWithFormat:@"%d个%@", product.count, NSLS(product.name)];
    order.productDescription = [NSString stringWithFormat:@"description: %@", product.desc];

#ifdef DEBUG
    order.amount = @"0.01";
#else
    order.amount = [product priceInRMB];
#endif

    PPDebug(@"charge price in RMB is %@", [product priceInRMB]);
    
    order.notifyURL = [ConfigManager getAlipayNotifyUrl]; //回调URL
    [[AlixPayOrderManager defaultManager] addOrder:order];
    
    [sheet setActionBlock:^(NSInteger buttonIndex){
        switch (buttonIndex) {
                /*
            case 0:
                // pay via zhifubao
                [bself alipayForOrder:order];
                break;
                
            case 1:
                // pay via apple account
                [bself applePayForProduct:product];
                break;
                 */

//                /*
            case 0:
                // pay via zhifubao
                [bself alipayWebPaymentForOrder:order product:product];
                break;
                
            case 1:
                // pay via zhifubao
                [bself alipayForOrder:order];
                break;

            case 2:
                // pay via apple account
                [bself applePayForProduct:product];
                break;
//                 */
                
            default:
                break;
        }
    }];
    
    [sheet release];
}

- (void)alipayForOrder:(AlixPayOrder *)order
{
    [AliPayManager payWithOrder:order
                      appScheme:[GameApp alipayCallBackScheme]
                  rsaPrivateKey:[ConfigManager getAlipayRSAPrivateKey]];
    
    
}

- (void)alipayWebPaymentForOrder:(AlixPayOrder *)order product:(PBIAPProduct*)product
{
    NSString* url = [ConfigManager getAlipayWebUrl];
    url = [url stringByAddQueryParameter:METHOD value:@"charge"];
    url = [url stringByAddQueryParameter:PARA_APPID value:[GameApp appId]];
    url = [url stringByAddQueryParameter:PARA_GAME_ID value:[GameApp gameId]];
    url = [url stringByAddQueryParameter:PARA_AMOUNT value:order.amount];
    url = [url stringByAddQueryParameter:PARA_DESC value:order.productName];
    url = [url stringByAddQueryParameter:PARA_URL value:product.taobaoUrl];
    url = [url stringByAddQueryParameter:PARA_USERID value:[[UserManager defaultManager] userId]];
    url = [url stringByAddQueryParameter:PARA_TYPE intValue:product.type];
    url = [url stringByAddQueryParameter:PARA_COUNT intValue:product.count];
    
//    NSString* url = [NSString stringWithFormat:[ConfigManager getAlipayWebUrl],
//                     [order.productName encodedURLParameterString], order.amount];
    NSString* title = [NSString stringWithFormat:@"充值 - %@", order.productName];
    TaoBaoController* vc = [[TaoBaoController alloc] initWithURL:url title:title];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)applePayForProduct:(PBIAPProduct *)product
{
    if ([MobClick isJailbroken]) {
        
        __block typeof (self)bself = self;
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGifTips") message:NSLS(@"kJailBrokenUserIAPTips") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
            [bself showActivityWithText:NSLS(@"kBuying")];
            [[AccountService defaultService] buyProduct:product];
        } clickCancelBlock:^{
        }];
        
        [dialog showInView:self.view];
        
    }else{
        [self showActivityWithText:NSLS(@"kBuying")];
        [[AccountService defaultService] buyProduct:product];
    }
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

- (IBAction)clickRestoreButton:(id)sender {
    [[AccountService defaultService] restoreIAPPurchase];
}

@end
