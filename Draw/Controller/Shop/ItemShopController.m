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
#import "ShowDrawController.h"
#import "ShoppingManager.h"
#import "ColorShopView.h"

ItemShopController *staticItemController = nil;

@implementation ItemShopController
@synthesize coinsAmountLabel;
@synthesize itemAmountLabel;
@synthesize titleLabel;
@synthesize callFromShowViewController;
@synthesize gotoCoinShopButton;

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
    
    self.coinsAmountLabel.text = [NSString stringWithFormat:@"%d", coinsAmount];
    self.itemAmountLabel.text = [NSString stringWithFormat:@"%d", itemAmount];
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
    NSInteger price = [[model price] intValue];
    if ([[AccountService defaultService] hasEnoughCoins:price] == NO){
        PPDebug(@"<ItemShopController> click buy item but coins not enough");        
        if (callFromShowViewController) {
            NSString *message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughTips"), price];
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCoinsNotEnoughTitle") message:message style:CommonDialogStyleSingleButton delegate:self];
            dialog.tag = DIALOG_NOT_BUY_COIN_TAG;
            [dialog showInView:self.view];
            
        }else{        
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

- (void)clickOk:(CommonDialog *)dialog
{
    if (dialog.tag == DIALOG_NOT_BUY_COIN_TAG) {
//        [dialog removeFromSuperview];
    }else{
        [self.navigationController pushViewController:[CoinShopController instance] animated:YES];
        _coinController = [CoinShopController instance];
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


- (UINavigationController *)topNavigationController
{
    if (_coinController) {
        return _coinController.navigationController;
    }
    return self.navigationController;
}

- (void)dealloc {
    PPRelease(titleLabel);
    PPRelease(coinsAmountLabel);
    PPRelease(itemAmountLabel);
    [super dealloc];
}
@end
