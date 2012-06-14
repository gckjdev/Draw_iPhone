//
//  FeedController.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "FeedService.h"

@interface FeedController : PPTableViewController<FeedServiceDelegate>
{
    
}
- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickFeedButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *myFeedButton;
@property (retain, nonatomic) IBOutlet UIButton *allFeedButton;
@property (retain, nonatomic) IBOutlet UIButton *hotFeedButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@end
