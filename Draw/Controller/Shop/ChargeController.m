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
#import "MobClickUtils.h"
#import "PPConfigManager.h"
#import "ShareImageManager.h"
#import "UIViewUtils.h"
#import "MKBlockActionSheet.h"
#import "StringUtil.h"
#import "NotificationCenterManager.h"
#import "NotificationName.h"
#import "StringUtil.h"
#import "IAPProductManager.h"
#import "PPNetworkConstants.h"
#import "CommonDialog.h"
#import "PBIAPProduct+Utils.h"
#import "SKProductService.h"

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

- (id)init
{
    if (self = [super init]) {
        _saleCurrency = [GameApp saleCurrency];
        __block typeof (self)bself = self;
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
    self.countLabel.text = [NSString stringWithFormat:@"%ld", [[AccountManager defaultManager] getBalanceWithCurrency:_saleCurrency]];
}

- (void)updateTaobaoLinkView
{
    self.taobaoLinkView.hidden = YES;
}

- (IBAction)clickBackButton:(id)sender {
    [[AccountService defaultService] setDelegate:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

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
    PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
    [self applePayForProduct:product];
}

- (void)showBuyActionSheetWithIndex:(NSIndexPath *)indexPath
{
    PBIAPProduct *product = [dataList objectAtIndex:indexPath.row];
    [self applePayForProduct:product];
}

- (void)applePayForProduct:(PBIAPProduct *)product
{
    [self showActivityWithText:NSLS(@"kBuying")];
    [[AccountService defaultService] buyProduct:product];
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
