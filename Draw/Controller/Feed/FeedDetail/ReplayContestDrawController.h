//
//  ReplayContestDrawController.h
//  Draw
//
//  Created by haodong on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"
#import "CommonDialog.h"
#import "DrawDataService.h"

@class DrawFeed;
@class ShowDrawView;

@interface ReplayContestDrawController : PPViewController<CommonDialogDelegate, DrawDataServiceDelegate>
{
    ShowDrawView *_showView;
}
@property (retain, nonatomic) IBOutlet UIView *holderView;
@property (retain, nonatomic) ShowDrawView *showView;
@property (retain, nonatomic) IBOutlet UIButton *upButton;
@property (retain, nonatomic) IBOutlet UIButton *downButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;


- (id)initWithFeed:(DrawFeed *)feed;

@end
