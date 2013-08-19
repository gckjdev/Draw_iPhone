//
//  MyWordsController.h
//  Draw
//
//  Created by haodong qiu on 12年6月4日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"
#import "CommonDialog.h"

@interface MyWordsController : PPTableViewController<CommonDialogDelegate>
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *addWordButton;

@end
