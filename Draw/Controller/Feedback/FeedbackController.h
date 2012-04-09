//
//  FeedbackController.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "SNSServiceDelegate.h"

@interface FeedbackController : PPViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, SNSServiceDelegate>
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UILabel *TitleLabel;

@end
