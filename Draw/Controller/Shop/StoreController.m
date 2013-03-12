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
#import "AccountService.h"
#import "UserManager.h"
#import "AdService.h"

typedef enum{
    TabIDNormal = 100,
    TabIDTool = 101,
    TabIDPromotion = 102,
}TabID;

@interface StoreController ()

@property (retain, nonatomic) UIButton *selectedButton;
@property (retain, nonatomic) PBGameItem *selectedItem;
@property (assign, nonatomic) int selectedCount;

@end

@implementation StoreController

- (void)dealloc {
    [_selectedButton release];
//    [_tipsLabel release];
    [_backButton release];
    [_chargeButton release];
    [_selectedItem release];
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
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    [[GameItemService sharedGameItemService] updateItemListWithType:PBDrawItemTypeNomal handler:^(BOOL success, NSArray *itemsList) {
        if (success) {
            [bself reloadTableViewDataSource];
        }else{
            
        }
    }];
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
    
    [self  updateItemData];
}

- (void)updateBalance
{
    self.coinBalanceLabel.text = [NSString stringWithFormat:@"%d", [[AccountService defaultService] getBalanceWithCurrency:PBGameCurrencyCoin]];
    
    self.ingotBalanceLabel.text = [NSString stringWithFormat:@"%d", [[AccountService defaultService] getBalanceWithCurrency:PBGameCurrencyIngot]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPDebug(@"select row: %d", indexPath.row);
    PBGameItem *item = [self.tabDataList objectAtIndex:indexPath.row];
    
    
    if (item.itemId == ItemTypeColor) {
        ColorShopView *colorShop = [ColorShopView colorShopViewWithFrame:self.view.bounds];
        colorShop.delegate = self;
        [colorShop showInView:self.view animated:YES];
        return;
    }
    
    BuyItemView *buyItemView = [BuyItemView createWithItem:item];
    
    CustomInfoView *cusInfoView;
    
    if (item.salesType == PBGameItemSalesTypeOneOff && [[UserGameItemService defaultService] countOfItem:item.itemId] >=1) {
        cusInfoView = [CustomInfoView createWithTitle:NSLS(item.name)
                                             infoView:buyItemView
                                       hasCloseButton:YES
                                         buttonTitles:NSLS(@"kGive"), nil];
    }else{
        cusInfoView = [CustomInfoView createWithTitle:NSLS(item.name)
                                             infoView:buyItemView
                                       hasCloseButton:YES
                                         buttonTitles:NSLS(@"kBuy"), NSLS(@"kGive"), nil];
    }
    


    [cusInfoView showInView:self.view];

    __block typeof (self) bself = self;
    [cusInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        int count = ((BuyItemView *)infoView).count;
        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kBuy")]) {
            PPDebug(@"you buy %d %@", count, NSLS(item.name));
            [button setTitle:NSLS(@"kBuying...") forState:UIControlStateNormal];
            [cusInfoView showActivity];
            [[UserGameItemService defaultService] buyItem:item count:count handler:^(UserGameItemServiceResultCode resultCode, int itemId, int count, NSString *toUserId) {
                if (resultCode == UIS_SUCCESS) {
                    [cusInfoView dismiss];
                    if (item.itemId == ItemTypeRemoveAd) {
                        [[AdService defaultService] disableAd];
                    }
                }else{
                    [cusInfoView hideActivity];
                    [button setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
                }
                
                [self showUserGameItemServiceResult:resultCode
                                               item:item
                                              count:count
                                           toUserId:toUserId];
            }];
        }else{
            PPDebug(@"you give %d %@", count, NSLS(item.name));
            
            bself.selectedCount = count;
            bself.selectedItem = item;
            
            FriendController *vc = [[[FriendController alloc] initWithDelegate:bself] autorelease];
            [bself.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)showUserGameItemServiceResult:(UserGameItemServiceResultCode)resultCode
                                 item:(PBGameItem *)item
                                count:(int)count
                             toUserId:(NSString *)toUserId
{
    switch (resultCode) {
        case UIS_SUCCESS:
            if ([toUserId isEqualToString:[[UserManager defaultManager] userId]]) {
                [self popupHappyMessage:NSLS(@"kYouBuy") title:nil];
                [self.dataTableView reloadData];
            }else{
                [self popupHappyMessage:@"kYouGive" title:nil];
            }
            [self updateBalance];
            break;
            
        case UIS_ERROR_NETWORK:
            if ([toUserId isEqualToString:[[UserManager defaultManager] userId]]) {
                [self popupHappyMessage:NSLS(@"kBuyItemFail") title:nil];
                [self.dataTableView reloadData];
            }else{
                [self popupHappyMessage:@"kGiveItemFail" title:nil];
            }
            break;
            
        case UIS_BALANCE_NOT_ENOUGH:
            [self popupHappyMessage:NSLS(@"kBalanceNotEnough") title:nil];
            break;
            
            case UIS_BAD_PARAMETER:
            [self popupHappyMessage:NSLS(@"kBadParaMeter") title:nil];
            break;
            
        default:
            break;
    }
}

- (void)friendController:(FriendController *)controller
         didSelectFriend:(MyFriend *)aFriend
{
    [controller.navigationController popViewControllerAnimated:YES];
    GiftDetailView *giftDetailView = [GiftDetailView createWithItem:_selectedItem myFriend:aFriend count:_selectedCount];
    
    CustomInfoView *cusInfoView = [CustomInfoView createWithTitle:NSLS(@"kGive")
                                                         infoView:giftDetailView
                                                   hasCloseButton:YES
                                                     buttonTitles:NSLS(@"kCancel"), NSLS(@"kOK"), nil];
    
    
    
    [cusInfoView showInView:self.view];
    
    __block typeof (self) bself = self;
    [cusInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        [cusInfoView dismiss];
        if (button.tag == 1) {
            [[UserGameItemService defaultService] giveItem:_selectedItem toUser:[aFriend friendUserId] count:_selectedCount handler:^(UserGameItemServiceResultCode resultCode, int itemId, int count, NSString *toUserId) {
                if (resultCode == UIS_SUCCESS) {
                    [cusInfoView dismiss];
                }
                [bself showUserGameItemServiceResult:resultCode
                                               item:nil
                                              count:count
                                           toUserId:toUserId];
            }];
        }
    }];
}





- (NSInteger)tabCount //default 1
{
    return 3;
}
- (NSInteger)currentTabIndex
{
    return 0;
}


- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabIDs[] = {TabIDNormal, TabIDTool, TabIDPromotion};
    return tabIDs[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitles[] = {NSLS(@"kItemNormal"), NSLS(@"kItemTool"), NSLS(@"kItemPromotion")};
    return tabTitles[index];

}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    GameItemService *service = [GameItemService sharedGameItemService];
    GetItemsListResultHandler handler = ^(BOOL success, NSArray *itemsList) {
        if (success) {
            [bself finishLoadDataForTabID:tabID resultList:itemsList];
        }else{
            [bself failLoadDataForTabID:tabID];
        }
    };

    
    switch (tabID) {
        case TabIDNormal:
            [service getItemsListWithType:PBDrawItemTypeNomal resultHandler:handler];
            break;
        case TabIDTool:
            [service getItemsListWithType:PBDrawItemTypeTool resultHandler:handler];
            break;
            
        case TabIDPromotion:
            [service getPromotingItemsList:handler];
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

@end


