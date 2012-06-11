//
//  YoumiWallController.h
//  Draw
//
//  Created by  on 12-6-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouMiWall.h"
#import "PPTableViewController.h"

@interface YoumiWallController : PPTableViewController
{
    NSInteger point;  // 用户的积分
    
    
    // 
    YouMiWall *wall;
    NSMutableArray *openApps;
    
}

- (IBAction)clickHelp:(id)sender;
- (IBAction)clickQueryPoints:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *helpButton;
@property (retain, nonatomic) IBOutlet UIButton *queryButton;

@end
