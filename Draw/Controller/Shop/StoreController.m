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
    [super dealloc];
}

- (void)viewDidUnload {
    [self setSelectedButton:nil];
    [self setTitleLabel:nil];
    [self setBackButton:nil];
    [self setChargeButton:nil];
    [self setCoinBalanceLabel:nil];
    [self setIngotBalanceLabel:nil];
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

- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeNone];

    [super viewDidLoad];
    [self initTabButtons];
    
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLS(@"kStore");
    [self.chargeButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];
    [self updateBalance];
    [self updateItemData];

    [GameItemService createTestDataFile];
}

- (void)updateBalance
{
    self.coinBalanceLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin]];
    
    self.ingotBalanceLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyIngot]];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickChargeButton:(id)sender {
    ChargeController *controller = [[ChargeController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
//    //TODO
//    return count;
//}

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
        if ([item hasUrl]) {
            TaoBaoController *vc = [[[TaoBaoController alloc] initWithURL:[item url] title:NSLS(@"kTaoBaoProductDetail")] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            __block typeof (self) bself = self;
            
            [BuyItemView showBuyItemView:item.itemId inView:self.view resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
                [bself updateBalance];
                [bself.dataTableView reloadData];
            }];
        }
    }
}

- (NSInteger)tabCount //default 1
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
            [self finishLoadDataForTabID:tabID resultList:[[GameItemManager defaultManager] itemsListWithType:PBDrawItemTypeNomal]];
            break;
        case TabIDTool:
            [self finishLoadDataForTabID:tabID resultList:[[GameItemManager defaultManager] itemsListWithType:PBDrawItemTypeTool]];
            break;
            
        case TabIDPromotion:
            [self finishLoadDataForTabID:tabID resultList:[[GameItemManager defaultManager] promotingItemsList]];
             break;
            
        case TabIDTaoBao:
            [self finishLoadDataForTabID:tabID resultList:[self taoBaoItemList]];
            break;
            
        default:
            break;
    }
}

- (NSArray *)taoBaoItemList{
    NSArray *arr = [NSArray arrayWithObjects:[self dianRongBi], nil];
    return arr;
}

- (PBGameItem *)dianRongBi{
    PBGameItem_Builder *builder = [[[PBGameItem_Builder alloc] init] autorelease];
    [builder setItemId:ItemTypeTaoBao];
    [builder setName:[ConfigManager getDianRongBiName]];
    [builder setDesc:[ConfigManager getDianRongBiDesc]];
    [builder setImage:[ConfigManager getDianRongBiImageURL]];
    [builder setUrl:[ConfigManager getDianRongBiTaoBaoURL]];
    return [builder build];
}

#pragma mark -
#pragma ColorShopViewDelegate method
- (void)didBuyColorList:(NSArray *)colorList groupId:(NSInteger)groupId
{
    [self updateBalance];
}

@end


