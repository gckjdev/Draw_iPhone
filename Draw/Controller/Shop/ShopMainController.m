//
//  ShopMainController.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShopMainController.h"
#import "CoinShopController.h"
#import "ItemShopController.h"
#import <StoreKit/StoreKit.h>
#import "ShareImageManager.h"
#import "LocaleUtils.h"

@implementation ShopMainController
@synthesize coinNumberLabel;
@synthesize titleLabel;
@synthesize showcaseBg;
@synthesize backButton;
@synthesize itemNumberLabel;
@synthesize buyCoinButton;
@synthesize buyItemButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.showcaseBg setImage:[imageManager showcaseBackgroundImage]];
    [self.buyCoinButton setBackgroundImage:[imageManager buyButtonImage] forState:UIControlStateNormal];
    [self.buyItemButton setBackgroundImage:[imageManager buyButtonImage] forState:UIControlStateNormal];
    [self.buyCoinButton setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
    [self.buyItemButton setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];    
    [self.titleLabel setText:NSLS(@"kShopMainTitle")];

}

- (void)viewDidUnload
{
    [self setBuyCoinButton:nil];
    [self setBuyItemButton:nil];
    [self setCoinNumberLabel:nil];
    [self setItemNumberLabel:nil];
    [self setShowcaseBg:nil];
    [self setTitleLabel:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [buyCoinButton release];
    [buyItemButton release];
    [coinNumberLabel release];
    [itemNumberLabel release];
    [showcaseBg release];
    [titleLabel release];
    [backButton release];
    [super dealloc];
}
- (IBAction)clickBuyCoinButton:(id)sender {
    CoinShopController *cc = [CoinShopController instance];
    [self.navigationController pushViewController:cc animated:YES];
}

- (IBAction)clickBuyItemButton:(id)sender {
    ItemShopController *ic = [ItemShopController instance];
    [self.navigationController pushViewController:ic animated:YES];
}
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
