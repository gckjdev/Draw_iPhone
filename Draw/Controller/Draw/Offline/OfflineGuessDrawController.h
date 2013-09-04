//
//  ShowDrawController.h
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"
#import "PPViewController.h"
#import "CommonMessageCenter.h"
#import "StableView.h"
#import "CanvasRect.h"
#import "DrawFeed.h"
#import "WordInputView.h"
#import "CommonDialog.h"

@interface OfflineGuessDrawController : PPViewController<CommonDialogDelegate, WordInputViewDelegate>
{

}
@property (retain, nonatomic) DrawFeed *feed;
@property (retain, nonatomic) IBOutlet WordInputView *wordInputView;

- (IBAction)bomb:(id)sender;

- (id)initWithFeed:(DrawFeed *)feed;

+ (OfflineGuessDrawController *)startOfflineGuess:(DrawFeed *)feed
                                   fromController:(UIViewController *)fromController;


@end


