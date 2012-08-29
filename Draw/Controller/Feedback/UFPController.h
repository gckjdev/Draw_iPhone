//
//  UFPController.h
//  Draw
//
//  Created by Orange on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMUFPTableView.h"
#import "PPTableViewController.h"

@interface UFPController :  PPTableViewController<UMUFPTableViewDataLoadDelegate, UITableViewDataSource, UITableViewDelegate> {
    
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UMUFPTableView* mTableView;
@property (retain, nonatomic) NSArray* mPromoterDatas;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end
