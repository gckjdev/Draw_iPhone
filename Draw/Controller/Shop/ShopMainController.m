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

@implementation ShopMainController
@synthesize coinNumberLabel;
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setBuyCoinButton:nil];
    [self setBuyItemButton:nil];
    [self setCoinNumberLabel:nil];
    [self setItemNumberLabel:nil];
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
    [super dealloc];
}
- (IBAction)clickBuyCoinButton:(id)sender {
    CoinShopController *cc = [[CoinShopController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
    [cc release];
}

- (IBAction)clickBuyItemButton:(id)sender {
    ItemShopController *ic = [[ItemShopController alloc] init];
    [self.navigationController pushViewController:ic animated:YES];
    [ic release];
}
@end
