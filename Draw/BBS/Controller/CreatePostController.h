//
//  CreatePostController.h
//  Draw
//
//  Created by gamy on 12-11-16.
//
//

#import "PPViewController.h"
#import "BBSService.h"
#import "ChangeAvatar.h"
#import "OfflineDrawViewController.h"

@class PBBBSBoard;
@class PBBBSAction;
@class PBBBSPost;

@interface CreatePostController : PPViewController<BBSServiceDelegate, ChangeAvatarDelegate, OfflineDrawDelegate, UIActionSheetDelegate>
{
    
}

@property (retain, nonatomic) IBOutlet UIButton *graffitiButton;
@property (retain, nonatomic) IBOutlet UIButton *imageButton;
@property (retain, nonatomic) IBOutlet UITextView *textView;

@property (retain, nonatomic) IBOutlet UIButton *rewardButton;
//- (id)initWithBoard:(PBBBSBoard *)board;
+ (CreatePostController *)enterControllerWithBoard:(PBBBSBoard *)board
                                    fromController:(UIViewController *)fromController;

+ (CreatePostController *)enterControllerWithSourecePost:(PBBBSPost *)post
                                            sourceAction:(PBBBSAction *)action
                                          fromController:(UIViewController *)fromController;

- (IBAction)clickBackButton:(id)sender;

- (IBAction)clickSubmitButton:(id)sender;
- (IBAction)clickGraffitiButton:(id)sender;
- (IBAction)clickImageButton:(id)sender;
- (IBAction)clickRewardButton:(id)sender;

@end
