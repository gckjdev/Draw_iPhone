//
//  VendingController.h
//  Draw
//
//  Created by Orange on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"

@interface VendingController : PPViewController {
    NSMutableArray* _itemList;
}
@property (retain, nonatomic) IBOutlet UIScrollView *itemListScrollView;
@property (retain, nonatomic) IBOutlet UIButton *coinsButton;
@property (retain, nonatomic) IBOutlet UIButton *buyCoinButton;

@end
