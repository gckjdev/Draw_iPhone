//
//  VendingController.m
//  Draw
//
//  Created by Orange on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VendingController.h"
#import "ShareImageManager.h"
#import "Item.h"
#import "AccountManager.h"
#import "ItemType.h"

#define ITEM_COUNT_PER_LINE 3
#define LINE_PER_PAGE       3

#define PRICE_TAG_OFFSET 20120710
#define ITEM_BUTTON_OFFSET  120120710
#define PAGE_TAG_OFFSET      220120710

#define FIRST_SHELF_FRAME   CGRectMake(5, 69, 297, 54)
#define SHELF_SEPERATOR     102
#define FIRST_ITEM_FRAME    CGRectMake(22, 20, 67, 67)
#define FIRST_PRICE_COIN_FRAME  CGRectMake(23, 89, 17, 17)
#define FIRST_PRICE_LABEL_FRAME CGRectMake(45, 89, 45, 17)
#define ITEM_SEPERATOR  98

@interface VendingController () <ColorShopViewDelegate>

@end

@implementation VendingController
@synthesize itemListScrollView;
@synthesize coinsButton;
@synthesize buyCoinButton;

- (void)dealloc {
    [itemListScrollView release];
    [coinsButton release];
    [buyCoinButton release];
    [_itemList release];
    [super dealloc];
}

- (void)initButtons
{
    [self.buyCoinButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.buyCoinButton setTitle:NSLS(@"kCoinShopTitle") forState:UIControlStateNormal];
}

- (void)initTitles
{
    [self.coinsButton setTitle:[NSString stringWithFormat:@"X%d",[AccountManager defaultManager].getBalance] forState:UIControlStateNormal];
}

- (void)addPageViewBackground:(UIView*)view
{
    //add background
    UIImageView* bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shopping_bg.png"]];
    [bg setFrame:CGRectMake(0, 
                            0, 
                            self.itemListScrollView.frame.size.width, 
                            self.itemListScrollView.frame.size.height)];
    [view addSubview:bg];
    
    //add shelf
    for (int i = 0; i < LINE_PER_PAGE; i ++) {
        UIImageView* shelf = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop_shelf.png"]];
        CGRect rect = FIRST_SHELF_FRAME;
        [shelf setFrame:CGRectMake(rect.origin.x, 
                                   rect.origin.y + i*SHELF_SEPERATOR, 
                                   rect.size.width, 
                                   rect.size.height)];
        [view addSubview:shelf];
    }
}

- (void)addItem:(Item*)item 
     toPageView:(UIView*)view 
      withIndex:(int)index
{
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(FIRST_ITEM_FRAME.origin.x + ITEM_SEPERATOR*(index%ITEM_COUNT_PER_LINE), 
                                                                  FIRST_ITEM_FRAME.origin.y + SHELF_SEPERATOR*(index/ITEM_COUNT_PER_LINE), 
                                                                  FIRST_ITEM_FRAME.size.width, 
                                                                  FIRST_ITEM_FRAME.size.height)];
    UIImageView* coin = [[UIImageView alloc] initWithFrame:CGRectMake(FIRST_PRICE_COIN_FRAME.origin.x + ITEM_SEPERATOR*(index%ITEM_COUNT_PER_LINE), 
                                                                  FIRST_PRICE_COIN_FRAME.origin.y + SHELF_SEPERATOR*(index/ITEM_COUNT_PER_LINE), 
                                                                  FIRST_PRICE_COIN_FRAME.size.width, 
                                                                  FIRST_PRICE_COIN_FRAME.size.height)];
    UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(FIRST_PRICE_LABEL_FRAME.origin.x + ITEM_SEPERATOR*(index%ITEM_COUNT_PER_LINE), 
                                                                  FIRST_PRICE_LABEL_FRAME.origin.y + SHELF_SEPERATOR*(index/ITEM_COUNT_PER_LINE), 
                                                                  FIRST_PRICE_LABEL_FRAME.size.width, 
                                                                  FIRST_PRICE_LABEL_FRAME.size.height)];
    
    [coin setImage:[UIImage imageNamed:@"small_coin.png"]];
    
    [priceLabel setText:[NSString stringWithFormat:@"%d",item.price]];
    [priceLabel setBackgroundColor:[UIColor clearColor]];
    
    [button setImage:item.itemImage forState:UIControlStateNormal];
    int pageIndex = view.tag-PAGE_TAG_OFFSET;
    button.tag = pageIndex*LINE_PER_PAGE*ITEM_COUNT_PER_LINE+index+ITEM_BUTTON_OFFSET;
    [button addTarget:self action:@selector(clickItemButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    [view addSubview:coin];
    [view addSubview:priceLabel];
    
}

- (void)addItemsToPageView:(UIView*)view 
            withPageIndex:(int)pageIndex
{
    for (int i = 0; i < LINE_PER_PAGE*ITEM_COUNT_PER_LINE; i ++) {
        int itemIndex = pageIndex*LINE_PER_PAGE*ITEM_COUNT_PER_LINE+i;
        if (itemIndex >= _itemList.count) {
            return;
        }
        Item* item = [_itemList objectAtIndex:itemIndex];
        view.tag = pageIndex+PAGE_TAG_OFFSET;
        [self addItem:item 
           toPageView:view 
            withIndex:i];
    }
}

- (UIView*)viewWithPageIndex:(int)pageIndex
{
    UIView* view = [[[UIView alloc] initWithFrame:CGRectMake(self.itemListScrollView.frame.size.width*pageIndex, 
                                                            0, 
                                                            self.itemListScrollView.frame.size.width, 
                                                            self.itemListScrollView.frame.size.height)] autorelease];
    [self addPageViewBackground:view];
    [self addItemsToPageView:view withPageIndex:pageIndex];
    return view;
}

- (void)createItemList
{
    int pageCount = _itemList.count/(LINE_PER_PAGE*ITEM_COUNT_PER_LINE) + 1;
    [self.itemListScrollView setContentSize:CGSizeMake(self.itemListScrollView.frame.size.width*pageCount, self.itemListScrollView.frame.size.height)];
    for (int i = 0; i < pageCount; i ++) {
        UIView* view = [self viewWithPageIndex:i];
        [self.itemListScrollView addSubview:view];
    }
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickItemButton:(id)sender
{
    UIButton* button = (UIButton*)sender;
    int itemIndex = button.tag-ITEM_BUTTON_OFFSET;
    if (itemIndex < _itemList.count) {
        Item* item = [_itemList objectAtIndex:itemIndex];
        if (item.type == ItemTypeColor) {
            ColorShopView *colorShop = [ColorShopView colorShopViewWithFrame:self.view.bounds];
            colorShop.delegate = self;
            [colorShop showInView:self.view animated:YES];
        } else {
            //
        }
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _itemList = [[NSMutableArray alloc] initWithObjects:[Item tomato], [Item tips], [Item colors], [Item flower], [Item iceCreamPen], [Item brushPen], [Item featherPen], nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTitles];
    [self initButtons];
    [self createItemList];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setItemListScrollView:nil];
    [self setCoinsButton:nil];
    [self setBuyCoinButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - colorShopView delegate
- (void)didPickedColorView:(ColorView *)colorView
{
    
}
@end
