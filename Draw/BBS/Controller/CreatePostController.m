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

@interface CreatePostController ()
{
    PBBBSBoard *_bbsBoard;
    UIImage *_image;
    UIImage *_drawImage;
    NSMutableArray *_drawActionList;
}
@property(nonatomic, retain)PBBBSBoard *bbsBoard;

@property(nonatomic, retain)UIImage *image;
@property(nonatomic, retain)UIImage *drawImage;
@property(nonatomic, retain)NSMutableArray *drawActionList;
@end

@implementation CreatePostController
@synthesize bbsBoard = _bbsBoard;
@synthesize image = _image;
@synthesize drawImage = _drawImage;
@synthesize drawActionList = _drawActionList;
@synthesize textView = _textView;
- (void)dealloc
{
    PPRelease(_image);
    PPRelease(_drawImage);
    PPRelease(_drawActionList);
    PPRelease(_bbsBoard);
    PPRelease(_textView);
    [super dealloc];
}
- (id)initWithBoard:(PBBBSBoard *)board
{
    self = [super init];
    if (self) {
        self.bbsBoard = board;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}

#define TEXT_LENGTH_MIN 5
#define TEXT_LENGTH_MAX 30000
- (BOOL)checkSendingInfo
{
    if ([self.textView.text length] < TEXT_LENGTH_MIN) {
        PPDebug(@"<checkSendingInfo> text length less than %d", TEXT_LENGTH_MIN);
        return NO;
    }
    if ([self.textView.text length] > TEXT_LENGTH_MAX) {
        PPDebug(@"<checkSendingInfo> text length more than %d", TEXT_LENGTH_MAX);
        return NO;
    }
    return YES;
}

- (IBAction)clickBackButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clickSubmitButton:(id)sender {
    NSString *text = self.textView.text;
    if (![self checkSendingInfo]) {
        return;
    }
    [[BBSService defaultService] createPostWithBoardId:_bbsBoard.boardId
                                                  text:text
                                                 image:self.image
                                        drawActionList:self.drawActionList
                                             drawImage:self.drawImage
                                              delegate:self];
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

@end
