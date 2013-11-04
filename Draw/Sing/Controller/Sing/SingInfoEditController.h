//
//  SingInfoEditController.h
//  Draw
//
//  Created by 王 小涛 on 13-10-22.
//
//

#import "PPViewController.h"
#import "UIPlaceholderTextView.h"
#import "Opus.h"

#define KEY_NOTIFICATION_SING_INFO_CHANGE @"KEY_NOTIFICATION_SING_INFO_CHANGE"

@interface SingInfoEditController : PPViewController

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UIPlaceholderTextView *descTextView;
@property (retain, nonatomic) IBOutlet UILabel *tagLabel;
@property (retain, nonatomic) IBOutlet UIButton *comfirmButton;
@property (retain, nonatomic) IBOutlet UIView *tagsHolderView;


- (id)initWithOpus:(Opus *)opus;

@end
