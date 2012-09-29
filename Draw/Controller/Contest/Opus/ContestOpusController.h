//
//  HotController.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonTabController.h"
#import "FeedService.h"
#import "RankView.h"
#import "TopPlayerView.h"
#import "UserService.h"

@class Contest;
@interface ContestOpusController : CommonTabController<FeedServiceDelegate,RankViewDelegate,TopPlayerViewDelegate,UserServiceDelegate>
{
    Contest *_contest;
}

@property(nonatomic, retain)Contest *contest;
- (id)initWithContest:(Contest *)contest;
@end
