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


typedef enum{
    OnlineDraw = 0,
    OfflineDraw = 1,
}GameType;

@class ToolView;
@interface SelectWordController : PPViewController<UITableViewDataSource, UITableViewDelegate, DrawGameServiceDelegate>
{
    NSArray *_wordArray;
    NSInteger  retainCount;
    BOOL hasPushController;
    ToolView *toolView;
    DrawGameService *drawGameService;
    NSTimer *_timer;
}

@property (retain, nonatomic) IBOutlet UITableView *wordTableView;
@property (retain, nonatomic) NSArray *wordArray;
@property (retain, nonatomic) IBOutlet UILabel *clockLabel;
@property (retain, nonatomic) IBOutlet UIButton *changeWordButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) GameType gameType;
@property (retain, nonatomic) IBOutlet UIImageView *timeBg;
- (IBAction)clickChangeWordButton:(id)sender;


- (id)initWithType:(GameType)gameType;

@end
