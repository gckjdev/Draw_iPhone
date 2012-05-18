//
//  ShowRemoteDrawController.h
//  Draw
//
//  Created by haodong qiu on 12年5月17日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPViewController.h"

@class PBDraw;

@interface ShowRemoteDrawController : PPViewController

@property (retain, nonatomic) PBDraw *draw;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *wordLabel;
@property (retain, nonatomic) IBOutlet UIView *holderView;

- (id)initWithPBDraw:(PBDraw *)pbDraw;

- (IBAction)clickBackButton:(id)sender;

@end
