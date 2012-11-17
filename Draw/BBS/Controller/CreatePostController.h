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
@interface CreatePostController : PPViewController<BBSServiceDelegate, ChangeAvatarDelegate, OfflineDrawDelegate>
{
}

@property (retain, nonatomic) IBOutlet UIButton *graffitiButton;
@property (retain, nonatomic) IBOutlet UIButton *imageButton;
@property (retain, nonatomic) IBOutlet UITextView *textView;

- (id)initWithBoard:(PBBBSBoard *)board;
+ (CreatePostController *)enterControllerWithBoard:(PBBBSBoard *)board
                                    fromController:(UIViewController *)fromController;


- (IBAction)clickBackButton:(id)sender;

- (IBAction)clickSubmitButton:(id)sender;
- (IBAction)clickGraffitiButton:(id)sender;
- (IBAction)clickImageButton:(id)sender;

@end
