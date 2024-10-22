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
#import "BBSPopupSelectionView.h"

@class PBBBSBoard;
@class PBBBSAction;
@class PBBBSPost;
@class CreatePostController;
@class PBGroup;

@protocol CreatePostControllerDelegate <NSObject>

@optional
- (void)didController:(CreatePostController *)controller
        CreateNewPost:(PBBBSPost *)post;

- (void)didController:(CreatePostController *)controller
        editPost:(PBBBSPost *)post;

- (void)didController:(CreatePostController *)controller
      CreateNewAction:(PBBBSAction *)action;
@end


@interface CreatePostController : PPViewController<BBSServiceDelegate, ChangeAvatarDelegate, OfflineDrawDelegate, BBSOptionViewDelegate, UITextViewDelegate>
{
    
}

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *graffitiButton;
@property (retain, nonatomic) IBOutlet UIButton *imageButton;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIButton *rewardButton;
@property (retain, nonatomic) IBOutlet UIView *panel;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIImageView *inputBG;
@property (assign, nonatomic, getter = isForGroup) BOOL forGroup;
@property (assign, nonatomic, getter = isForEditing) BOOL forEditing;

@property (retain, nonatomic) IBOutlet UIButton *isPrivate;
- (IBAction)clickPrivateButton:(id)sender;
@property (assign, nonatomic) id<CreatePostControllerDelegate>delegate;

//- (id)initWithBoard:(PBBBSBoard *)board;
//create post
+ (CreatePostController *)enterControllerWithBoard:(PBBBSBoard *)board
                                    fromController:(UIViewController *)fromController;

//create topic
+ (CreatePostController *)enterControllerWithGroup:(PBGroup *)group
                                    fromController:(UIViewController *)fromController;

//reply
+ (CreatePostController *)enterControllerWithSourecePost:(PBBBSPost *)post
                                            sourceAction:(PBBBSAction *)action
                                          fromController:(UIViewController *)fromController;

//reply
+ (CreatePostController *)enterControllerWithSourecePostId:(NSString *)postId
                                                   postUid:(NSString *)postUid
                                                  postText:(NSString *)postText
                                              sourceAction:(PBBBSAction *)action
                                          fromController:(UIViewController *)fromController;
//edit
+ (CreatePostController *)enterControllerWithPost:(PBBBSPost *)post
                                         forGroup:(BOOL)forGroup
                                   fromController:(UIViewController *)fromController;

- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickSubmitButton:(id)sender;
- (IBAction)clickGraffitiButton:(id)sender;
- (IBAction)clickImageButton:(id)sender;
- (IBAction)clickRewardButton:(id)sender;

@end
