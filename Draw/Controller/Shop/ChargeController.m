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
//#import "TaoBaoController.h"
#import "MobClickUtils.h"
#import "PPConfigManager.h"
#import "ShareImageManager.h"
#import "UIViewUtils.h"
#import "MKBlockActionSheet.h"
//#import "AliPayManager.h"
#import "StringUtil.h"
//#import "AlixPayOrderManager.h"
#import "NotificationCenterManager.h"
#import "NotificationName.h"
#import "StringUtil.h"
#import "IAPProductManager.h"
#import "PPNetworkConstants.h"
#import "CommonDialog.h"
#import "PBIAPProduct+Utils.h"
#import "SKProductService.h"


//#define ALIPAY_EXTRA_PARAM_KEY_IAP_PRODUCT @"ALIPAY_EXTRA_PARAM_KEY_IAP_PRODUCT"

@interface ChargeController ()

@end

@implementation ChargeController

- (void)dealloc {
    
    [self unregisterAllNotifications];
    
    [_countLabel release];
    [_taobaoLinkView release];
    [_currencyImageView release];
    [_countBgImageView release];
    [_balanceBgImageView release];
    [_taobaoButton release];
    [_balanceTipLabel release];
    [_taobaoLabel release];
    [super dealloc];
}

//- (void)handleAlipayCallBack:(NSNotification *)note
//{
//    PPDebug(@"receive message: %@", NOTIFICATION_ALIPAY_PAY_CALLBACK);
//    NSDictionary *userInfo = note.userInfo;
//    int resultCode = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_CODE] intValue];
//    NSString *msg = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_MESSAGE] intValue];
//    AlixPayOrder *order = [userInfo objectForKey:ALIPAY_CALLBACK_RESULT_ORDER];
//    NSString *alipayProductId = [AlixPayOrderManager productIdFromTradeNo:order.tradeNO];
//    PBIAPProduct *product = [[IAPProductManager defaultManager] productWithAlipayProductId:alipayProductId];
//
//    if (resultCode == ERROR_SUCCESS) {
//        [self showActivityWithText:NSLS(@"kCharging")];
//        PBGameCurrency currency = [IAPProductManager currencyWithIAPProductType:product.type];
//        [[AccountService defaultService] chargeBalance:currency count:product.count source:ChargeViaAlipay order:order];
//    }else{
//        [CommonDialog createDialogWithTitle:NSLS(@"kGifTips")
//                                    message:msg
//                                      style:CommonDialogStyleSingleButton];
//
////        POSTMSG(@"支付失败");
//    }
//}

//- (void)handleJumpToAlipayClient:(NSNotification *)note
//{
//    PPDebug(@"receive message: %@", NOTIFICATION_JUMP_TO_ALIPAY_CLIENT);
//    NSDictionary *userInfo = note.userInfo;
//    int resultCode = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_CODE] intValue];
////    NSString *msg = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_MESSAGE] intValue];
//    AlixPayOrder *order = [userInfo objectForKey:ALIPAY_CALLBACK_RESULT_ORDER];
//    NSString *alipayProductId = [AlixPayOrderManager productIdFromTradeNo:order.tradeNO];
//    PBIAPProduct *product = [[IAPProductManager defaultManager] productWithAlipayProductId:alipayProductId];
//
//    if (resultCode != ERROR_SUCCESS) {
//        [self pushTaobao:product.taobaoUrl];
//    }
//}

- (id)init
{
    if (self = [super init]) {
        _saleCurrency = [GameApp saleCurrency];
        __block typeof (self)bself = self;
//        [[NotificationCenterManager defaultManager] registerNotificationWithName:NOTIFICATION_ALIPAY_PAY_CALLBACK usingBlock:^(NSNotification *note) {
//            [bself handleAlipayCallBack:note];
//        }];
//
//        [[NotificationCenterManager defaultManager] registerNotificationWithName:NOTIFICATION_JUMP_TO_ALIPAY_CLIENT usingBlock:^(NSNotification *note) {
//            [bself handleJumpToAlipayClient:note];
//        }];
    }
    
    return self;
}

