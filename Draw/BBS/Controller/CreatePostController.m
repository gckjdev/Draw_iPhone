//
//  CreatePostController.m
//  Draw
//
//  Created by gamy on 12-11-16.
//
//

#import "CreatePostController.h"
#import "BBSService.h"
#import "BBSModelExt.h"
#import "UIImageExt.h"
#import "OfflineDrawViewController.h"
#import "ShareImageManager.h"
#import "BBSPopupSelectionView.h"
#import "GameNetworkConstants.h"
#import "AccountService.h"
#import <QuartzCore/QuartzCore.h>
#import "PPConfigManager.h"
#import "WordFilterService.h"
#import "Group.pb.h"
#import "GroupPermission.h"
#import "UIViewController+BGImage.h"
#import "UserFeedController.h"

@interface CreatePostController ()
{
    PBBBSBoard *_bbsBoard;
    
    PBBBSAction *_sourceAction;
//    PBBBSPost *_sourcePost;

    //post info
    NSString *_postId;
    NSString *_postUid;
    NSString *_postText;
    
    UIImage *_image;
    UIImage *_drawImage;
    NSString *_text;
    NSMutableArray *_drawActionList;
    ChangeAvatar *_imagePicker;
    NSInteger _bonus;
    
    BBSManager *_bbsManager;
    
    
    BOOL canCommit;
}
@property(nonatomic, retain)PBGroup *group;
@property(nonatomic, retain)PBBBSBoard *bbsBoard;
@property(nonatomic, retain)ChangeAvatar *imagePicker;
@property(nonatomic, retain)UIImage *image;
@property(nonatomic, retain)UIImage *drawImage;
@property(nonatomic, retain)NSMutableArray *drawActionList;
@property(nonatomic, retain)NSString *text;
@property(nonatomic, retain)PBBBSPost *post;
@property(nonatomic, assign)NSInteger bonus;

@property(nonatomic, retain) PBBBSAction *sourceAction;
//@property(nonatomic, retain) PBBBSPost *sourcePost;

@property(nonatomic, retain) NSString *postId;
@property(nonatomic, retain) NSString *postUid;
@property(nonatomic, retain) NSString *postText;
@property(nonatomic, assign) CGSize canvasSize;

// for select opus
@property(nonatomic, retain) NSString *opusId;
@property(nonatomic, assign) int opusCategory;


@end

#define BUTTON_CORNER_RADIUS_INNER ISIPAD ? 4 : 2

@implementation CreatePostController
@synthesize bbsBoard = _bbsBoard;

@synthesize image = _image;
@synthesize drawImage = _drawImage;
@synthesize drawActionList = _drawActionList;
@synthesize textView = _textView;
@synthesize imagePicker = _imagePicker;
@synthesize text = _text;
@synthesize bonus = _bonus;
@synthesize sourceAction = _sourceAction;

@synthesize postText = _postText;
@synthesize postId = _postId;
@synthesize postUid = _postUid;
@synthesize delegate = _delegate;

- (void)dealloc
{
    PPRelease(_post);
    PPRelease(_group);
    PPRelease(_image);
    PPRelease(_drawImage);
    PPRelease(_drawActionList);
    PPRelease(_bbsBoard);
    PPRelease(_textView);
    PPRelease(_imagePicker);
    PPRelease(_text);
    PPRelease(_graffitiButton);
    PPRelease(_imageButton);
    PPRelease(_rewardButton);
    PPRelease(_sourceAction);
    PPRelease(_postUid);
    PPRelease(_postId);
    PPRelease(_postText);

    PPRelease(_bgImageView);
    PPRelease(_panel);
    PPRelease(_titleLabel);
    PPRelease(_backButton);
    PPRelease(_submitButton);
    PPRelease(_inputBG);
    
    [_isPrivate release];
    [super dealloc];
}
- (id)initWithBoard:(PBBBSBoard *)board
{
    self = [super init];
    if (self) {
        self.bbsBoard = board;
        self.bonus = 0;
        self.forGroup = NO;
    }
    return self;
}
- (id)initWithGroup:(PBGroup *)group
{
    self = [super init];
    if (self) {
        self.group = group;
        self.bonus = 0;
        self.forGroup = YES;
    }
    return self;
}

- (BBSService *)service
{
    if (self.forGroup) {
        return [BBSService groupTopicService];
    }
    return [BBSService defaultService];
}

