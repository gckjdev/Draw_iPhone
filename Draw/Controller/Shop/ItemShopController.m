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

ItemShopController *staticItemController = nil;

@implementation ItemShopController
@synthesize coinsAmountLabel;
@synthesize itemAmountLabel;
@synthesize titleLabel;

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
    [[PriceService defaultService] fetchShoppingListByType:SHOPPING_ITEM_TYPE viewController:self];
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
    [self updateLabels];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
//    return 2;
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
    ShoppingModel *model = [self.dataList objectAtIndex:indexPath.row];
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
                               model:(ShoppingModel *)model
{
    
    if ([[AccountService defaultService] hasEnoughCoins:[model price]] == NO){
        PPDebug(@"<ItemShopController> click buy item but coins not enough");
        _dialogAction = DIALOG_ACTION_ASK_BUY_COIN;
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCoinsNotEnoughTitle") message:NSLS(@"kCoinsNotEnough") style:CommonDialogStyleDoubleButton deelegate:self];
        [dialog showInView:self.view];
        return;
    }
              
    [[AccountService defaultService] buyItem:ITEM_TYPE_TIPS itemCount:[model count] itemCoins:[model price]];
    [self updateLabels];
}

- (void)clickOk:(CommonDialog *)dialog
{
    [self.navigationController pushViewController:[CoinShopController instance] animated:YES];
}

- (void)clickBack:(CommonDialog *)dialog
{    
}

#pragma mark - Price service delegate
- (void)didBeginFetchData
{
    [self showActivityWithText:@"Loading..."];
}
- (void)didFinishFetchShoppingList:(NSArray *)shoppingList resultCode:(int)resultCode
{
    [self hideActivity];
    self.dataList = shoppingList;
    [self.dataTableView reloadData];
}


- (void)dealloc {
    [titleLabel release];
    [coinsAmountLabel release];
    [itemAmountLabel release];
    [super dealloc];
}
@end
