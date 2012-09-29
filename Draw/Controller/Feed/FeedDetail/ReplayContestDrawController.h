//
//  ReplayContestDrawController.h
//  Draw
//
//  Created by haodong on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"

@class DrawFeed;
@class ShowDrawView;
@interface ReplayContestDrawController : PPViewController
{
    ShowDrawView *_showView;
}
@property (retain, nonatomic) IBOutlet UIView *holderView;
@property (retain, nonatomic) ShowDrawView *showView;
- (id)initWithFeed:(DrawFeed *)feed;

@end
