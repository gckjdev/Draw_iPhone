//
//  ToolSheetView.h
//  Draw
//
//  Created by haodong qiu on 12年7月30日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"

@protocol ToolSheetViewDelegate <NSObject>

@optional
- (void)didSelectTool:(NSInteger)index;
- (void)didDismissToolSheet;

@end


@interface ToolSheetView : UIView <CMPopTipViewDelegate>

@property (assign, nonatomic) id<ToolSheetViewDelegate> delegate;

- (void)updateWithTitleList:(NSArray *)titleList 
            countNumberList:(NSArray *)countNumberList 
                   delegate:(id<ToolSheetViewDelegate>)delegate;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL)animated;

@end
