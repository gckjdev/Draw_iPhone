//
//  ReplayView.h
//  Draw
//
//  Created by  on 12-9-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowDrawView.h"
#import "PPViewController.h"
//#import "CommonItemInfoView.h"
#import "DrawBgManager.h"
#import "DrawFeed.h"
#import "AdService.h"


@interface ReplayObject : NSObject
{
    
}

+ (id)obj;

@property(nonatomic, assign) BOOL *isNewVersion;
@property(nonatomic, assign) CGSize canvasSize;

@property(nonatomic, retain) NSMutableArray *actionList;
@property(nonatomic, retain) UIImage *bgImage;
@property(nonatomic, retain) NSArray *layers;

@end

@interface ReplayView : UIView<ShowDrawViewDelegate>
{
}




@property(nonatomic, assign)NSUInteger endIndex;
@property(nonatomic, retain)DrawFeed *drawFeed;
@property(nonatomic, retain)UIView *adView;;
@property(nonatomic, assign)BOOL popControllerWhenClose;

+ (id)createReplayView;

- (void)showInController:(PPViewController *)controller
                  object:(ReplayObject *)obj;

- (void)setPlayControlsDisable:(BOOL)disable;

@end
