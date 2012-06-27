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
    NSInteger _startIndex;
    NSString *_userId;
}
@property (retain, nonatomic) IBOutlet UILabel *noFeedTipsLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property(nonatomic, assign) NSInteger startIndex;
@property(nonatomic, retain) NSString *userId;

- (id)initWithUserId:(NSString *)userId;
- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickRefreshButton:(id)sender;

@end
