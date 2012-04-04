//
//  SelectWordController.h
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawGameService.h"
#import "PPViewController.h"
@class ToolView;
@interface SelectWordController : PPViewController<UITableViewDataSource, UITableViewDelegate, DrawGameServiceDelegate>
{
    NSArray *_wordArray;
    NSInteger  retainCount;
    BOOL hasPushController;
    ToolView *toolView;
    DrawGameService *drawGameService;
}

@property (retain, nonatomic) IBOutlet UITableView *wordTableView;
@property (retain, nonatomic) NSArray *wordArray;
- (IBAction)clickChangeWordButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *clockLabel;
@property (retain, nonatomic) IBOutlet UIButton *changeWordButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@end
