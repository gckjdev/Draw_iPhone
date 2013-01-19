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
#import "StableView.h"
#import "ItemManager.h"
#import "AnimationManager.h"
#import "CoinShopController.h"
#import "DeviceDetection.h"
#import "CommonMessageCenter.h"
#import "ConfigManager.h"
//#import "YoumiWallController.h"
#import "LmWallService.h"
#import "DiceItem.h"
#import "FontButton.h"
#import "CustomDiceManager.h"


#define ITEM_COUNT_PER_LINE 3
#define LINE_PER_PAGE       3

#define PRICE_TAG_OFFSET 20120710
#define ITEM_BUTTON_OFFSET  120120710
#define PAGE_TAG_OFFSET      220120710

#define ITEM_TIPS_DIALOG_TAG    20120924

#define BOUGHT_ITEM @"boughtItem"

#define FIRST_SHELF_FRAME   ([DeviceDetection isIPAD]?CGRectMake(12, 150, 712, 117):CGRectMake(5, 69, 297, 54))
#define SHELF_SEPERATOR     ([DeviceDetection isIPAD]?240:110)
#define FIRST_ITEM_FRAME    ([DeviceDetection isIPAD]?CGRectMake(70, 56, 122, 122):CGRectMake(24, 23, 61, 61))
#define FIRST_PRICE_COIN_FRAME  ([DeviceDetection isIPAD]?CGRectMake(96, 196, 34, 34):CGRectMake(37, 89, 17, 17))
#define FIRST_PRICE_LABEL_FRAME ([DeviceDetection isIPAD]?CGRectMake(138, 196, 100, 34):CGRectMake(57, 89, 42, 17))
#define ITEM_SEPERATOR  ([DeviceDetection isIPAD]?235:98)
#define OUT_ITEM_CENTER (self.itemOutImageView.center)
#define OUT_ITEM_AMPLITUDE  ([DeviceDetection isIPAD]?100:35)

#define PRICE_LABEL_FONT_SIZE   ([DeviceDetection isIPAD]?26:13)

#define ANIM_GROUP        @"animationFallingRotate"
#define FALLING_GROUP       @"fallingGroup"

static VendingController* staticVendingController = nil;

@interface VendingController () <ColorShopViewDelegate>

@end

@implementation VendingController
@synthesize itemListScrollView;
@synthesize coinsButton;
@synthesize buyCoinButton;
@synthesize outItem;
@synthesize titleLabel;
@synthesize titleImageView;
@synthesize bgImageView;
@synthesize coinsShopButton;
@synthesize pageControl;
@synthesize itemOutImageView = _itemOutImageView;

- (void)dealloc {
    [itemListScrollView release];
    [coinsButton release];
    [buyCoinButton release];
    [_itemList release];
    [outItem release];
    [titleLabel release];
    [titleImageView release];
    [bgImageView release];
    [coinsShopButton release];
    [pageControl release];
    [_itemOutImageView release];
    [super dealloc];
    
}

+(VendingController *)instance
{
    if (staticVendingController == nil) {
        staticVendingController = [[VendingController alloc] init];
    }
    return staticVendingController;
}

- (UINavigationController *)topNavigationController
{
//    if (_coinController) {
//        return _coinController.navigationController;
//    }
    return self.navigationController;
}

