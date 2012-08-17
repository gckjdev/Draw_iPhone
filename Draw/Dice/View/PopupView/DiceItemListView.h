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


- (id)init;
- (void)updateWithDelegate:(id<DiceItemListViewDelegate>)delegate;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL)animated;

@end
