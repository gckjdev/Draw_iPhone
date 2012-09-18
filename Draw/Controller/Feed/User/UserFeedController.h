//
//  UserFeedController.h
//  Draw
//
//  Created by  on 12-6-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "FeedCell.h"
#import "FeedService.h"

@interface UserFeedController : PPTableViewController<FeedServiceDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *noFeedTipsLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *opusButton;
@property (retain, nonatomic) IBOutlet UIButton *feedButton;

- (id)initWithUserId:(NSString *)userId nickName:(NSString *)nickName;
- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickRefreshButton:(id)sender;
- (IBAction)clickTabButton:(id)sender;

@end
