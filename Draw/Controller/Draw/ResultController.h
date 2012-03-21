//
//  ResultController.h
//  Draw
//
//  Created by  on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultController : UIViewController
{
    UIImage * _image;
}
@property (retain, nonatomic) IBOutlet UIButton *upButton;
@property (retain, nonatomic) IBOutlet UIButton *downButton;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *exitButton;

- (IBAction)clickUpButton:(id)sender;

- (IBAction)clickDownButton:(id)sender;
- (IBAction)clickContinueButton:(id)sender;
- (IBAction)clickSaveButton:(id)sender;
- (IBAction)clickExitButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *drawImage;

- (id)initWithImage:(UIImage *)image;

@end