- (NSString *)boardId
{
    if (self.forGroup) {
        return _group.groupId;
    }
    return _bbsBoard.boardId;
}

+ (CreatePostController *)enterControllerWithBoard:(PBBBSBoard *)board
                                    fromController:(UIViewController *)fromController
{
    CreatePostController *cp = [[[CreatePostController alloc] initWithBoard:board] autorelease];
    [fromController presentModalViewController:cp animated:YES];
    return cp;
}

+ (CreatePostController *)enterControllerWithGroup:(PBGroup *)group
                                    fromController:(UIViewController *)fromController
{
    CreatePostController *cp = [[CreatePostController alloc] initWithGroup:group];
    [fromController presentModalViewController:cp animated:YES];
    return [cp autorelease];

}


+ (CreatePostController *)enterControllerWithSourecePost:(PBBBSPost *)post
                                            sourceAction:(PBBBSAction *)action
                                          fromController:(UIViewController *)fromController
{
    CreatePostController *cp = [[[CreatePostController alloc] init] autorelease];
    cp.sourceAction = action;

    cp.postId = post.postId;
    cp.postUid = post.createUser.userId;
    cp.postText = post.content.text;
    
    [fromController presentModalViewController:cp animated:YES];
    return cp;
}

+ (CreatePostController *)enterControllerWithPost:(PBBBSPost *)post
                                         forGroup:(BOOL)forGroup
                                   fromController:(UIViewController *)fromController
{
    CreatePostController *cp = [[[CreatePostController alloc] init] autorelease];
    cp.post = post;
    cp.postId = post.postId;
    cp.postUid = post.createUser.userId;
    cp.postText = post.content.text;
    cp.forGroup = forGroup;
    cp.forEditing = YES;
    [fromController presentModalViewController:cp animated:YES];
    return cp;
}


+ (CreatePostController *)enterControllerWithSourecePostId:(NSString *)postId
                                                   postUid:(NSString *)postUid
                                                  postText:(NSString *)postText
                                              sourceAction:(PBBBSAction *)action
                                            fromController:(UIViewController *)fromController
{
    CreatePostController *cp = [[[CreatePostController alloc] init] autorelease];
    cp.sourceAction = action;
    
    cp.postId = postId;
    cp.postUid = postUid;
    cp.postText = postText;
    
    [fromController presentModalViewController:cp animated:YES];
    return cp;    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _bbsManager = [BBSManager defaultManager];
        canCommit = YES;
    }
    return self;
}

- (void)roundToolButton:(UIButton *)button cornerRadius:(CGFloat)radius
{
    button.layer.cornerRadius = radius;
    button.layer.masksToBounds = YES;
}

- (void)updateToolButtons
{
    BBSImageManager *imageManager = [BBSImageManager defaultManager];
    if (self.drawImage) {
        [self.graffitiButton setImage:self.drawImage
                             forState:UIControlStateNormal];
        [self roundToolButton:self.graffitiButton cornerRadius:BUTTON_CORNER_RADIUS_INNER];

    }else{
        [self.graffitiButton setImage:[imageManager bbsCreateDrawEnable]
                             forState:UIControlStateNormal];
        [self roundToolButton:self.graffitiButton cornerRadius:0];
    }
    if (self.image) {
        [self.imageButton setImage:self.image
                          forState:UIControlStateNormal];
        [self roundToolButton:self.imageButton cornerRadius:BUTTON_CORNER_RADIUS_INNER];
        [self.imageButton setBackgroundColor:[UIColor whiteColor]];
    }else{
        [self.imageButton setImage:[imageManager bbsCreateImageEnable]
                          forState:UIControlStateNormal];
        [self roundToolButton:self.imageButton cornerRadius:0];
        [self.imageButton setBackgroundColor:[UIColor clearColor]];
    }
    if (self.bonus > 0) {
        [self.rewardButton setTitle:[NSString stringWithFormat:@"+%d",self.bonus]
                           forState:UIControlStateNormal];
    }else{
        [self.rewardButton setTitle:NSLS(@"kReward")
                           forState:UIControlStateNormal];        
    }
    
    if([self isForEditing]){
        self.rewardButton.hidden = YES;
        self.imageButton.hidden = YES;
        self.graffitiButton.hidden = YES;
    }
}

- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
{
    if (ISIPAD) {
        return;
    }
    PPDebug(@"<keyboardWillShowWithRect> keyboardRect = %@",NSStringFromCGRect(keyboardRect));
    CGRect frame = self.panel.frame;
    CGSize size = CGSizeMake(frame.size.width, keyboardRect.origin.y);
    frame.size = size;
    
    PPDebug(@"<keyboardWillShowWithRect> panel Rect = %@",NSStringFromCGRect(frame));

    [UIView animateWithDuration:0.3 animations:^{
        self.panel.frame = frame;
    }];

}


- (void)initViews
{
    NSString* initText = nil;
    if ([self isForEditing]) {
        initText = self.postText;
    }else{
        initText = [BBSManager lastInputText];
    }
//    if ([self.postText length] == 0){
//        initText = [BBSManager lastInputText];
//    }
//    else{
//        initText = self.postText;
//    }
    [self.textView setText:initText];
    
    BBSImageManager *imageManager = [BBSImageManager defaultManager];
    BBSColorManager *colorManager = [BBSColorManager defaultManager];
    BBSFontManager *fontManager = [BBSFontManager defaultManager];
    
    [self.bgImageView setImage:[imageManager bbsBGImage]];
    [self.graffitiButton setImage:[imageManager bbsCreateDrawEnable] forState:UIControlStateNormal];
    [self.imageButton setImage:[imageManager bbsCreateImageEnable] forState:UIControlStateNormal];
//    [self.backButton setImage:[imageManager bbsBackImage] forState:UIControlStateNormal];
    [self.inputBG setImage:[imageManager bbsCreateInputBg]];
    [self.textView setTextColor:[UIColor blackColor]];
    [self.textView setFont:[fontManager postContentFont]];
    
//    [BBSViewManager updateLable:self.titleLabel
//                        bgColor:[UIColor clearColor]
//                           font:[fontManager bbsTitleFont]
//                      textColor:[colorManager bbsTitleColor]
//                           text:NSLS(@"kComment")];
    
    
    [BBSViewManager updateButton:self.rewardButton
                         bgColor:[UIColor clearColor]
                         bgImage:[imageManager bbsCreateRewardBg]
                           image:[imageManager bbsCreateRewardOptionBG]
                            font:[fontManager creationDefaulFont]
                      titleColor:[colorManager creationDefaultColor]
                           title:NSLS(@"kReward")
                        forState:UIControlStateNormal];
    
    [BBSViewManager updateButton:self.submitButton
                         bgColor:[UIColor clearColor]
                         bgImage:[imageManager bbsCreateSubmitBg]
                           image:nil
                            font:[fontManager creationDefaulFont]
                      titleColor:[colorManager creationDefaultColor]
                           title:NSLS(@"kPublish")
                        forState:UIControlStateNormal];

    NSString *titleName = nil;
    self.rewardButton.hidden = YES;
    
    if ([self isForCreatingAction]) {
        titleName = _sourceAction != nil ? NSLS(@"kReply") :  NSLS(@"kComment");
    }else if([self isForEditing]){
        titleName = [self isForGroup] ? NSLS(@"kEditTopic") : NSLS(@"kEditPost");
    }else{
        self.rewardButton.hidden = NO;
        titleName = [self isForGroup] ? NSLS(@"kCreateTopic") : NSLS(@"kCreatePost");
    }
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:titleName];
    [BBSViewManager updateDefaultBackButton:self.backButton];

    GroupPermissionManager *gpm = [GroupPermissionManager myManagerWithGroupId:_group.groupId];    
    [self.isPrivate setHidden:!(self.forGroup && [gpm canCreatePrivateTopic])];
    [self.isPrivate setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    [self.isPrivate setTitle:NSLS(@"kPrivatePostForGroup") forState:UIControlStateNormal];
    
    [self.isPrivate setTitleColor:COLOR_BROWN forState:UIControlStateHighlighted];
    [self.isPrivate setTitle:NSLS(@"kPrivatePostForGroup") forState:UIControlStateHighlighted];
    [self.isPrivate setTitleColor:COLOR_BROWN forState:UIControlStateSelected];
    [self.isPrivate setTitle:NSLS(@"kPrivatePostForGroup") forState:UIControlStateSelected];

}

