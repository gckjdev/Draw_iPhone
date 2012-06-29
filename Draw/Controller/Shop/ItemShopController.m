//
//  ItemShopController.m
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemShopController.h"
#import "PriceService.h"
#import "AccountManager.h"
#import "ItemManager.h"
#import "Item.h"
#import "ShareImageManager.h"
#import "AccountManager.h"
#import "ItemType.h"
#import "AccountService.h"
#import "CommonDialog.h"
#import "CoinShopController.h"
#import "PPDebug.h"
#import "OnlineGuessDrawController.h"
#import "ShoppingManager.h"
#import "ColorShopView.h"
#import "YoumiWallController.h"
#import "ConfigManager.h"
#import "MobClick.h"
#import "LmWallService.h"

ItemShopController *staticItemController = nil;

@implementation ItemShopController
@synthesize coinsAmountLabel;
@synthesize itemAmountLabel;
@synthesize freeGetCoinsButton;
@synthesize titleLabel;
@synthesize callFromShowViewController;
@synthesize gotoCoinShopButton;
@synthesize removeAdButton;

+(ItemShopController *)instance
{
    if (staticItemController == nil) {
        staticItemController = [[ItemShopController alloc] init];
    }
    return staticItemController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        callFromShowViewController = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)updateLabels
{
    int itemAmount = [[ItemManager defaultManager] tipsItemAmount]; 
    int coinsAmount = [[AccountManager defaultManager] getBalance];
    
    self.coinsAmountLabel.text = [NSString stringWithFormat:@"%@%d", NSLS(@"kCurrentCoins"), coinsAmount];
    self.itemAmountLabel.text = [NSString stringWithFormat:@"%@%d", NSLS(@"kCurrentItems"), itemAmount];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSArray* itemList = [[ShoppingManager defaultManager] findItemPriceList];
    if ([itemList count] == 0){
        [[PriceService defaultService] fetchShoppingListByType:SHOPPING_ITEM_TYPE viewController:self];
    }
    else{
        self.dataList = itemList;
    }
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    UIImageView *tableBg = [[UIImageView alloc] initWithFrame:self.dataTableView.bounds];
    
    [tableBg setImage:[imageManager showcaseBackgroundImage]];
    [self.dataTableView setBackgroundView:tableBg];
    [tableBg release];
    
    [self.titleLabel setText:NSLS(@"kItemShopTitle")];    

    if ([ConfigManager isInReviewVersion] == NO && 
        ([LocaleUtils isChina] == YES || 
        [LocaleUtils isOtherChina] == YES)){
        [self.freeGetCoinsButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage]    
                                           forState:UIControlStateNormal];
        
        self.freeGetCoinsButton.hidden = NO;
    }
    else{
        self.freeGetCoinsButton.hidden = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //load the coin number
    [super viewDidAppear:animated];
        
    self.dataList = [[ShoppingManager defaultManager] findItemPriceList];
    [self updateLabels];
    
    [self.gotoCoinShopButton setTitle:NSLS(@"kGotoCoinShop") forState:UIControlStateNormal];
    [self.gotoCoinShopButton setBackgroundImage:[[ShareImageManager defaultManager] buyButtonImage] forState:UIControlStateNormal];
    
    self.gotoCoinShopButton.hidden = callFromShowViewController;

    [self.removeAdButton setTitle:NSLS(@"kRemoveAd") forState:UIControlStateNormal];
    [self.removeAdButton setBackgroundImage:[[ShareImageManager defaultManager] buyButtonImage] forState:UIControlStateNormal];
    
    
    if ([LocaleUtils isChina] == YES || 
        [LocaleUtils isOtherChina] == YES){
        self.gotoCoinShopButton.hidden = YES;
    }
    else{
        self.gotoCoinShopButton.hidden = NO;
    }
    
    _coinController = nil;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.callFromShowViewController = NO;
    [super viewDidDisappear:animated];
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setCoinsAmountLabel:nil];
    [self setItemAmountLabel:nil];
    [self setFreeGetCoinsButton:nil];
    [self setRemoveAdButton:nil];
    [self setGotoCoinShopButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [ShoppingCell getCellIdentifier];
    ShoppingCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ShoppingCell createCell:self];
        cell.shoppingDelegate = self;
    }
    cell.indexPath = indexPath;
    PriceModel *model = [self.dataList objectAtIndex:indexPath.row];
    [cell setCellInfo:model indexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ShoppingCell getCellHeight];
}


