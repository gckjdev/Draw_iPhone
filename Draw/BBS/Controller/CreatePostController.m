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
}
@property(nonatomic, retain)PBBBSBoard *bbsBoard;
@property(nonatomic, retain)ChangeAvatar *imagePicker;
@property(nonatomic, retain)UIImage *image;
@property(nonatomic, retain)UIImage *drawImage;
@property(nonatomic, retain)NSMutableArray *drawActionList;
@property(nonatomic, retain)NSString *text;
@property(nonatomic, assign)NSInteger bonus;

@property(nonatomic, retain) PBBBSAction *sourceAction;
//@property(nonatomic, retain) PBBBSPost *sourcePost;

@property(nonatomic, retain) NSString *postId;
@property(nonatomic, retain) NSString *postUid;
@property(nonatomic, retain) NSString *postText;



@end

//#define ISIPAD [DeviceDetection isIPAD]
#define BUTTON_CORNER_RADIUS ISIPAD ? 4 : 2

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
    
    [super dealloc];
}
- (id)initWithBoard:(PBBBSBoard *)board
{
    self = [super init];
    if (self) {
        self.bbsBoard = board;
        self.bonus = 0;
    }
    return self;
}
+ (CreatePostController *)enterControllerWithBoard:(PBBBSBoard *)board
                                    fromController:(UIViewController *)fromController
{
    CreatePostController *cp = [[[CreatePostController alloc] initWithBoard:board] autorelease];
    [fromController presentModalViewController:cp animated:YES];
    return cp;
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
        [self roundToolButton:self.graffitiButton cornerRadius:BUTTON_CORNER_RADIUS];

    }else{
        [self.graffitiButton setImage:[imageManager bbsCreateDrawEnable]
                             forState:UIControlStateNormal];
        [self roundToolButton:self.graffitiButton cornerRadius:0];
    }
    if (self.image) {
        [self.imageButton setImage:self.image
                          forState:UIControlStateNormal];
        [self roundToolButton:self.imageButton cornerRadius:BUTTON_CORNER_RADIUS];
    }else{
        [self.imageButton setImage:[imageManager bbsCreateImageEnable]
                          forState:UIControlStateNormal];
        [self roundToolButton:self.imageButton cornerRadius:0];
    }
    if (self.bonus > 0) {
        [self.rewardButton setTitle:[NSString stringWithFormat:@"+%d",self.bonus]
                           forState:UIControlStateNormal];
    }else{
        [self.rewardButton setTitle:NSLS(@"kReward")
                           forState:UIControlStateNormal];        
    }
}

- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
{
    PPDebug(@"<keyboardWillShowWithRect> keyboardRect = %@",NSStringFromCGRect(keyboardRect));
    CGRect frame = self.panel.frame;
    CGSize size = CGSizeMake(frame.size.width, keyboardRect.origin.y);
    frame.size = size;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.panel.frame = frame;
    }];

}


- (void)initViews
{
    
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
    
    if ([self.postId length] != 0) {
        self.rewardButton.hidden = YES;
        titleName = _sourceAction != nil ? NSLS(@"kReply") :  NSLS(@"kComment");
    }else{
        self.rewardButton.hidden = NO;
        titleName = NSLS(@"kCreatePost");
    }
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:titleName];
    [BBSViewManager updateDefaultBackButton:self.backButton];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self updateToolButtons];
    [self.textView becomeFirstResponder];
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
    [super viewDidUnload];
}

#define IMAGE_SIZE_MAX 1500

