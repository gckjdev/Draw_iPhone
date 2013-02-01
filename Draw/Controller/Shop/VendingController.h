//
//  VendingController.h
//  Draw
//
//  Created by Orange on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"
#import "ColorShopView.h"
#import "CommonItemInfoView.h"
#import "UICustomPageControl.h"
#import "CommonDialog.h"


@interface VendingController : PPViewController <ColorShopViewDelegate, CommonItemInfoViewDelegate, CommonDialogDelegate>{
    NSMutableArray* _itemList;
    int _currentBuyingItem;
}
@property (retain, nonatomic) IBOutlet UIImageView *itemOutImageView;
@property (retain, nonatomic) IBOutlet UIScrollView *itemListScrollView;
@property (retain, nonatomic) IBOutlet UIButton *coinsButton;
@property (retain, nonatomic) IBOutlet UIButton *buyCoinButton;
@property (retain, nonatomic) IBOutlet UIImageView *outItem;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *titleImageView;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIButton *coinsShopButton;
@property (retain, nonatomic) IBOutlet UICustomPageControl *pageControl;

+ (VendingController *)instance;
- (UINavigationController *)topNavigationController;

@end
