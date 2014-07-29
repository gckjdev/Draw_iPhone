//
//  TipsPageViewController.m
//  Draw
//
//  Created by ChaoSo on 14-7-25.
//
//

#import "TipsPageViewController.h"
#import "SGFocusImageItem.h"

@interface TipsPageViewController ()

@property (nonatomic, retain) NSString* dialogTitle;
@property (nonatomic, retain) NSArray* imagePathArray;

@end

@implementation TipsPageViewController

+ (void)show:(PPViewController*)superController title:(NSString*)title imagePathArray:(NSArray*)imagePathArray
{
    TipsPageViewController *rspc = [[TipsPageViewController alloc] init];
    rspc.dialogTitle = title;
    rspc.imagePathArray = imagePathArray;
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:title customView:rspc.view style:CommonSquareDialogStyleCross];
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
    [self initTipsSGFousImage:nil];
}

#define IMAGE_FRAME_X (ISIPAD ? 26:11)
#define IMAGE_FRAME_Y (ISIPAD ? 20:15)
#define IMAGE_FRAME_WIDTH (ISIPAD ? 500:265)
//#define IMAGE_FRAME_HEIGHT (ISIPAD ? 450:240)
//#define DEFAULT_GALLERY_IMAGE @"square2"
#define IMAGE_FRAME_HEIGHT (ISIPAD ? 500:265)
#define DEFAULT_GALLERY_IMAGE @"square3"

-(void)initTipsSGFousImage:(NSString*)gallerUrlString{
    
    
    NSString *galleryImage = gallerUrlString;
    NSURL *galleryUrl = [NSURL URLWithString:galleryImage];
    
    NSMutableArray *itemList = [[[NSMutableArray alloc] init] autorelease];
    UIImage *image = nil;
    //设置默认图片
    if(galleryUrl==nil||[galleryUrl isEqual:@""]){
        
        image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE] ;
        
    }
    //读取网上的图片数据
    NSData* data = [NSData dataWithContentsOfURL:galleryUrl];
    if(data==nil){
        image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE] ;
    }
    image = [[[UIImage alloc] initWithData:data] autorelease];
    
    if(image==nil){
        image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE] ;
    }
    
    image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE];

    SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithTitle:@"" image:image tag:1] autorelease];
    SGFocusImageItem *item2 = [[[SGFocusImageItem alloc] initWithTitle:@"" image:image tag:2] autorelease];
    
    [itemList addObject:item];
    [itemList addObject:item2];

    
    SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrameAndIntervalTime:CGRectMake(0, 0, IMAGE_FRAME_WIDTH,IMAGE_FRAME_HEIGHT)
                                                                    delegate:self
                                                                    intervalTime:0.0f
                                                             focusImageItems:itemList, nil
                                                            ];
    imageFrame.userInteractionEnabled = YES;
//    [imageFrame stopScoll];
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

@end
