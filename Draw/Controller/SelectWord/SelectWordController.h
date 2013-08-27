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
#import "SelectCustomWordView.h"

typedef enum{
    OnlineDraw = 0,
    OfflineDraw = 1,
//    FeedDraw = 2,
}GameType;

@class ToolView;
@interface SelectWordController : PPViewController<UITableViewDataSource, UITableViewDelegate, DrawGameServiceDelegate, SelectCustomWordViewDelegate>
{
    NSArray *_wordArray;
    NSInteger  retainCount;
    BOOL hasPushController;
    ToolView *toolView;
    DrawGameService *drawGameService;
    NSTimer *_timer;
    NSString *_targetUid;
}

@property (retain, nonatomic) IBOutlet UITableView *wordTableView;
@property (retain, nonatomic) NSArray *wordArray;
@property (retain, nonatomic) IBOutlet UILabel *clockLabel;
@property (retain, nonatomic) IBOutlet UIButton *changeWordButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) GameType gameType;
@property (retain, nonatomic) IBOutlet UIImageView *timeBg;
@property (retain, nonatomic) IBOutlet UIButton *myWordsButton;
@property (retain, nonatomic) NSString *targetUid;
@property (retain, nonatomic) UIView  *adView;
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;

- (IBAction)clickChangeWordButton:(id)sender;
+ (void)startSelectWordFrom:(UIViewController *)controller gameType:(GameType)gameType;
+ (void)startSelectWordFrom:(UIViewController *)controller targetUid:(NSString *)targetUid;

- (id)initWithTargetUid:(NSString *)targetUid;
- (id)initWithType:(GameType)gameType;

@end
