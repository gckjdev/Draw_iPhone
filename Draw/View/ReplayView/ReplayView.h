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


@interface ReplayView : UIView<ShowDrawViewDelegate>
{

}


@property(nonatomic, assign)NSUInteger endIndex;
@property(nonatomic, retain)DrawFeed *drawFeed;

+ (id)createReplayView;

- (void)showInController:(PPViewController *)controller
          withActionList:(NSMutableArray *)actionList
            isNewVersion:(BOOL)isNewVersion;

- (void)showInController:(PPViewController *)controller
          withActionList:(NSMutableArray *)actionList
            isNewVersion:(BOOL)isNewVersion
                    size:(CGSize)size;


- (void)setPlayControlsDisable:(BOOL)disable;

@end
