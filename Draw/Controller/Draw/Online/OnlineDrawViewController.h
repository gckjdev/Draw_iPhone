//
//  DrawViewController.h
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawView.h"
#import "DrawGameService.h"
#import "CommonDialog.h"
#import "SuperGameViewController.h"
#import "LevelService.h"
#import "DrawToolPanel.h"
#import "CommonItemInfoView.h"

@class Word;
@class ShareImageManager;

@interface OnlineDrawViewController : SuperGameViewController<DrawViewDelegate,CommonDialogDelegate,LevelServiceDelegate, DrawToolPanelDelegate, CommonItemInfoViewDelegate> {
    DrawView *drawView;
    PenView *_willBuyPen;
}

- (IBAction)clickChangeRoomButton:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *wordLabel;
@property (retain, nonatomic) GameMessage *gameCompleteMessage;


+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController;

- (id)initWithWord:(Word *)word lang:(LanguageType)lang;

@end

