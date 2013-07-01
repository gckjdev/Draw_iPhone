//
//  AskPsController.h
//  Draw
//
//  Created by haodong on 13-6-8.
//
//

#import "PPViewController.h"
#import "ChangeAvatar.h"
#import "OpusService.h"

@interface AskPsController : PPViewController<ChangeAvatarDelegate, UITextFieldDelegate, OpusServiceDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *contentHolderView;
@property (retain, nonatomic) IBOutlet UIButton *pictureButton;
@property (retain, nonatomic) IBOutlet UITextField *descTextField;
@property (retain, nonatomic) IBOutlet UITextField *coinsPerUserTextField;
@property (retain, nonatomic) IBOutlet UITextField *coinsMaxTotalTextField;
@property (retain, nonatomic) IBOutlet UITextField *ingotBestUserTextField;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *requirementLabel;
@property (retain, nonatomic) IBOutlet UILabel *awardLabel;
@property (retain, nonatomic) IBOutlet UILabel *coinsPerUserLabel;
@property (retain, nonatomic) IBOutlet UILabel *coinsMaxTotalLabel;
@property (retain, nonatomic) IBOutlet UILabel *ingotBestUserLabel;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *chargeButton;

- (IBAction)clickRequirementButton:(id)sender;
- (IBAction)clickPictureButton:(id)sender;
- (IBAction)clickSubmitButton:(id)sender;
- (IBAction)touchDownBackground:(id)sender;

@end
