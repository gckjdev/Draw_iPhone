//
//  itemListView.h
//  Draw
//
//  Created by haodong qiu on 12年7月30日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"
#import "DiceItem.h"

@protocol DiceItemListViewDelegate <NSObject>

@optional
- (void)didSelectItem:(Item *)item;
- (void)didDismissItemListView;

@end


@interface DiceItemListView : UIView <CMPopTipViewDelegate>

@property (assign, nonatomic) id<DiceItemListViewDelegate> delegate;

- (void)disableCutItem;
- (void)enableCutItem;

- (void)update;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
       aboveSubView:(UIView *)siblingSubview
           duration:(int)duration
           animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL)animated;

@end
