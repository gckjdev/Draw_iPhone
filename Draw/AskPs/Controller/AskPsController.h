//
//  AskPsController.h
//  Draw
//
//  Created by haodong on 13-6-8.
//
//

#import "PPViewController.h"
#import "ChangeAvatar.h"

@interface AskPsController : PPViewController<ChangeAvatarDelegate>
@property (retain, nonatomic) IBOutlet UIButton *pictureButton;
@property (retain, nonatomic) IBOutlet UITextField *descTextField;

- (IBAction)clickRequirementButton:(id)sender;

@end
