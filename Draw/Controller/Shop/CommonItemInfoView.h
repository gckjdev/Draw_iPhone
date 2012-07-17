//
//  CommonItemInfoView.h
//  Draw
//
//  Created by Orange on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Item;

@protocol CommonItemInfoViewDelegate <NSObject>

- (void)didBuyItem:(Item*)anItem 
            result:(int)result;

@end

@interface CommonItemInfoView : UIView

+ (void)showItem:(Item*)anItem 
      infoInView:(UIViewController*)superController;

@property (retain, nonatomic) IBOutlet UIImageView* backgroundImageView;
@property (retain, nonatomic) IBOutlet UIButton *mask;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *itemTitle;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *itemUnit;
@property (retain, nonatomic) IBOutlet UILabel *coinLabel;
@property (retain, nonatomic) IBOutlet UILabel *coinCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *itemDescriptionLabel;
@property (retain, nonatomic) IBOutlet UIImageView *itemImageView;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;
@property (retain, nonatomic) Item* currentItem;
@property (assign, nonatomic) id<CommonItemInfoViewDelegate> delegate;

@end
