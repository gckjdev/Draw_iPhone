//
//  TipsPageViewController.m
//  Draw
//
//  Created by ChaoSo on 14-7-25.
//
//

#import "TipsPageViewController.h"
#import "SGFocusImageItem.h"
#import "BBSService.h"

@interface TipsPageViewController ()
{
}

@property (nonatomic, retain) NSString* dialogTitle;
@property (nonatomic, retain) NSArray* imagePathArray;
@property (nonatomic, assign) int* returnIndex;
@property (nonatomic, assign) int defaultIndex;

@end

@implementation TipsPageViewController

+ (void)show:(PPViewController*)superController
       title:(NSString*)title
imagePathArray:(NSArray*)imagePathArray
defaultIndex:(int)defaultIndex
 returnIndex:(int*)returnIndex
  tutorialId:(NSString*)tutorialId
     stageId:(NSString *)stageId
  tutorialName:(NSString*)tutorialName
     stageName:(NSString *)stageName
   showForum:(BOOL)showForum
    showPlay:(BOOL)showPlay
playCallback:(dispatch_block_t)playCallback

{
    TipsPageViewController *rspc = [[TipsPageViewController alloc] init];
    rspc.dialogTitle = title;
    rspc.imagePathArray = imagePathArray;
    rspc.returnIndex = returnIndex;
    rspc.defaultIndex = defaultIndex;
    
    int style = CommonDialogStyleSingleButtonWithCross;
//    if (showForum && showPlay){
//        style = CommonDialogStyleDoubleButtonWithCross;
//    }
//    else{
//        style = CommonDialogStyleSingleButtonWithCross;
//    }
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:title
                                                    customView:rspc.view
                                                         style:style];
    
    if (showPlay){
        [dialog.oKButton setTitle:NSLS(@"kPlayTutorial") forState:UIControlStateNormal];
    }

    [dialog setClickOkBlock:^(id view){
        if (showPlay){
            EXECUTE_BLOCK(playCallback);
        }
        else{
            [rspc removeFromParentViewController];
        }
    }];
    
//    [dialog.cancelButton setTitle:NSLS(@"kAskQuestion") forState:UIControlStateNormal];
//    
//    [dialog setClickCancelBlock:^(id view){
//        BBSService *bbsService = [BBSService defaultService];
//        if(tutorialId!=nil&&stageId!=nil){
//            [bbsService getStagePost:tutorialId
//                             stageId:stageId
//                        tutorialName:tutorialName
//                           stageName:stageName
//                      fromController:superController];
//            
//        }
//    }];
    
    
    [dialog showInView:superController.view];
    [superController addChildViewController:rspc];
    [rspc release];
}

- (void)dealloc
{
    PPRelease(_dialogTitle);
    PPRelease(_imagePathArray);
    [super dealloc];
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
    [self initTipsSGFousImage:self.imagePathArray];
}

#define IMAGE_FRAME_X (ISIPAD ? 26:11)
#define IMAGE_FRAME_Y (ISIPAD ? 20:15)
#define IMAGE_FRAME_WIDTH (ISIPAD ? 500:265)
//#define IMAGE_FRAME_HEIGHT (ISIPAD ? 450:240)
//#define DEFAULT_GALLERY_IMAGE @"square2"
#define IMAGE_FRAME_HEIGHT (ISIPAD ? 500:265)
//#define DEFAULT_GALLERY_IMAGE @"daguanka"

-(void)initTipsSGFousImage:(NSArray*)imagePathArray{
    
    NSMutableArray *itemList = [[[NSMutableArray alloc] init] autorelease];
    
    for(NSString *gallerUrlString in imagePathArray){
        int i= 0;
        UIImage *image = [[[UIImage alloc] initWithContentsOfFile:gallerUrlString] autorelease];

        if(image==nil){
            image = [[ShareImageManager defaultManager] unloadBg];
        }
               SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithTitle:@"" image:image tag:i] autorelease];
        [itemList addObject:item];
        //test
        i++;
    }
    
    CGRect frame = CGRectMake(0, 0, IMAGE_FRAME_WIDTH,IMAGE_FRAME_HEIGHT);
    SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrameAndIntervalTime:frame
                                                                    delegate:self
                                                                    intervalTime:0.0f
                                                                    defaultPage:self.defaultIndex
                                                                    focusImageItems:itemList];
    
    imageFrame.userInteractionEnabled = YES;
    [self.view addSubview:imageFrame];
    [self.view bringSubviewToFront:imageFrame];
    [imageFrame release];
    
    
    
}

-(void)clickActionDelegate:(int)index{
    PPDebug(@"Tips");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Delegate

-(void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item{
    PPDebug(@"testing testing!!!");
}

-(void)setCurrentPage:(NSInteger)currentPage{
    PPDebug(@"currentPage==%d",currentPage);
    if (_returnIndex != NULL){
        *_returnIndex = currentPage;
        PPDebug(@"returnIndex==%d",self.returnIndex);
    }
    
}

@end
