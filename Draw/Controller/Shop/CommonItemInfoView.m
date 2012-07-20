//
//  CommonItemInfoView.m
//  Draw
//
//  Created by Orange on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonItemInfoView.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"
#import "LocaleUtils.h"
#import "Item.h"
#import "PPDebug.h"
#import "AccountService.h"
#import "DeviceDetection.h"
#import "AdService.h"
#import "PPViewController.h"

#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

@implementation CommonItemInfoView
@synthesize backgroundImageView = _backgroundImageView;
@synthesize mask = _mask;
@synthesize contentView = _contentView;
@synthesize itemTitle = _itemTitle;
@synthesize priceLabel = _priceLabel;
@synthesize itemCountLabel = _itemCountLabel;
@synthesize itemUnit = _itemUnit;
@synthesize coinLabel = _coinLabel;
@synthesize coinCountLabel = _coinCountLabel;
@synthesize itemDescriptionLabel = _itemDescriptionLabel;
@synthesize itemImageView = _itemImageView;
@synthesize cancelButton = _cancelButton;
@synthesize buyButton = _buyButton;
@synthesize currentItem = _currentItem;
@synthesize delegate = _delegate;

- (void)dealloc {
    PPRelease(_mask);
    PPRelease(_contentView);
    PPRelease(_backgroundImageView);
    [_itemTitle release];
    [_priceLabel release];
    [_itemCountLabel release];
    [_itemUnit release];
    [_coinLabel release];
    [_coinCountLabel release];
    [_itemDescriptionLabel release];
    [_itemImageView release];
    [_cancelButton release];
    [_buyButton release];
    [_currentItem release];
    [super dealloc];
}

- (void)initView
{
    [self.backgroundImageView setImage:[ShareImageManager defaultManager].friendDetailBgImage];
    [self.cancelButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.buyButton setBackgroundImage:[ShareImageManager defaultManager].greenImage forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [self.buyButton setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
    [self.priceLabel setText:NSLS(@"kCost")];
    [self.coinLabel setText:NSLS(@"kCoins")];
}

- (void)initViewWithItem:(Item*)anItem
{  
    [self initView];
    self.currentItem = anItem;
    [self.itemImageView setImage:anItem.itemImage];
    [self.itemDescriptionLabel setText:anItem.itemDescription];
    [self.itemTitle setText:anItem.itemName];
    if ([Item isItemCountable:anItem.type]) {
        [self.itemCountLabel setText:[NSString stringWithFormat:@"x %d",anItem.buyAmountForOnce]];
    }
    [self.coinCountLabel setText:[NSString stringWithFormat:@"%d",anItem.price]];

}


+ (CommonItemInfoView*)createUserInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommonItemInfoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <CommonItemInfoView> but cannot find cell object from Nib");
        return nil;
    }
    CommonItemInfoView* view =  (CommonItemInfoView*)[topLevelObjects objectAtIndex:0];
    
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:NO];
    [view.contentView.layer addAnimation:runIn forKey:@"runIn"];
    
    return view;
}

+ (void)showItem:(Item*)anItem 
      infoInView:(PPViewController<CommonItemInfoViewDelegate>*)superController
{
    CommonItemInfoView* view = [CommonItemInfoView createUserInfoView];
    [view initViewWithItem:anItem];
    view.delegate = superController;
    [superController.view addSubview:view];
}


- (void)startRunOutAnimation
{
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.contentView.layer addAnimation:runOut forKey:@"runOut"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }
}

- (IBAction)clickMask:(id)sender
{
    [self startRunOutAnimation];
}

- (IBAction)clickOK:(id)sender
{
    if (self.currentItem.type == ItemTypeRemoveAd){
        // special handling for ad
        [[AdService defaultService] requestRemoveAd:self.delegate];
        return;
    }    
    
    int result = [[AccountService defaultService] buyItem:self.currentItem.type 
                                   itemCount:self.currentItem.buyAmountForOnce 
                                   itemCoins:self.currentItem.price];
    if (_delegate && [_delegate respondsToSelector:@selector(didBuyItem:result:)]) {
        [_delegate didBuyItem:self.currentItem 
                       result:result];
    }
    [self startRunOutAnimation];
}

- (IBAction)clickCancel:(id)sender
{
    [self startRunOutAnimation];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
