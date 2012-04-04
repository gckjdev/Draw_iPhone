//
//  ColorShopController.m
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorShopController.h"
#import "ShareImageManager.h"
//#import "ColorShopCell.h"
#import "DrawViewController.h"
#import "ColorGroup.h"
#import "ColorView.h"

ColorShopController *staticColorShopController;

@implementation ColorShopController
@synthesize coinNumberLabel;
@synthesize titleLabel;
@synthesize colorShopControllerDelegate;
@synthesize callFromDrawView;
+(ColorShopController *)instance
{
    if (staticColorShopController == nil) {
        staticColorShopController = [[ColorShopController alloc] init];
    }
    staticColorShopController.colorShopControllerDelegate = nil;
    return staticColorShopController;
}

+(ColorShopController *)instanceWithDelegate:(id<ColorShopControllerDelegate>)delegate
{
    ColorShopController *cs = [ColorShopController instance];
    cs.colorShopControllerDelegate = delegate;
    return cs;
}

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

    NSMutableArray *colorList = [[[NSMutableArray alloc] init] autorelease];
    for (int i = 0; i < 10; i ++) {
        NSArray *array = [NSArray arrayWithObjects:[ColorView redColorView],[ColorView blueColorView],[ColorView blackColorView],[ColorView yellowColorView],[ColorView redColorView], nil];
        ColorGroup *group = [[ColorGroup alloc] initWithGroupId:i colorViewList:array];
        [colorList addObject:group];
        [group release];
    }
    self.dataList = colorList;
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    UIImageView *tableBg = [[UIImageView alloc] initWithFrame:self.dataTableView.bounds];
    
    [tableBg setImage:[imageManager showcaseBackgroundImage]];
    [self.dataTableView setBackgroundView:tableBg];
    [tableBg release];
    
    [self.titleLabel setText:NSLS(@"kBuyColor")];
}
- (void)viewDidUnload
{
    [self setCoinNumberLabel:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [coinNumberLabel release];
    [titleLabel release];
    [super dealloc];
}
- (IBAction)clickBackButton:(id)sender {
    if (callFromDrawView) {
        [DrawViewController returnFromController:self];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    callFromDrawView = NO;
}

#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [ColorShopCell getCellIdentifier];
    ColorShopCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ColorShopCell createCell:self];
    }
    cell.indexPath = indexPath;
    ColorGroup *group = [self.dataList objectAtIndex:indexPath.row];
    group.price = 100;
    [cell setCellInfo:group hasBought:rand()%2];
    cell.colorShopCellDelegate = self;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ColorShopCell getCellHeight];
}

#pragma mark - ColorShopCell delegate
- (void)didPickedColorView:(ColorView *)colorView
{
    NSLog(@"<ColorShopController>:didPickColor");
    if (callFromDrawView) {
        [DrawViewController returnFromController:self];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    callFromDrawView = NO;
    
    if (self.colorShopControllerDelegate && [self.colorShopControllerDelegate respondsToSelector:@selector(didPickedColorView:)]) {
        [self.colorShopControllerDelegate didPickedColorView:colorView];
    }
}

//#pragma mark - ColorShopCell delegate


//#pragma mark - Price service delegate
//- (void)didBeginFetchData
//{
//    [self showActivityWithText:@"Loading..."];
//}
//- (void)didFinishFetchShoppingList:(NSArray *)shoppingList resultCode:(int)resultCode
//{
//    [self hideActivity];
//    self.dataList = shoppingList;
//    [self.dataTableView reloadData];
//}
//
//- (void)didFinishFetchAccountBalance:(NSInteger)balance resultCode:(int)resultCode
//{
//    [self hideActivity];
//    NSLog(@"did get balance: %d",balance);
//}

@end
    