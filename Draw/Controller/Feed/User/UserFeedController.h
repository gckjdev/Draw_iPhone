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
#import "CommonTabController.h"
#import "RankView.h"

@interface UserFeedController : CommonTabController<FeedServiceDelegate, RankViewDelegate, UIActionSheetDelegate>
{
    NSString *_userId;
    NSString *_nickName;
}

@property(nonatomic, retain)NSString *userId;
@property(nonatomic, retain)NSString *nickName;

- (id)initWithUserId:(NSString *)userId
            nickName:(NSString *)nickName;

- (id)initWithUserId:(NSString *)userId
            nickName:(NSString *)nickName
     defaultTabIndex:(int)defaultTabIndex;
@end
