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
#import "BuyItemView.h"
#import "CustomInfoView.h"
#import "ChargeController.h"
#import "GiftDetailView.h"
#import "UserGameItemService.h"
#import "ItemType.h"
#import "AccountManager.h"
#import "UserManager.h"
#import "AdService.h"
#import "GameNetworkConstants.h"
#import "CommonMessageCenter.h"
#import "GameItemManager.h"
#import "BalanceNotEnoughAlertView.h"
#import "ConfigManager.h"
#import "TaoBaoController.h"
#import "UIViewUtils.h"


typedef enum{
    TabIDNormal = 100,
    TabIDTool = 101,
    TabIDPromotion = 102,
    TabIDTaoBao = 103
}TabID;

@interface StoreController ()
{
    BOOL _isLoadingAccountDataFinish;
    BOOL _isLoadingItemDataFinish;
}

@property (retain, nonatomic) UIButton *selectedButton;

@end

@implementation StoreController

- (void)dealloc {
    [_selectedButton release];
    [_backButton release];
    [_chargeButton release];
    [_coinBalanceLabel release];
    [_ingotBalanceLabel release];
    [_ingotImageView release];
    [_ingotBalanceBgImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setSelectedButton:nil];
    [self setTitleLabel:nil];
    [self setBackButton:nil];
    [self setChargeButton:nil];
    [self setCoinBalanceLabel:nil];
    [self setIngotBalanceLabel:nil];
    [self setIngotImageView:nil];
    [self setIngotBalanceBgImageView:nil];
    [super viewDidUnload];
}

- (void)updateItemData
{
    [self showActivityWithText:NSLS(@"kLoading")];
    
    __block typeof(self) bself = self;
    
    _isLoadingAccountDataFinish = NO;
    _isLoadingItemDataFinish = NO;
    
    [[GameItemService defaultService] syncData:^(BOOL success) {
        _isLoadingItemDataFinish = YES;
        
        if (_isLoadingItemDataFinish && _isLoadingAccountDataFinish){
            [self hideActivity];
        }
        
        [bself reloadTableViewDataSource];
    }];
    
    [[AccountService defaultService] syncAccountWithResultHandler:^(int resultCode) {
        _isLoadingAccountDataFinish = YES;

        if (_isLoadingItemDataFinish && _isLoadingAccountDataFinish){
            [self hideActivity];
        }
        
        [bself reloadTableViewDataSource];
        [bself updateBalance];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateBalance];
}

#define ADDTION_HEIGHT_WHEN_NO_TAB_BUTTON (ISIPAD ? 80 : 40)
- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeNone];

    self.ingotImageView.hidden = ![GameApp hasIngotBalance];
    self.ingotBalanceLabel.hidden = ![GameApp hasIngotBalance];
    self.ingotBalanceBgImageView.hidden = ![GameApp hasIngotBalance];

    [super viewDidLoad];
    [self initTabButtons];
    
    if (isDiceApp()) {
        for (TableTab *tab in [_tabManager tabList]) {
            [[self tabButtonWithTabID:tab.tabID] setHidden:YES];;
        }
        [self.dataTableView updateHeight:(self.dataTableView.frame.size.height + ADDTION_HEIGHT_WHEN_NO_TAB_BUTTON)];
        [self.dataTableView updateCenterY:(self.dataTableView.center.y - ADDTION_HEIGHT_WHEN_NO_TAB_BUTTON)];
    }
    
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLS(@"kStore");
    [self.chargeButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];
    [self updateBalance];
    [self updateItemData];

#ifdef DEBUG
    [GameItemService createTestDataFile];
#endif
}

- (void)updateBalance
{
    self.coinBalanceLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin]];
    
    self.ingotBalanceLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyIngot]];
}

- (IBAction)clickBackButton:(id)sender {
    [[AccountService defaultService] setDelegate:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickChargeButton:(id)sender {
    ChargeController *controller = [[ChargeController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
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
    
    [cell setCellInfo:[self.tabDataList objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)showColorShopView{
    ColorShopView *colorShop = [ColorShopView colorShopViewWithFrame:self.view.bounds];
    colorShop.delegate = self;
    [colorShop showInView:self.view animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPDebug(@"select row: %d", indexPath.row);
    PBGameItem *item = [self.tabDataList objectAtIndex:indexPath.row];

    if (item.itemId == ItemTypeColor) {
        [self showColorShopView];
    }else{
        if (item.type == PBDrawItemTypeDrawTaoBao) {
            TaoBaoController *vc = [[[TaoBaoController alloc] initWithURL:[item url] title:NSLS(@"kTaoBaoProductDetail")] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
            __block typeof (self) bself = self;
            [[AccountService defaultService] setDelegate:bself];
            
            [BuyItemView showBuyItemView:item.itemId inView:self.view resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
                [bself updateBalance];
                [bself.dataTableView reloadData];
            }];
        }
    }
}

- (NSInteger)tabCount
{
    return 4;
}
- (NSInteger)currentTabIndex
{
    return 0;
}


- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabIDs[] = {TabIDNormal, TabIDTool, TabIDPromotion, TabIDTaoBao};
    return tabIDs[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitles[] = {NSLS(@"kItemNormal"), NSLS(@"kItemTool"), NSLS(@"kItemPromotion"), NSLS(@"kItemTaoBao")};
    return tabTitles[index];

}
- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    TabID tabID = [self tabIDforIndex:index];
    switch (tabID) {
        case TabIDNormal:
            return NSLS(@"kNoSaleItemNormal");
            break;
        case TabIDTool:
            return NSLS(@"kNoSaleItemTool");
            break;
            
        case TabIDPromotion:
            return NSLS(@"kNoSaleItemPromoting");
            break;
            
        case TabIDTaoBao:
            return NSLS(@"kNoSaleItemTaoBao");
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{    
    switch (tabID) {
        case TabIDNormal:
            [self finishLoadDataForTabID:tabID resultList:[[GameItemManager defaultManager] itemsListWithType:PBDrawItemTypeDrawNomal]];
            break;
        case TabIDTool:
            [self finishLoadDataForTabID:tabID resultList:[[GameItemManager defaultManager] itemsListWithType:PBDrawItemTypeDrawTool]];
            break;
            
        case TabIDPromotion:
            [self finishLoadDataForTabID:tabID resultList:[[GameItemManager defaultManager] promotingItemsList]];
             break;
            
        case TabIDTaoBao:
            [self finishLoadDataForTabID:tabID resultList:[[GameItemManager defaultManager] itemsListWithType:PBDrawItemTypeDrawTaoBao]];
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma ColorShopViewDelegate method
- (void)didBuyColorList:(NSArray *)colorList groupId:(NSInteger)groupId
{
    [self updateBalance];
}

- (void)didFinishChargeCurrency:(PBGameCurrency)currency resultCode:(int)resultCode
{
    [self updateBalance];
}

@end