- (void)customBbsBg
{
    [self setDefaultBGImage];
//    UIImage* image = [[UserManager defaultManager] bbsBackground];
//    if (image) {
//        [self.bgImageView setImage:image];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self updateToolButtons];
    [self.textView becomeFirstResponder];
    [self customBbsBg];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [self setGraffitiButton:nil];
    [self setImageButton:nil];
    [self setRewardButton:nil];
    [self setBgImageView:nil];
    [self setPanel:nil];
    [self setTitleLabel:nil];
    [self setBackButton:nil];
    [self setSubmitButton:nil];
    [self setInputBG:nil];
    [self setIsPrivate:nil];
    [super viewDidUnload];
}

- (BOOL)isForCreatingAction
{
    if(self.isForEditing){
        return NO;
    }
    return [self.postId length] != 0;
}

#define IMAGE_SIZE_MAX 1500

- (IBAction)clickBackButton:(id)sender {
    if ([_textView.text length] > 0) {
        [self showQuitAlert];
        return;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clickSubmitButton:(id)sender {

    self.text = self.textView.text;
    if ([[WordFilterService defaultService] checkForbiddenWord:self.text]){
        return;
    }

    //if has source post, then send an action, or create a new post
    if (!canCommit) {
        PPDebug(@"Cannot Commit!!! it is sending!!!");
        return;
    }
    canCommit = NO;
    
    
    [self showActivityWithText:NSLS(@"kSending") center:self.textView.center];
    if ([self isForCreatingAction]) {
        
        [[self service] createActionWithPostId:self.postId
                                        PostUid:self.postUid
                                       postText:self.postText
                                   sourceAction:self.sourceAction
                                     actionType:ActionTypeComment
                                           text:self.text
                                          image:self.image
                                 drawActionList:self.drawActionList
                                      drawImage:self.drawImage
                                        opusId:self.opusId
                                  opusCategory:self.opusCategory
                                       boardId:self.post.boardId
                                       delegate:self
                                     canvasSize:self.canvasSize];
        
    }else if([self isForEditing]){
        [[self service] editPost:self.post text:self.text callback:^(NSInteger resultCode, PBBBSPost *editedPost) {
            [self hideActivity];
            [self alertError:resultCode];
            if (resultCode == 0) {
                self.post = editedPost;
                if ([self.delegate respondsToSelector:@selector(didController:editPost:)]) {
                    [self.delegate didController:self editPost:editedPost];
                }
                [self dismissModalViewControllerAnimated:YES];
            }
        }];
    }else{
    
        [[self service] createPostWithBoardId:[self boardId]
                                         text:self.text
                                        image:self.image
                               drawActionList:self.drawActionList
                                    drawImage:self.drawImage
                                       opusId:self.opusId
                                 opusCategory:self.opusCategory
                                        bonus:self.bonus
                                     delegate:self
                                   canvasSize:self.canvasSize
                                    isPrivate:[self isPrivatePost]];
    }

}

- (BOOL)isPrivatePost
{
    return self.isPrivate.isSelected;
}

- (IBAction)clickPrivateButton:(id)sender {
    self.isPrivate.selected = !self.isPrivate.selected;
}

#define ALERT_CLEAR_IMAGE_TAG 201212041
#define ALERT_CLEAR_DRAW_TAG  201212042
#define ALERT_QUIT_TAG        201306271

- (void)showClearImageAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS(@"kWarning")
                                                    message:NSLS(@"kClearImageData")
                                                   delegate:self
                                          cancelButtonTitle:NSLS(@"kCancel")
                                          otherButtonTitles:NSLS(@"kOK"),nil];
    
    alert.tag = ALERT_CLEAR_IMAGE_TAG;
    [alert show];
    [alert release];
}

- (void)showClearDrawDataAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS(@"kWarning")
                                                    message:NSLS(@"kClearDrawData")
                                                   delegate:self
                                          cancelButtonTitle:NSLS(@"kCancel")
                                          otherButtonTitles:NSLS(@"kOK"),nil];
    
    alert.tag = ALERT_CLEAR_DRAW_TAG;
    [alert show];
    [alert release];
}


- (void)showQuitAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS(@"kWarning")
                                                        message:NSLS(@"kBBSQuitTips")
                                                       delegate:self
                                              cancelButtonTitle:NSLS(@"kCancel")
                                              otherButtonTitles:NSLS(@"kOK"), nil];
    alert.tag = ALERT_QUIT_TAG;
    [alert show];
    [alert release];
}


