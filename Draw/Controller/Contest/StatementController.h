//
//  StatementController.h
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"

@class Contest;
@interface StatementController : PPViewController
{
    Contest *_contest;
}

@property(nonatomic, retain)Contest *contest;
- (id)initWithContest:(Contest *)contest;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *declineButton;
@property (retain, nonatomic) IBOutlet UIButton *acceptButton;
@property (retain, nonatomic) IBOutlet UIWebView *contentView;

- (IBAction)clickDeclineButton:(id)sender;
- (IBAction)acceptButton:(id)sender;
@end
