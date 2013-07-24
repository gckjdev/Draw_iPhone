//
//  GetNewNumberViewController.h
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

@class LoginByNumberController;
@class ShowNumberController;

@interface GetNewNumberViewController : PPViewController

@property (retain, nonatomic) IBOutlet UIButton *takeNumberButton;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;

@property (retain, nonatomic) LoginByNumberController *loginController;
@property (retain, nonatomic) ShowNumberController *showNumberController;

- (IBAction)clickLogin:(id)sender;
- (IBAction)clickTakeNumber:(id)sender;

@end