- (void)startToDraw
{
    OfflineDrawViewController *odc = [[[OfflineDrawViewController alloc]
                                      initWithTargetType:TypeGraffiti delegate:self] autorelease];
    [self presentModalViewController:odc animated:YES];
}

- (void)selectOpus
{
    PPDebug(@"select opus invoke");
    
    [UserFeedController selectOpus:self callback:^(int resultCode, NSString *opusId, UIImage *opusImage, int opusCategory) {
        if (resultCode == 0 && [opusId length] > 0){
            
            self.opusId = opusId;
            self.opusCategory = opusCategory;
            
            self.image = opusImage;
            [self updateToolButtons];
            [self.textView becomeFirstResponder];
        }
        else{
            
        }
    }];
}

- (void)startToSelectImage
{
    self.imagePicker = [[[ChangeAvatar alloc] init] autorelease];
    [self.imagePicker setAutoRoundRect:NO];
//    [self.imagePicker showSelectionView:self
//                               delegate:self
//                     selectedImageBlock:nil
//                     didSetDefaultBlock:  
//                                  title:nil
//                        hasRemoveOption:NO
//                           canTakePhoto:YES
//                      userOriginalImage:YES];

    __block CreatePostController* bself = self;
    
    [self.imagePicker showSelectionView:self
                                  title:NSLS(@"kSelectImageOrOpus")
                            otherTitles:@[NSLS(@"kSelectOpus")]
                                handler:^(NSInteger index) {
                                    [bself selectOpus];
                                }
                     selectImageHanlder:^(UIImage *image) {
                         [self didImageSelected:image];
                                }
                           canTakePhoto:YES
                      userOriginalImage:YES];
    
    [self.textView resignFirstResponder];
}
- (IBAction)clickGraffitiButton:(id)sender {
    if (self.image) {
        [self showClearImageAlert];
    }else{
        [self startToDraw];
    }
}

- (IBAction)clickImageButton:(id)sender {
    if (self.drawActionList) {
        [self showClearDrawDataAlert];
    }else{
        [self startToSelectImage];
    }
}

#pragma mark -alert view delegate

