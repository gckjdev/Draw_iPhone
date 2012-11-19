//
//  CreatePostController.m
//  Draw
//
//  Created by gamy on 12-11-16.
//
//

#import "CreatePostController.h"
#import "BBSService.h"
#import "Bbs.pb.h"
#import "UIImageExt.h"
#import "OfflineDrawViewController.h"
#import "ShareImageManager.h"

@interface CreatePostController ()
{
    PBBBSBoard *_bbsBoard;
    UIImage *_image;
    UIImage *_drawImage;
    NSString *_text;
    NSMutableArray *_drawActionList;
    ChangeAvatar *_imagePicker;
    NSInteger _bonus;
}
@property(nonatomic, retain)PBBBSBoard *bbsBoard;
@property(nonatomic, retain)ChangeAvatar *imagePicker;
@property(nonatomic, retain)UIImage *image;
@property(nonatomic, retain)UIImage *drawImage;
@property(nonatomic, retain)NSMutableArray *drawActionList;
@property(nonatomic, retain)NSString *text;
@property(nonatomic, assign)NSInteger bonus;
@end

@implementation CreatePostController
@synthesize bbsBoard = _bbsBoard;
@synthesize image = _image;
@synthesize drawImage = _drawImage;
@synthesize drawActionList = _drawActionList;
@synthesize textView = _textView;
@synthesize imagePicker = _imagePicker;
@synthesize text = _text;
@synthesize bonus = _bonus;

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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateToolButtons
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    if (self.drawImage) {
        [self.graffitiButton setImage:self.drawImage
                             forState:UIControlStateNormal];
    }else{
        [self.graffitiButton setImage:[imageManager greenImage]
                             forState:UIControlStateNormal];
    }
    if (self.image) {
        [self.imageButton setImage:self.image
                          forState:UIControlStateNormal];
    }else{
        [self.imageButton setImage:[imageManager redImage]
                          forState:UIControlStateNormal];
    }
    [self.rewardButton setTitle:[NSString stringWithFormat:@"%d",self.bonus]
                       forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateToolButtons];
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
    [super viewDidUnload];
}

#define TEXT_LENGTH_MIN 5
#define TEXT_LENGTH_MAX 3000
#define IMAGE_SIZE_MAX 1500
- (BOOL)checkAndSetSendingInfo
{

    self.text = self.textView.text;
    //create image post
    if (self.image) {
        if ([self.text length] == 0) {
            self.text = NSLS(@"kImage");
        }
        return YES;
    }
    
    //crate draw post.
    if (self.drawImage) {
        if ([self.text length] == 0) {
            self.text = NSLS(@"kGraffiti");
        }
        return YES;
    }
    
    //create text post
    if ([self.text length] < TEXT_LENGTH_MIN) {
        PPDebug(@"<checkSendingInfo> text length less than %d", TEXT_LENGTH_MIN);
        return NO;
    }
    if ([self.text length] > TEXT_LENGTH_MAX) {
        PPDebug(@"<checkSendingInfo> text length more than %d", TEXT_LENGTH_MAX);
        return NO;
    }
    return YES;
}

- (IBAction)clickBackButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clickSubmitButton:(id)sender {
    if (![self checkAndSetSendingInfo]) {
        return;
    }
    [[BBSService defaultService] createPostWithBoardId:_bbsBoard.boardId
                                                  text:self.text
                                                 image:self.image
                                        drawActionList:self.drawActionList
                                             drawImage:self.drawImage
                                                 bonus:self.bonus
                                              delegate:self];
}

- (IBAction)clickGraffitiButton:(id)sender {
    //TODO alert to clear image data.
    
    //clear image data
    self.image = nil;
    [self updateToolButtons];
    
    OfflineDrawViewController *odc = [[OfflineDrawViewController alloc] initWithTargetType:TypeGraffiti delegate:self];
    [self presentModalViewController:odc animated:YES];

}

- (IBAction)clickImageButton:(id)sender {
    //TODO alert to clear graffiti data
    
    //clear graffiti data
    self.drawActionList = nil;
    self.drawImage = nil;
    [self updateToolButtons];
    
    self.imagePicker = [[ChangeAvatar alloc] init];
    [self.imagePicker setAutoRoundRect:NO];
    [self.imagePicker setImageSize:CGSizeMake(0, 0)];
    [self.imagePicker showSelectionView:self];
}

- (IBAction)clickRewardButton:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:NSLS(@"kReward")
                                                    delegate:self
                                           cancelButtonTitle:NSLS(@"kCancel")
                                      destructiveButtonTitle:NSLS(@"0")
                                           otherButtonTitles:@"100",@"200",@"300", nil];
    [as setDestructiveButtonIndex:self.bonus/100];
    
    [as showInView:self.view];
    [as release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.bonus = buttonIndex * 100;
    [self updateToolButtons];
}

- (void)didImageSelected:(UIImage*)image
{
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

- (void)didCreatePost:(PBBBSPost *)post
           resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        PPDebug(@"<didCreatePost>create post successful!");
        [BBSManager printBBSPost:post];
        [self dismissModalViewControllerAnimated:YES];
    }else{
        PPDebug(@"<didCreatePost>create post fail.result code = %d",resultCode);
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
    self.drawImage = drawImage;
    self.drawActionList = drawActionList;
    [self updateToolButtons];
}

@end