- (IBAction)clickBackButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clickSubmitButton:(id)sender {

    //if has source post, then send an action, or create a new post
    self.text = self.textView.text;
    if ([self.postId length] != 0) {
        
        [[BBSService defaultService] createActionWithPostId:self.postId
                                                    PostUid:self.postUid
                                                   postText:self.postText
                                               sourceAction:self.sourceAction
                                                 actionType:ActionTypeComment
                                                       text:self.text
                                                      image:self.image
                                             drawActionList:self.drawActionList
                                                  drawImage:self.drawImage
                                                   delegate:self];
        
    }else{
        [[BBSService defaultService] createPostWithBoardId:_bbsBoard.boardId
                                                      text:self.text
                                                     image:self.image
                                            drawActionList:self.drawActionList
                                                 drawImage:self.drawImage
                                                     bonus:self.bonus
                                                  delegate:self];
    }
    [self showActivityWithText:NSLS(@"kSending")];
}

#define ALERT_CLEAR_IMAGE_TAG 201212041
#define ALERT_CLEAR_DRAW_TAG 201212042

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


- (void)startToDraw
{
    OfflineDrawViewController *odc = [[[OfflineDrawViewController alloc]
                                      initWithTargetType:TypeGraffiti delegate:self] autorelease];
    [self presentModalViewController:odc animated:YES];
}
- (void)startToSelectImage
{
    self.imagePicker = [[[ChangeAvatar alloc] init] autorelease];
    [self.imagePicker setAutoRoundRect:NO];
    [self.imagePicker setImageSize:CGSizeMake(0, 0)];
    [self.imagePicker showSelectionView:self];
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
        }
    }
}
#define SELECTION_VIEW_TAG 100
#define SELECTION_VIEW_OFFSET ([DeviceDetection isIPAD] ? 30 : 7)
- (IBAction)clickRewardButton:(id)sender {
    BBSPopupSelectionView *selectionView = (BBSPopupSelectionView *)[self.view
                                                                     viewWithTag:SELECTION_VIEW_TAG];
    if (selectionView) {
        [selectionView removeFromSuperview];
    }else{
        NSArray *titiles = [NSArray arrayWithObjects:NSLS(@"kNone"),@"100",@"200",@"300",nil];
        selectionView = [[BBSPopupSelectionView alloc] initWithTitles:titiles delegate:self];
        selectionView.tag = SELECTION_VIEW_TAG;
        CGPoint point = self.rewardButton.center;
        point.y -=  SELECTION_VIEW_OFFSET;
        [selectionView showInView:self.view showAbovePoint:point animated:YES];
        [selectionView release];
    }
}

- (void)optionView:(BBSOptionView *)optionView didSelectedButtonIndex:(NSInteger)index
{
    NSInteger bonus = index * 100;
    if ([[AccountService defaultService] hasEnoughCoins:bonus]) {
        self.bonus = index * 100;
        [self updateToolButtons];
    }else{
        NSString *msg = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughTips"),bonus];
        msg = NSLS(msg);
    }
}

- (void)didImageSelected:(UIImage*)image
{
    self.drawActionList = nil;
    self.drawImage = nil;

    if ([[image data] length] > IMAGE_SIZE_MAX) {
        NSData *data = UIImageJPEGRepresentation(image, 0.3);
        if (data) {
            self.image = [UIImage imageWithData:data];
            [self updateToolButtons];
            return;
        }
    }
    self.image = image;
    [self updateToolButtons];
}

- (void)alertError:(NSInteger)errorCode
{
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
        default:
            msg = NSLS(@"kNetworkError");
            break;
    }
    [UIUtils alert:msg];

}

- (void)didCreatePost:(PBBBSPost *)post
           resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        PPDebug(@"<didCreatePost>create post successful!");
        if (self.delegate && [self.delegate
                              respondsToSelector:@selector(didController:CreateNewPost:)]) {
            [self.delegate didController:self CreateNewPost:post];
        }
        if (self.bonus > 0) {
            [[AccountService defaultService] deductAccount:self.bonus source:BBSReward];
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
    if (resultCode == 0) {
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
            drawImage:(UIImage *)drawImage
{
    [controller dismissModalViewControllerAnimated:YES];
    self.image = nil;
    self.drawImage = drawImage;
    self.drawActionList = drawActionList;
    [self updateToolButtons];
}

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

@end
