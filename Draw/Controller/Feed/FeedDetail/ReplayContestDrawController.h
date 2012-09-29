//
//  ReplayContestDrawController.h
//  Draw
//
//  Created by haodong on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"

@class DrawFeed;

@interface ReplayContestDrawController : PPViewController
@property (retain, nonatomic) IBOutlet UIView *holderView;

- (id)initWithFeed:(DrawFeed *)feed;

@end
