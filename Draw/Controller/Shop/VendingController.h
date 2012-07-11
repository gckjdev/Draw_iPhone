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

@interface VendingController : PPViewController <ColorShopViewDelegate, CommonItemInfoViewDelegate>{
    NSMutableArray* _itemList;
}
@property (retain, nonatomic) IBOutlet UIScrollView *itemListScrollView;
@property (retain, nonatomic) IBOutlet UIButton *coinsButton;
@property (retain, nonatomic) IBOutlet UIButton *buyCoinButton;
@property (retain, nonatomic) IBOutlet UIImageView *outItem;

@end