#define COIN_COUNT_LABEL_WIDTH (ISIPAD ? 120 : 60)
#define COIN_COUNT_BG_IMAGE_VIEW_WIDTH (ISIPAD ? 128 : 64)


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCanDragBack:NO];
    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:NSLS(@"kChargeTitle")];
    [titleView setRightButtonTitle:NSLS(@"kRestore")];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [titleView setRightButtonSelector:@selector(clickRestoreButton:)];
    
    if ([PPConfigManager showRestoreButton]) {
        
        [titleView showRightButton];
    } else {
        
        [titleView hideRightButton];
    }
    


    if ([PPConfigManager showRestoreButton]) {
        [titleView showRightButton];
    } else {
        [titleView hideRightButton];
    }
    
    self.currencyImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:_saleCurrency];
    
    if (_saleCurrency == PBGameCurrencyCoin) {
        [self.countLabel updateWidth:COIN_COUNT_LABEL_WIDTH];
        [self.countBgImageView updateWidth:COIN_COUNT_BG_IMAGE_VIEW_WIDTH];
        self.countLabel.center = self.countBgImageView.center;
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
    
    
    self.balanceBgImageView.backgroundColor = COLOR_RED;
    [self.taobaoButton setBackgroundColor:COLOR_RED];

    self.balanceTipLabel.textColor = COLOR_WHITE;
    self.countLabel.textColor = COLOR_WHITE;
    self.taobaoLabel.textColor = COLOR_WHITE;

}

- (void)viewDidAppear:(BOOL)animated
{
    [[AccountService defaultService] syncAccountWithResultHandler:nil];
    [super viewDidAppear:animated];
    
    [self registerNotificationWithName:NOTIFICATION_SYNC_ACCOUNT usingBlock:^(NSNotification *note) {
        [self updateBalance];
    }];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [self setCountLabel:nil];
    [self setTaobaoLinkView:nil];
    [self setCurrencyImageView:nil];
    [self setCountBgImageView:nil];
    [self setBalanceBgImageView:nil];
    [self setTaobaoButton:nil];
    [self setBalanceTipLabel:nil];
    [self setTaobaoLabel:nil];
    [super viewDidUnload];
}

- (void)updateBalance
{
    self.countLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:_saleCurrency]];
}

- (void)updateTaobaoLinkView
{
    self.taobaoLinkView.hidden = YES;
    
    
//    if (([LocaleUtils isChina] || [LocaleUtils isChinese])
//        && [PPConfigManager isInReviewVersion] == NO) {
//        self.taobaoLinkView.hidden = NO;
//    } else {
//        self.taobaoLinkView.hidden = YES;
//    }
}

- (IBAction)clickBackButton:(id)sender {
    [[AccountService defaultService] setDelegate:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)pushTaobao:(NSString *)taobaoUrl
//{    
//    TaoBaoController *controller = [[TaoBaoController alloc] initWithURL:taobaoUrl title:NSLS(@"kTaoBaoChargeTitle")];
//    [self.navigationController pushViewController:controller animated:YES];
//    [controller release];
//}
//
//- (IBAction)clickTaoBaoButton:(id)sender {
//    
//    NSString *taobaoUrl = nil;
//    if ([dataList count] > 0) {
//        PBIAPProduct *product = [dataList objectAtIndex:0];
//        taobaoUrl = product.taobaoUrl;
//    }
//    
//    if (taobaoUrl == nil || [taobaoUrl length] == 0) {
//        taobaoUrl = [PPConfigManager getTaobaoHomeUrl];
//    }
//    [self pushTaobao:taobaoUrl];
//}

#pragma mark - UITableViewDataSource
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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChargeCell getCellHeight];
}

#pragma mark - ChargeCellDelegate method
- (void)didClickBuyButton:(NSIndexPath *)indexPath
{
    BOOL isChina = [LocaleUtils isChina];
    BOOL isChinese = [LocaleUtils isChinese];
    BOOL isInReviewVersion = [PPConfigManager isInReviewVersion];
    if ((isChina || isChinese) && isInReviewVersion == NO && [GameApp canPayWithAlipay]) {
        [self showBuyActionSheetWithIndex:indexPath];
    }else{
        PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
        [self applePayForProduct:product];
    }
}