#pragma mark - ShoppingCell delegate
#define DIALOG_NOT_BUY_COIN_TAG 20120406
- (void)didClickBuyButtonAtIndexPath:(NSIndexPath *)indexPath 
                               model:(PriceModel *)model
{
    [MobClick event:@"BUY_ITEM" label:[[model price] description]];
    
    NSInteger price = [[model price] intValue];
    if ([[AccountService defaultService] hasEnoughCoins:price] == NO){
        PPDebug(@"<ItemShopController> click buy item but coins not enough");        
        // rem by Benson for call IAP directly
//        if (callFromShowViewController) {
//            NSString *message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughTips"), price];
//            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCoinsNotEnoughTitle") message:message style:CommonDialogStyleSingleButton delegate:self];
//            dialog.tag = DIALOG_NOT_BUY_COIN_TAG;
//            [dialog showInView:self.view];
//            
//        }else
        {        
            [MobClick event:@"NO_COINS"];
            _dialogAction = DIALOG_ACTION_ASK_BUY_COIN;
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCoinsNotEnoughTitle") message:NSLS(@"kCoinsNotEnough") style:CommonDialogStyleDoubleButton delegate:self];
            dialog.tag = DIALOG_ACTION_ASK_BUY_COIN;
            [dialog showInView:self.view];
        }
        return;
    }
              
    [[AccountService defaultService] buyItem:ITEM_TYPE_TIPS 
                                   itemCount:[[model count] intValue]
                                   itemCoins:[[model price] intValue]];
    [self updateLabels];
}

- (void)buyCoins
{
    [MobClick event:@"BUY_COINS"];
    
    NSArray* coinPriceList = [[ShoppingManager defaultManager] findCoinPriceList];
    if ([coinPriceList count] > 0){
        PriceModel* model = [coinPriceList objectAtIndex:0];
        [self showActivityWithText:NSLS(@"kBuying")];
        [[AccountService defaultService] setDelegate:self];
        [[AccountService defaultService] buyCoin:model];
        
    }    
}

- (void)clickOk:(CommonDialog *)dialog
{
    if (dialog.tag == DIALOG_NOT_BUY_COIN_TAG) {
    }else{
        [self buyCoins];
    }
}

- (void)clickBack:(CommonDialog *)dialog
{    
//    [dialog removeFromSuperview];
}

- (IBAction)clickGotoCoinShopButton:(id)sender
{
    [self.navigationController pushViewController:[CoinShopController instance] animated:YES];
    _coinController = [CoinShopController instance];
}

- (IBAction)clickRemoveAd:(id)sender
{
    if ([ConfigManager wallEnabled]){
        [self showYoumiWall];
    }
    else{
        [self buyCoins];
    }
}

#pragma mark - Price service delegate
- (void)didBeginFetchData
{
    [self showActivityWithText:NSLS(@"kLoading")];
}
- (void)didFinishFetchShoppingList:(NSArray *)shoppingList resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0){
        self.dataList = [[ShoppingManager defaultManager] findItemPriceList];
        [self.dataTableView reloadData];
    }
    else{
        [self popupMessage:NSLS(@"kNetworkFailure") title:nil];
    }
}


#pragma mark - Account Service Delegate

- (void)didFinishBuyProduct:(int)resultCode
{
    [self hideActivity];
    
    if (resultCode != 0 && resultCode != PAYMENT_CANCEL){
        [MobClick event:@"BUY_COINS_OK"];
        
        [self popupMessage:NSLS(@"kFailToConnectIAPServer") title:nil]; 
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else if (resultCode == PAYMENT_CANCEL){
        [MobClick event:@"BUY_COINS_CANCEL"];
        return;
    }
    
    [self updateLabels];
    
    if (resultCode == 0){
        [self popupMessage:NSLS(@"kBuyCoinsSucc") title:nil];
    }
}

- (void)didProcessingBuyProduct
{
    [self hideActivity];
    [self showActivityWithText:NSLS(@"kProcessingIAP")];
}


- (UINavigationController *)topNavigationController
{
    if (_coinController) {
        return _coinController.navigationController;
    }
    return self.navigationController;
}

- (void)showLmWall
{
}

- (void)showYoumiWall
{
    [UIUtils alert:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励哦！"];
    
    [[LmWallService defaultService] show:self];

    /*
    [MobClick event:@"SHOW_YOUMI_WALL"];
    YoumiWallController* controller = [[YoumiWallController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    */
}

- (void)dealloc {
    PPRelease(titleLabel);
    PPRelease(coinsAmountLabel);
    PPRelease(itemAmountLabel);
    [freeGetCoinsButton release];
    [super dealloc];
}
@end
