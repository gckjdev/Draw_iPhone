//
//  SelectCustomWordView.h
//  Draw
//
//  Created by haodong qiu on 12年6月5日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDialog.h"
#import "CommonDialog.h"

@class SelectCustomWordView;

@protocol SelectCustomWordViewDelegate <NSObject>

@optional
- (void)didSelecCustomWord:(NSString *)word;
- (void)didCloseSelectCustomWordView:(SelectCustomWordView *)view;

@end


@interface SelectCustomWordView : UIView<UITableViewDataSource,UITableViewDelegate, CommonDialogDelegate, CommonDialogDelegate>
@property (retain, nonatomic) IBOutlet UIButton *bgButton;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *addWordButton;
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (assign, nonatomic) id<SelectCustomWordViewDelegate> delegate;

+ (SelectCustomWordView *)createView:(id<SelectCustomWordViewDelegate>)aDelegate;

- (void)showInView:(UIView *)superview;

@end