- (void)showBuyActionSheetWithIndex:(NSIndexPath *)indexPath
{
    PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
    [self applePayForProduct:product];
    
    /*
    MKBlockActionSheet *sheet =
    [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kSelectPaymentWay")
                                     delegate:nil
                            cancelButtonTitle:NSLS(@"kCancel")
                       destructiveButtonTitle:nil
                            otherButtonTitles:
                            //NSLS(@"kPayViaZhiFuBaoWeb"),
                            NSLS(@"kPayViaZhiFuBao"),
//                            NSLS(@"kPayViaWechatPay"),
                            NSLS(@"kPayViaAppleAccount"),
                            nil];
    [sheet showInView:self.view];
    
    PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
    
    // alipay order construction
    AlixPayOrder *order = [[[AlixPayOrder alloc] init] autorelease];
    order.partner = [PPConfigManager getAlipayPartner];
    order.seller = [PPConfigManager getAlipaySeller];
    order.tradeNO =  [AlixPayOrderManager tradeNoWithProductId:product.alipayProductId];
    order.productName = [NSString stringWithFormat:@"%ld个%@", product.count, NSLS(product.name)];
    order.productDescription = [NSString stringWithFormat:@"【产品描述】%@", product.name];

    order.productChargeType = PRODUCT_TYPE_INGOT;
    order.productChargeAmount = product.count;

#ifdef DEBUG
    order.amount = @"0.01";
#else
    order.amount = [product priceInRMB];
#endif
    PPDebug(@"charge price in RMB is %@", [product priceInRMB]);
    order.notifyURL = [PPConfigManager getAlipayNotifyUrl]; //回调URL
    [[AlixPayOrderManager defaultManager] addOrder:order];
    
    //微信支付所需要的参数,其中price微信需要以分为单位,所以做了简单转换 TODO for charlie 测试！
    NSString* wxOrderName = [NSString stringWithFormat:@"%ld个%@", product.count, NSLS(product.name)];
    NSString* wxOrderPrice = [NSString stringWithFormat:@"%.0f", [order.amount floatValue]*100];
    
    PPDebug(@"WeChatPay OrderName=%@, Price=%@", wxOrderName, wxOrderPrice);
    
    //actions of the sheet
    [sheet setActionBlock:^(NSInteger buttonIndex){
        switch (buttonIndex) {
            
            case 0:

                [[AliPayManager defaultService] pay:order.tradeNO
                                            subject:order.productName
                                               desc:order.productDescription
                                              price:[order.amount floatValue]];
                break;

//            case 1:
//                // pay via wechat
//                [self wxPayWithOrderName:wxOrderName
//                                   price:wxOrderPrice];
//                
//                break;
//            case 2:

            case 1:
                // pay via apple account
                [self applePayForProduct:product];
                break;

            default:
                break;
        }
    }];
    
    [sheet release];
     */
}

//- (void)alipayForOrder:(AlixPayOrder *)order
//{
//    [[AccountService defaultService] setDelegate:self];
//    [[[AccountService defaultService] alipayManager] payWithOrder:order
//                                                        appScheme:[GameApp alipayCallBackScheme]
//                                                    rsaPrivateKey:[PPConfigManager getAlipayRSAPrivateKey]];
//
//
//}

/*
- (void)alipayWebPaymentForOrder:(AlixPayOrder *)order product:(PBIAPProduct*)product
{
    NSString* PRODUCT = @"chargeCoin";
    
    NSString* url = [PPConfigManager getAlipayWebUrl];
    url = [url stringByAddQueryParameter:METHOD value:@"charge"];
    url = [url stringByAddQueryParameter:PARA_APPID value:[GameApp appId]];
    url = [url stringByAddQueryParameter:PARA_GAME_ID value:[GameApp gameId]];
    url = [url stringByAddQueryParameter:PARA_AMOUNT value:order.amount];
    url = [url stringByAddQueryParameter:PARA_DESC value:order.productName];
    url = [url stringByAddQueryParameter:PARA_URL value:product.taobaoUrl];
    url = [url stringByAddQueryParameter:PARA_USERID value:[[UserManager defaultManager] userId]];
    url = [url stringByAddQueryParameter:PARA_TYPE intValue:product.type];
    url = [url stringByAddQueryParameter:PARA_COUNT intValue:product.count];
    
    url = [url stringByAddQueryParameter:PARA_XIAOJI_NUMBER value:[[UserManager defaultManager] xiaojiNumber]];
    url = [url stringByAddQueryParameter:PARA_PRODUCT value:PRODUCT];

    NSString* title = [NSString stringWithFormat:@"充值 - %@", order.productName];
    TaoBaoController* vc = [[TaoBaoController alloc] initWithURL:url title:title];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}
*/

- (void)applePayForProduct:(PBIAPProduct *)product
{
//    if ([MobClick isJailbroken]) {
//
//        __block typeof (self)bself = self;
//
//        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGifTips") message:NSLS(@"kJailBrokenUserIAPTips") style:CommonDialogStyleDoubleButton];
//        [dialog setClickOkBlock:^(UILabel *label){
//                [bself showActivityWithText:NSLS(@"kBuying")];
//                [[AccountService defaultService] buyProduct:product];
//        }];
//
//        [dialog showInView:self.view];
//
//    }else{
        [self showActivityWithText:NSLS(@"kBuying")];
        [[AccountService defaultService] buyProduct:product];
//    }
}


- (void)didFinishBuyProduct:(int)resultCode
{
    [self hideActivity];
    
    if (resultCode != ERROR_SUCCESS && resultCode != PAYMENT_CANCEL){
        POSTMSG(NSLS(@"kFailToConnectIAPServer"));
        
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
        POSTMSG(NSLS(@"kChargIngotSuccess"));
    }else{
        POSTMSG(NSLS(@"kChargIngotFailure"));
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
