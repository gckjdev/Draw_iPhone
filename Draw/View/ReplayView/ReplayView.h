//
//  ReplayView.h
//  Draw
//
//  Created by  on 12-9-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowDrawView.h"

@class DrawFeed;
@class ShowDrawView;
@interface ReplayView : UIView<ShowDrawViewDelegate>
{
    id _delegate;
    DrawFeed *_feed;
    ShowDrawView *_showView;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, retain) IBOutlet UIView *holderView;
@property(nonatomic, retain) ShowDrawView *showView;
@property(nonatomic, retain) DrawFeed *feed;

+ (id)createReplayView:(id)delegate;
- (IBAction)clickCloseButton:(id)sender;
- (void)setViewInfo:(DrawFeed *)feed;
- (void)showInView:(UIView *)view;
@end
