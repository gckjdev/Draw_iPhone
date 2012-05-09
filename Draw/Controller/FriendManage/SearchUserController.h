//
//  SearchUserController.h
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"

@interface SearchUserController :PPTableViewController 
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) IBOutlet UITextField *inputTextField;

- (IBAction)clickBack:(id)sender;
- (IBAction)clickSearch:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
