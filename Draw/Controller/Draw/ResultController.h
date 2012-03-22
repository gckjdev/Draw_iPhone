//
//  ResultController.h
//  Draw
//
//  Created by  on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawGameService.h"


@interface ResultController : UIViewController<DrawGameServiceDelegate>
{
    UIImage * _image;
    BOOL didGameStarted;
    NSTimer *continueTimer;
    NSInteger retainCount;
    DrawGameService *drawGameService;
    BOOL hasRankButtons;
}
@property (retain, nonatomic) IBOutlet UIButton *upButton;
@property (retain, nonatomic) IBOutlet UIButton *downButton;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *exitButton;
@property (retain, nonatomic) NSString *wordText;
@property (assign, nonatomic) NSInteger score;
@property (retain, nonatomic) IBOutlet UILabel *wordLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;


- (IBAction)clickUpButton:(id)sender;
- (IBAction)clickDownButton:(id)sender;
- (IBAction)clickContinueButton:(id)sender;
- (IBAction)clickSaveButton:(id)sender;
- (IBAction)clickExitButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *drawImage;

- (id)initWithImage:(UIImage *)image wordText:(NSString *)aWordText score:(NSInteger)aScore hasRankButtons:(BOOL)has;

@end
