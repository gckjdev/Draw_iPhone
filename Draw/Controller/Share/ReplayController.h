//
//  ReplayController.h
//  Draw
//
//  Created by  on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "ShowDrawView.h"
#import "ShareAction.h"

@class MyPaint;

@interface ReplayController : PPViewController<ShowDrawViewDelegate>

@property (nonatomic, retain) MyPaint *paint;
@property (nonatomic, retain) ShareAction *shareAction;
@property (nonatomic, assign) BOOL replayForCreateGif;
@property (nonatomic, retain) NSString *tempGIFFilePath;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIView *showHolderView;
@property (retain, nonatomic) IBOutlet UILabel *wordLabel;


- (id)initWithPaint:(MyPaint*)paint;
- (IBAction)clickShareButton:(id)sender;
- (IBAction)clickBackButton:(id)sender;

@end
