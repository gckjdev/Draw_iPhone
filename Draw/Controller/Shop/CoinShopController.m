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

@implementation CoinShopController

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
    
    
    [[PriceService defaultService] fetchCoinProductList:self];
    NSString *userId = [[DrawGameService defaultService] userId];
    NSLog(@"userID = %@",userId);
    [[PriceService defaultService] fetchAccountBalanceWithUserId:userId viewController:self];
}

- (void)viewDidUnload
{
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

#pragma mark - ShoppingCell delegate
- (void)didClickBuyButtonAtIndexPath:(NSIndexPath *)indexPath 
                               model:(ShoppingModel *)model
{
    NSLog(@"<CoinShopController>:did click row %d",indexPath.row);
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

- (void)didFinishFetchAccountBalance:(NSInteger)balance resultCode:(int)resultCode
{
    [self hideActivity];
    NSLog(@"did get balance: %d",balance);
}

@end
