//
//  AskPsController.h
//  Draw
//
//  Created by haodong on 13-6-8.
//
//

#import "PPViewController.h"
#import "ChangeAvatar.h"

@interface AskPsController : PPViewController<ChangeAvatarDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *contentHolderView;
@property (retain, nonatomic) IBOutlet UIButton *pictureButton;
@property (retain, nonatomic) IBOutlet UITextField *descTextField;
@property (retain, nonatomic) IBOutlet UITextField *coinsPerUserTextField;
@property (retain, nonatomic) IBOutlet UITextField *coinsMaxTotalTextField;
@property (retain, nonatomic) IBOutlet UITextField *ingotBestUser;

- (IBAction)clickRequirementButton:(id)sender;

@end