- (void)initButtons
{
    [self.buyCoinButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.coinsShopButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    NSString* buyCoinButtonTitle;
    if ([ConfigManager wallEnabled]) {
        buyCoinButtonTitle = NSLS(@"kFreeCoins");
    } else {
        buyCoinButtonTitle = NSLS(@"kCoinShopTitle");
    }
    [self.buyCoinButton setTitle:buyCoinButtonTitle forState:UIControlStateNormal];
}

- (void)initTitles
{
    [self.coinsButton setTitle:[NSString stringWithFormat:@"x %d",[AccountManager defaultManager].getBalance] forState:UIControlStateNormal];
}

- (void)addPageViewBackground:(UIView*)view
{
    ShareImageManager* manager = [ShareImageManager defaultManager];
    //add background
    UIImageView* bg = [[[UIImageView alloc] initWithImage:manager.shoppingBackground] autorelease];
    
    bg.frame  = view.bounds;
    bg.autoresizingMask =
    !UIViewAutoresizingFlexibleBottomMargin
    | !UIViewAutoresizingFlexibleTopMargin
    | !UIViewAutoresizingFlexibleLeftMargin
    | !UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    
    [view addSubview:bg];
    
    //add shelf
    for (int i = 0; i < LINE_PER_PAGE; i ++) {
        UIImageView* shelf = [[[UIImageView alloc] initWithImage:manager.shopShelf] autorelease];
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
    ToolView* toolView = [[ToolView alloc] initWithItemType:item.type number:item.amount];
    [toolView setFrame:CGRectMake(FIRST_ITEM_FRAME.origin.x + ITEM_SEPERATOR*(index%ITEM_COUNT_PER_LINE), 
                                 FIRST_ITEM_FRAME.origin.y + SHELF_SEPERATOR*(index/ITEM_COUNT_PER_LINE), 
                                 FIRST_ITEM_FRAME.size.width, 
                                  FIRST_ITEM_FRAME.size.height)];
//    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(FIRST_ITEM_FRAME.origin.x + ITEM_SEPERATOR*(index%ITEM_COUNT_PER_LINE), 
//                                                                  FIRST_ITEM_FRAME.origin.y + SHELF_SEPERATOR*(index/ITEM_COUNT_PER_LINE), 
//                                                                  FIRST_ITEM_FRAME.size.width, 
//                                                                  FIRST_ITEM_FRAME.size.height)];
    UIImageView* coin = [[UIImageView alloc] initWithFrame:CGRectMake(FIRST_PRICE_COIN_FRAME.origin.x + ITEM_SEPERATOR*(index%ITEM_COUNT_PER_LINE), 
                                                                  FIRST_PRICE_COIN_FRAME.origin.y + SHELF_SEPERATOR*(index/ITEM_COUNT_PER_LINE), 
                                                                  FIRST_PRICE_COIN_FRAME.size.width, 
                                                                  FIRST_PRICE_COIN_FRAME.size.height)];
    UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(FIRST_PRICE_LABEL_FRAME.origin.x + ITEM_SEPERATOR*(index%ITEM_COUNT_PER_LINE), 
                                                                  FIRST_PRICE_LABEL_FRAME.origin.y + SHELF_SEPERATOR*(index/ITEM_COUNT_PER_LINE), 
                                                                  FIRST_PRICE_LABEL_FRAME.size.width, 
                                                                  FIRST_PRICE_LABEL_FRAME.size.height)];
    
    [coin setImage:[ShareImageManager defaultManager].smallCoin];
    
    [priceLabel setText:[NSString stringWithFormat:@"%d",item.price]];
    [priceLabel setBackgroundColor:[UIColor clearColor]];
    
    [priceLabel setFont:[UIFont systemFontOfSize:PRICE_LABEL_FONT_SIZE]];
    
    int pageIndex = view.tag-PAGE_TAG_OFFSET;
    toolView.tag = pageIndex*LINE_PER_PAGE*ITEM_COUNT_PER_LINE+index+ITEM_BUTTON_OFFSET;
    [toolView addTarget:self action:@selector(clickItemButton:)];
    
    [view addSubview:toolView];
    [view addSubview:coin];
    [view addSubview:priceLabel];
    [toolView release];
    [coin release];
    [priceLabel release];
    
    
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
    view.autoresizingMask =
    !UIViewAutoresizingFlexibleBottomMargin
    | !UIViewAutoresizingFlexibleTopMargin
    | !UIViewAutoresizingFlexibleLeftMargin
    | !UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    
    [self addPageViewBackground:view];
    [self addItemsToPageView:view withPageIndex:pageIndex];
    return view;
}

- (void)createItemList
{
    int pageCount = (_itemList.count-1)/(LINE_PER_PAGE*ITEM_COUNT_PER_LINE) + 1;
    [self.itemListScrollView setContentSize:CGSizeMake(self.itemListScrollView.frame.size.width*pageCount, self.itemListScrollView.frame.size.height)];
    for (int i = 0; i < pageCount; i ++) {
        UIView* view = [self viewWithPageIndex:i];
        [self.itemListScrollView addSubview:view];
    }
}

- (void)refleshToolViewForItem:(Item*)anItem
{
    int pageCount = _itemList.count/(LINE_PER_PAGE*ITEM_COUNT_PER_LINE) + 1;
    for (int i = 0; i < pageCount; i ++) {
        UIView* view = [self.itemListScrollView viewWithTag:PAGE_TAG_OFFSET+i];
        int firstItemTag = i*LINE_PER_PAGE*ITEM_COUNT_PER_LINE;
        for (int j = firstItemTag; j < firstItemTag+LINE_PER_PAGE*ITEM_COUNT_PER_LINE; j ++) {
            ToolView* tool = (ToolView*)[view viewWithTag:(ITEM_BUTTON_OFFSET+j)];
            if (tool && tool.itemType == anItem.type) {
                if ([Item isItemCountable:anItem.type]) {
                    [tool setNumber:[[ItemManager defaultManager] amountForItem:anItem.type]];
                    
                } else {
                    [tool setAlreadyHas:YES];
                }
            }
        }
    }

}

- (void)showWall
{        
    [UIUtils alertWithTitle:@"免费金币获取提示" msg:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励哦！"];
    [[LmWallService defaultService] show:self];
}

- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickCoin:(id)sender
{
    CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];    
}

- (IBAction)buyCoin:(id)sender
{
    if ([ConfigManager wallEnabled]) {
        [self showWall];
    } else {
        CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}
- (IBAction)clickCoinsShopButton:(id)sender {
    CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)clickItemButton:(id)sender
{
    [self.outItem.layer removeAllAnimations];
    ToolView* button = (ToolView*)sender;
    BOOL canBuyAgain = [Item isItemCountable:button.itemType] || !button.alreadyHas;
    int itemIndex = button.tag-ITEM_BUTTON_OFFSET;
    if (itemIndex < _itemList.count) {
        Item* item = [_itemList objectAtIndex:itemIndex];
        if (item.type == ItemTypeColor) {
            ColorShopView *colorShop = [ColorShopView colorShopViewWithFrame:self.view.bounds];
            colorShop.delegate = self;
            [colorShop showInView:self.view animated:YES];
        } else {
            [CommonItemInfoView showItem:item infoInView:self canBuyAgain:canBuyAgain];
        }
    }    
}

#define FALLING_TIME    0.05
#define TIME_FROME_CENTER_TO_SIDE   1
#define ENLARGE_DURATION    2
#define ENLARGE_RATE    20
- (void)showBuyItemAnimation:(Item*)anItem
{
    [self.outItem setImage:anItem.itemImage];
    
    CAAnimation* falling = [AnimationManager translationAnimationFrom:self.outItem.center 
                                                                   to:self.itemOutImageView.center
                                                             duration:FALLING_TIME 
                                                             delegate:self 
                                                     removeCompeleted:NO];
    
    CAAnimation* rolling = [AnimationManager rotateAnimationWithRoundCount:1 
                                                                  duration:TIME_FROME_CENTER_TO_SIDE];
    rolling.delegate = self;
    rolling.beginTime =FALLING_TIME;
    rolling.autoreverses = YES;
    rolling.removedOnCompletion = NO;
    
    CAAnimation* rRolling = [AnimationManager rotateAnimationWithRoundCount:-1 
                                                                   duration:TIME_FROME_CENTER_TO_SIDE];
    rRolling.delegate = self;
    rRolling.beginTime =FALLING_TIME + 2*TIME_FROME_CENTER_TO_SIDE;
    rRolling.autoreverses = YES;
    rRolling.removedOnCompletion = NO;
    
    CAAnimation* moveToRight = [AnimationManager translationAnimationTo:CGPointMake(OUT_ITEM_CENTER.x+OUT_ITEM_AMPLITUDE, OUT_ITEM_CENTER.y)
                                                               duration:TIME_FROME_CENTER_TO_SIDE];
    moveToRight.beginTime = FALLING_TIME;
    moveToRight.removedOnCompletion = NO;
    
    CAAnimation* moveToLeft = [AnimationManager translationAnimationFrom:CGPointMake(OUT_ITEM_CENTER.x+OUT_ITEM_AMPLITUDE, OUT_ITEM_CENTER.y) 
                                                                      to:CGPointMake(OUT_ITEM_CENTER.x-OUT_ITEM_AMPLITUDE, OUT_ITEM_CENTER.y) 
                                                                duration:2*TIME_FROME_CENTER_TO_SIDE];
    moveToLeft.beginTime = moveToRight.beginTime+moveToRight.duration;
    moveToLeft.removedOnCompletion = NO;
    
    CAAnimation* moveToCenter = [AnimationManager translationAnimationFrom:CGPointMake(OUT_ITEM_CENTER.x-OUT_ITEM_AMPLITUDE, OUT_ITEM_CENTER.y) 
                                                                        to:OUT_ITEM_CENTER 
                                                                  duration:TIME_FROME_CENTER_TO_SIDE];
    moveToCenter.beginTime = moveToLeft.beginTime+moveToLeft.duration;
    moveToCenter.removedOnCompletion = NO;
    
    CAAnimation* toScreenCenter = [AnimationManager translationAnimationFrom:OUT_ITEM_CENTER 
                                                                          to:self.view.center 
                                                                    duration:ENLARGE_DURATION 
                                                                    delegate:self 
                                                            removeCompeleted:NO];
    toScreenCenter.beginTime = moveToCenter.beginTime + moveToCenter.duration;
    
    
    CAAnimation* enLarge = [AnimationManager scaleAnimationWithScale:ENLARGE_RATE 
                                                            duration:ENLARGE_DURATION 
                                                            delegate:self 
                                                    removeCompeleted:NO];
    enLarge.beginTime = moveToCenter.beginTime + moveToCenter.duration;
    //enLarge.removedOnCompletion = NO;
    
    CAAnimation* disappear = [AnimationManager disappearAnimationWithDuration:ENLARGE_DURATION];
    disappear.beginTime = moveToCenter.beginTime + moveToCenter.duration;
    disappear.removedOnCompletion = NO;
    
    //method2:放入动画数组，统一处理！
    CAAnimationGroup* animGroup    = [CAAnimationGroup animation];
    
    //设置动画代理
    animGroup.delegate = self;
    
    animGroup.removedOnCompletion = YES;
    
    animGroup.duration             = disappear.beginTime+disappear.duration;
    animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
    animGroup.repeatCount         = 1;//FLT_MAX;  //"forever";
    animGroup.fillMode             = kCAFillModeForwards;
    animGroup.animations             = [NSArray arrayWithObjects:falling, rolling, moveToRight, moveToLeft, moveToCenter, rRolling, enLarge, disappear, toScreenCenter,nil];
    [animGroup setValue:FALLING_GROUP  forKey:ANIM_GROUP];
    //对视图自身的层添加组动画
    [self.outItem.layer addAnimation:animGroup forKey:ANIM_GROUP];
    
    

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([ConfigManager isProVersion]){
            if (isDrawApp()) {
                _itemList = [[NSMutableArray alloc] initWithObjects:[Item tips], [Item colors], [Item tomato], [Item flower], [Item iceCreamPen], [Item brushPen], [Item featherPen], [Item waterPen], [Item PaletteItem],nil];
                if ([DeviceDetection isIPAD] || [DeviceDetection isIPhone5]) {
                    [_itemList addObject:[Item ColorAlphaItem]];
                }
            }
            
            if (isDiceApp() || isZhajinhuaApp()) {
                _itemList = [[NSMutableArray alloc] initWithObjects:[Item removeAd], [Item rollAgain], [Item cut], [Item peek], [Item postpone], [Item urge], [Item turtle], [Item diceRobot], [Item reverse], [Item patriotDice], [Item goldenDice], [Item woodDice], [Item blueCrystalDice], [Item pinkCrystalDice], [Item greenCrystalDice], [Item purpleCrystalDice], [Item blueDiamondDice], [Item pinkDiamondDice], [Item greenDiamondDice], [Item purpleDiamondDice], nil];       
            }
        }
        else{
            if (isDrawApp()) {
                _itemList = [[NSMutableArray alloc] initWithObjects:[Item removeAd], [Item tips], [Item colors], [Item tomato], [Item flower], [Item iceCreamPen], [Item brushPen], [Item featherPen], [Item waterPen], [Item PaletteItem], nil];
                if ([DeviceDetection isIPAD] || [DeviceDetection isIPhone5]) {
                    [_itemList addObject:[Item ColorAlphaItem]];
                }
            }
            
            if (isDiceApp() || isZhajinhuaApp()) {
                _itemList = [[NSMutableArray alloc] initWithObjects:[Item removeAd], [Item rollAgain], [Item cut], [Item peek], [Item postpone], [Item urge], [Item turtle], [Item diceRobot], [Item reverse], [Item patriotDice], [Item goldenDice], [Item woodDice], [Item blueCrystalDice], [Item pinkCrystalDice], [Item greenCrystalDice], [Item purpleCrystalDice], [Item blueDiamondDice], [Item pinkDiamondDice], [Item greenDiamondDice], [Item purpleDiamondDice], nil];
            }

        }
    }
    return self;
}

- (void)initCustomPageControl
{
    self.pageControl.hidden = (_itemList.count > LINE_PER_PAGE*ITEM_COUNT_PER_LINE)?NO:YES;
    self.pageControl.hidesForSinglePage = YES;
    int pageCount = (_itemList.count-1)/(LINE_PER_PAGE*ITEM_COUNT_PER_LINE) + 1;
    [self.pageControl setNumberOfPages:pageCount];
    
    [self.pageControl setPageIndicatorImageForCurrentPage:[[ShareImageManager defaultManager] pointForCurrentSelectedPage] forNotCurrentPage:[[ShareImageManager defaultManager] pointForUnSelectedPage]];
    
    if ([DeviceDetection isIPAD]) {
        self.pageControl.transform = CGAffineTransformMakeScale(2.0, 2.0);
        self.pageControl.center = CGPointMake(self.view.center.x, self.pageControl.center.y);
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTitles];
    [self initButtons];
    [self createItemList];
    self.titleImageView.hidden = !isDrawApp();
    self.titleLabel.hidden = !isDiceApp();
    self.titleLabel.text = NSLS(@"kDiceShop");
    self.bgImageView.image = [UIImage imageNamed:[GameApp background]];
    
    self.coinsShopButton.hidden = YES;
    
    if (isDiceApp() && [ConfigManager wallEnabled]) {
        self.coinsShopButton.hidden = NO;
    }
    

    [self initCustomPageControl];
    [self.coinsButton.titleLabel setAdjustsFontSizeToFitWidth:YES];

    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidUnload
{
    [self setItemListScrollView:nil];
    [self setCoinsButton:nil];
    [self setBuyCoinButton:nil];
    [self setOutItem:nil];
    [self setTitleLabel:nil];
    [self setTitleImageView:nil];
    [self setBgImageView:nil];
    [self setCoinsShopButton:nil];
    [self setPageControl:nil];
    [self setItemOutImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma animation delegate
- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* animValue = [anim valueForKey:ANIM_GROUP];
    if ([animValue isEqualToString:FALLING_GROUP]) {
        [self.outItem setImage:nil];
    }
}

#pragma mark - colorShopView delegate
- (void)didPickedColorView:(ColorView *)colorView
{
    
}

#pragma mark - commonItemInfoViewDelegate
- (void)didBuyItem:(Item *)anItem 
            result:(int)result
{ 
    if (result == ERROR_COINS_NOT_ENOUGH) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCoinsNotEnough") delayTime:1 isHappy:NO];
    } else {
        [self.coinsButton setTitle:[NSString stringWithFormat:@"x %d",[AccountManager defaultManager].getBalance] forState:UIControlStateNormal];
        [self showBuyItemAnimation:anItem];
        [self refleshToolViewForItem:anItem];
        [self showItemTips:anItem];
    }
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    /* we switch page at %50 across */
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth +1);
    self.pageControl.currentPage = page;
}

- (void)showItemTips:(Item*)anItem
{
    if (![[ItemManager defaultManager] hasShownItemTips:anItem.type]) {
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kItemTips") 
                                                           message:[Item getItemTips:anItem.type] 
                                                             style:CommonDialogStyleDoubleButton 
                                                          delegate:self];
        dialog.tag = ITEM_TIPS_DIALOG_TAG;
        [dialog.oKButton.fontLable setText:NSLS(@"kNoMoreShowIt")];
        [dialog.oKButton.fontLable setAdjustsFontSizeToFitWidth:YES];
        [dialog.backButton.fontLable setText:NSLS(@"kOK")];
        _currentBuyingItem = anItem.type;
        [dialog showInView:self.view];
    }
    if ([Item isCustomDice:anItem.type]) {
        [[CustomDiceManager defaultManager] setMyDiceTypeByItemType:anItem.type];
    }
    
}

#pragma mark - commondialog delegate
- (void)clickOk:(CommonDialog *)dialog
{
    [[ItemManager defaultManager] didShowItemTips:_currentBuyingItem];
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}

@end
