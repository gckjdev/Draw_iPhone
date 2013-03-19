//
//  CoinShopController.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CoinShopController.h"
#import <StoreKit/StoreKit.h>
#import "DrawGameService.h"
#import "AccountService.h"
#import "ShareImageManager.h"
#import "AccountManager.h"
#import "ShoppingManager.h"
#import "PPDebug.h"

CoinShopController *staticCoinController;

@implementation CoinShopController
@synthesize titleLabel;
@synthesize coinNumberLabel;

+(CoinShopController *)instance
{
    if (staticCoinController == nil) {
        staticCoinController = [[CoinShopController alloc] init];
    }
    return staticCoinController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([SKPaymentQueue canMakePayments]) {
        // Display a store to the user.
    } else {
        [UIUtils alert:NSLS(@"kPaymentCannotMake")];
    }
    
    

    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    UIImageView *tableBg = [[UIImageView alloc] initWithFrame:self.dataTableView.bounds];
    
    [tableBg setImage:[imageManager showcaseBackgroundImage]];
    [self.dataTableView setBackgroundView:tableBg];
    [tableBg release];
    
    [self.titleLabel setText:NSLS(@"kCoinShopTitle")];


    // why here??? Benson
//    [[PriceService defaultService] fetchAccountBalanceWithUserId:userId viewController:self];
}


- (void)viewDidAppear:(BOOL)animated
{
    PPDebug(@"<CoinShop> viewDidAppear");
    self.dataList = [[ShoppingManager defaultManager] findCoinPriceList];
    if ([self.dataList count] == 0){
        [[PriceService defaultService] fetchCoinProductList:self];        
    }
    [self.dataTableView reloadData];
    
    [self updateCoinNumberLabel];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setCoinNumberLabel:nil];
    [self setTitleLabel:nil];
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
- (void)didClickBuyButtonAtIndexPath:(NSIndexPath *)indexPath 
                               model:(PriceModel *)model
{
    PPDebug(@"<CoinShopController>:did click row %d",indexPath.row);
    
    
    [self showActivityWithText:NSLS(@"kBuying")];
    [[AccountService defaultService] setDelegate:self];
    [[AccountService defaultService] buyCoin:model];
}

- (void)updateCoinNumberLabel
{
    self.coinNumberLabel.text = [NSString stringWithFormat:@"%d", [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin]];
}

#pragma mark - Price service delegate
- (void)didBeginFetchData
{
    [self showActivityWithText:NSLS(@"kLoading")];
}

- (void)didFinishBuyProduct:(int)resultCode
{
    [self hideActivity];
    
    if (resultCode != 0 && resultCode != PAYMENT_CANCEL){
        [self popupMessage:NSLS(@"kFailToConnectIAPServer") title:nil]; 
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else if (resultCode == PAYMENT_CANCEL){
        return;
    }
    
    // update product count number label
    [self updateCoinNumberLabel];
    
    if (resultCode == 0){
        [self popupMessage:NSLS(@"kBuyCoinsSucc") title:nil];
    }
}

- (void)didProcessingBuyProduct
{
    [self hideActivity];
    [self showActivityWithText:NSLS(@"kProcessingIAP")];
}

- (void)didFinishFetchShoppingList:(NSArray *)shoppingList resultCode:(int)resultCode
{
    [self hideActivity];
    self.dataList = shoppingList;
    [self.dataTableView reloadData];
}

- (void)didFinishFetchAccountBalance:(NSInteger)balance resultCode:(int)resultCode
{
    [self hideActivity];
    PPDebug(@"did get balance: %d",balance);
}

- (void)dealloc {
    PPRelease(coinNumberLabel);
    PPRelease(titleLabel);
    [super dealloc];
}


@end
