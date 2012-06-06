//
//  SelectCustomWordView.h
//  Draw
//
//  Created by haodong qiu on 12年6月5日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDialog.h"

@protocol SelectCustomWordViewDelegate <NSObject>
- (void)didSelecCustomWord:(NSString *)word;
@end


@interface SelectCustomWordView : UIView<UITableViewDataSource,UITableViewDelegate, CommonDialogDelegate>

@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (assign, nonatomic) id<SelectCustomWordViewDelegate> delegate;

+ (SelectCustomWordView *)createView:(id<SelectCustomWordViewDelegate>)aDelegate;

- (void)showInView:(UIView *)superview;

- (IBAction)clickCloseButton:(id)sender;

@end