- (void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (theAlertView.tag == ALERT_CLEAR_IMAGE_TAG) {
            [self startToDraw];
        }else if(theAlertView.tag == ALERT_CLEAR_DRAW_TAG){
            [self startToSelectImage];
        }else if(theAlertView.tag == ALERT_QUIT_TAG){
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}
#define SELECTION_VIEW_TAG 100
#define SELECTION_VIEW_OFFSET ([DeviceDetection isIPAD] ? 30 : 7)
#define BONUS_LIST_END (-1)

//int *getRewardBonusList()
//{
//    static int bonus[] = {0,100,300,500,1000,-1};
//    return bonus;
//}

- (IBAction)clickRewardButton:(id)sender {
    BBSPopupSelectionView *selectionView = (BBSPopupSelectionView *)[self.view
                                                                     viewWithTag:SELECTION_VIEW_TAG];
    if (selectionView) {
        [selectionView removeFromSuperview];
    }else{
        NSMutableArray *titles = [NSMutableArray arrayWithObjects:NSLS(@"kNone"),nil];
        int *value = [PPConfigManager getBBSRewardBounsList];//getRewardBonusList();
        
        for (++value; *value != BONUS_LIST_END; ++value) {
            NSString *str = [NSString stringWithFormat:@"%d",*value];
            [titles addObject:str];
        }
        selectionView = [[BBSPopupSelectionView alloc] initWithTitles:titles delegate:self];
        selectionView.tag = SELECTION_VIEW_TAG;
        CGPoint point = self.rewardButton.center;
        point.y -=  SELECTION_VIEW_OFFSET;
        [selectionView showInView:self.view showAbovePoint:point animated:YES];
        [selectionView release];
    }
}

- (void)optionView:(BBSOptionView *)optionView didSelectedButtonIndex:(NSInteger)index
{
    NSInteger bonus = [PPConfigManager getBBSRewardBounsList][index];
    if ([[AccountService defaultService] hasEnoughBalance:bonus currency:PBGameCurrencyCoin]) {

        self.bonus = bonus;
        [self updateToolButtons];
    }else{
        NSString *msg = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughTips"),bonus];
        if(ISIPAD){
            POSTMSG(msg);
        }else{
            [UIUtils alert:msg];
        }
    }
}

- (void)didImageSelected:(UIImage*)image
{
    self.drawActionList = nil;
    self.drawImage = nil;
    self.opusId = nil;

    self.image = image;
    [self updateToolButtons];
    [self.textView becomeFirstResponder];
}

- (void)alertError:(NSInteger)errorCode
{
    if (errorCode == 0) {
        return;
    }
    NSString *msg = nil;
    switch (errorCode) {
        case ERROR_BBS_TEXT_TOO_SHORT:
            msg = [NSString stringWithFormat:NSLS(@"kTextTooShot"),
                   [[BBSManager defaultManager] textMinLength]];
            break;
        case ERROR_BBS_TEXT_TOO_LONG:
            msg = [NSString stringWithFormat:NSLS(@"kTextTooLong"),
                   [[BBSManager defaultManager] textMaxLength]];
            break;
        case ERROR_BBS_TEXT_TOO_FREQUENT:
            msg = [NSString stringWithFormat:NSLS(@"kTextTooFrequent"),
                   [[BBSManager defaultManager] creationFrequency]];
            break;
        case ERROR_BBS_POST_SUPPORT_TIMES_LIMIT:
            msg = [NSString stringWithFormat:NSLS(@"kSupportTimesLimit"),
                   [[BBSManager defaultManager] supportMaxTimes]];
            break;
        case ERROR_BBS_TEXT_REPEAT:
            msg = NSLS(@"kContentRepeatedError");
            break;
        case ERROR_BBS_BOARD_FORIDDEN:
            msg = NSLS(@"kUserBoardForbidden");
            break;
            
        default:
            msg = NSLS(@"kNetworkError");
            break;
    }
    if(ISIPAD){        
        POSTMSG(msg);
    }else{
        POSTMSG(msg);
//        [UIUtils alert:msg];
    }

}

- (void)didCreatePost:(PBBBSPost *)post
           resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    canCommit = YES;
    if (resultCode == 0) {
        [BBSManager saveLastInputText:nil];
        PPDebug(@"<didCreatePost>create post successful!");
        if (self.delegate && [self.delegate
                              respondsToSelector:@selector(didController:CreateNewPost:)]) {
            [self.delegate didController:self CreateNewPost:post];
        }
        if (self.bonus > 0) {
            [[AccountService defaultService] deductCoin:self.bonus source:BBSReward];
        }
        [self dismissModalViewControllerAnimated:YES];
    }else{
        PPDebug(@"<didCreatePost>create post fail.result code = %d",resultCode);
        [self alertError:resultCode];
    }

}

- (void)didCreateAction:(PBBBSAction *)action
                 atPost:(NSString *)postId
            replyAction:(PBBBSAction *)replyAction
             resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    canCommit = YES;    
    if (resultCode == 0) {
        [BBSManager saveLastInputText:nil];
        PPDebug(@"<didCreateAction>create action successful!");
        if (self.delegate && [self.delegate
                              respondsToSelector:@selector(didController:CreateNewAction:)]) {
            [self.delegate didController:self CreateNewAction:action];
        }
        [self dismissModalViewControllerAnimated:YES];
    }else{
        PPDebug(@"<didCreateAction>create action fail.result code = %d",resultCode);
        [self alertError:resultCode];
    }
}


#pragma mark - offline create draw delegate

- (void)didControllerClickBack:(OfflineDrawViewController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)didController:(OfflineDrawViewController *)controller
     submitActionList:(NSMutableArray *)drawActionList
           canvasSize:(CGSize)size
            drawImage:(UIImage *)drawImage
{
    [controller dismissModalViewControllerAnimated:YES];
    self.image = nil;
    self.drawImage = drawImage;
    self.drawActionList = drawActionList;
    self.canvasSize = size;
    [self updateToolButtons];
}
/*
#pragma mark textview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([textView.text length] != 0) {
            [self clickSubmitButton:self.submitButton];
        }
        return NO;
    }
    return YES;
}
*/

- (void)textViewDidChange:(UITextView *)textView
{
    [BBSManager saveLastInputText:textView.text];
}

@end
