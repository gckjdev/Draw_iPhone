//
//  MetroHomeController.m
//  Draw
//
//  Created by ChaoSo on 14-7-8.
//
//

#import "MetroHomeController.h"
#import "UserManager.h"
#import "UserTutorialMainController.h"
#import "UIViewController+CommonHome.h"
#import "MoreViewController.h"
#import "BillboardManager.h"
#import "ICETutorialController.h"
#import "GuidePageManager.h"
#import "ICETutorialController.h"
#import "ResultSharePageViewController.h"
#import "ResultShareAlertPageViewController.h"
#import "TipsPageViewController.h"
#import "SDWebImageManager.h"

@interface MetroHomeController ()

@end


@implementation MetroHomeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define TRENDS_BUTTON_TITLE_EDGEINSETS   (ISIPAD ? -35 : -35)
#define DOCUMENT_BUTTON_TITLE_EDGEINSETS (ISIPAD ? -39 : -32)
#define MESSAGE_BUTTON_TITLE_EDGEINSET   (ISIPAD ? -39 : -32)
#define MORE_BUTTON_TITLE_EDGEINSETS     (ISIPAD ? -33 : -32)
#define BOTTOM_BUTTON_HEIGHT (ISIPAD ? 55 : 37)
-(void)setButtonTitleBottom{
    [self.indexButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT, TRENDS_BUTTON_TITLE_EDGEINSETS, 0, 0)];
    [self.documentButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT, DOCUMENT_BUTTON_TITLE_EDGEINSETS, 0, 0)];
    [self.messageButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT, MESSAGE_BUTTON_TITLE_EDGEINSET, 0, 0)];
    [self.moreButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT,                        MORE_BUTTON_TITLE_EDGEINSETS, 0, 0)];
    
}


#define DEFAUT_IMAGE_NAME "dialogue@2x"
#define TEST_DATA_GALLERYIMAGE "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg"
#define IS_IOS7_OR_LATER [[UIDevice currentDevice] systemVersion]>=7 ? YES:NO
- (void)viewDidLoad
{
//    
//    [CommonTitleView createTitleView:self.view];
//    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kMetroMainHome")];
    
    
    
    [super viewDidLoad];
    
//    
//    //test
//    [self goToGuidePage];
    
    [self setBackground];
        // Do any additional setup after loading the view from its nib.

    
    [self setGalleryView];
//    [self setGalleryImageForModel];
   
    //用户头像
    UserManager* userManager = [UserManager defaultManager];
    
    [self.avatarView setAvatarUrl:[userManager avatarURL]
                     gender:[userManager gender]
                     useDefaultLogo:NO];
    self.avatarView.delegate = self;    
    
    //用户名字（赋值）
    NSString *name = [userManager nickName];
    [_topNameLable setText:name];
    [_topNameLable setFont:AD_FONT(20, 15)];
    [_topNameLable setTextColor:COLOR_BROWN];
    [_topNameButton setTitle:name forState:UIControlStateNormal];
    [_topNameButton setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    [_topNameButton.titleLabel setFont:AD_FONT(20, 15)];
    [self setButtonTitleBottom];
    
    //TEST
    [self setBadgeView];
    
    //autolayout 适配ios6 ios7
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.galleryView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.topView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0];
    
    int constant = 0;
    if(ISIOS7){
        constant = 20;
    }
    NSLayoutConstraint* constraint2 = [NSLayoutConstraint constraintWithItem:self.topView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:constant];
    
    [self.view addConstraint:constraint];
    
    [self.view addConstraint:constraint2];
    
}
-(void)viewWillAppear:(BOOL)animated{
    //适配IOS7
//    if([DeviceDetection isOS7]){
//        PPDebug(@"self.view.bounds.y1==%d",self.view.bounds.origin.y);
//        self.view.bounds = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height);
//        PPDebug(@"self.view.bounds.y2==%d",self.view.bounds.origin.y);
//    }
    
}

-(void)setGalleryImageForModel{
    
    [self setCanDragBack:NO];
     UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE_NAME];
    BillboardManager *bbManager = [BillboardManager defaultManager];
    self.bbList = bbManager.bbList;
//    CGRect bound=CGRectMake(26,15, 268, 120);
    for(Billboard *bb in self.bbList){
        UIImageView *imageView =[[[UIImageView alloc]initWithFrame:CGRectMake(26, 15, 268, 120)] autorelease];
        
        NSString *galleryImage = bb.image;
        
        NSURL *galleryUrl = [NSURL URLWithString:galleryImage];
        [imageView setImageWithUrl:galleryUrl
                  placeholderImage:placeHolderImage
                       showLoading:YES
                          animated:YES];

    }
   
   
}

-(void)galleryClick:(id)sender{
    [[self.bbList objectAtIndex:0] clickAction:self];
    PPDebug(@"<click_gallery_image>button_tag=%d",index);
}



#define TEST_DATA 5
-(void)setBadgeView{
    [self.indexBadge setNumber:TEST_DATA];
    [self.documentBadge setNumber:TEST_DATA];
    [self.messageBadge setNumber:TEST_DATA];
    [self.moreBadge setNumber:TEST_DATA];
    [self.anounceBadge setNumber:TEST_DATA];
}

-(IBAction)goToLearning:(id)sender{
    UserTutorialMainController* uc = [[UserTutorialMainController alloc] init];
    [self.navigationController pushViewController:uc animated:YES];
    [uc release];    
}

//主页背景
#define GALLERY_BACKGROUND_Y (ISIPAD ? 69:41)
- (void)setBackground
{
    
    UIImage *galleryBackground = [UIImage imageNamed:@"gonggaolan.png"];
    UIColor *color = [[UIColor alloc] initWithPatternImage:galleryBackground];
    
    CGRect frame = CGRectMake(0, GALLERY_BACKGROUND_Y, self.galleryView.frame.size.width, self.galleryView.frame.size.height);
    UIView *bg = [[UIView alloc] initWithFrame:frame];
    [bg setBackgroundColor:color];
    [color release];
    
    self.galleryView.backgroundColor = [UIColor clearColor];
    [self.topView insertSubview:bg atIndex:0];
    [bg release];
    UIImage *bottomBackground = [UIImage imageNamed:@"neironglan yu caidanlan.png"];
    [self.bottomBackground setBackgroundColor:[UIColor clearColor]];
    [self.bottomBackground setImage:bottomBackground];
}







#pragma -mark
#pragma mark click
- (IBAction)goTolearning:(id)sender {
}

- (IBAction)goToBBS:(id)sender {
//    [self enterBBS];
    
//    ResultShareAlertPageViewController *rspc = [[ResultShareAlertPageViewController alloc] init];
//    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kResultSharePage") customView:rspc.view style:CommonDialogStyleCross];
//    [dialog showInView:self.view];
    
    TipsPageViewController *rspc = [[TipsPageViewController alloc] init];
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"提示") customView:rspc.view style:CommonSquareDialogStyleCross];
    [dialog showInView:self.view];
}

- (IBAction)goToDraw:(id)sender {
    [self enterOfflineDraw];
}

- (IBAction)goToOpus:(id)sender {
    [self enterOpusClass];
}

- (IBAction)goToIndexController:(id)sender{
    [self enterTimeline];
}

- (IBAction)goToDocumentController:(id)sender{
    [self enterDraftBox];
}

- (IBAction)goToMessageController:(id)sender{
    [self enterChat];
}

- (IBAction)goToMoreController:(id)sender{
//    [self enterMore];
    
    MoreViewController *more = [[MoreViewController alloc] init];
    [self.navigationController pushViewController:more animated:YES];
    [more release];
}


-(IBAction)goToAnnounce:(id)sender{
    [self showBulletinView];
}

-(IBAction)goToUserDetail:(id)sender{
    [self enterUserDetail];
}





#pragma mark - Avatart View Delegate

- (void)didClickOnAvatar:(NSString *)userId
{
    [self enterUserDetail];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击事件
-(void)labelClicked{
    PPDebug(@"click the label");
}
//创造手势
//
//-(void)goToUserDetail{
//    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                action:@selector(labelClicked:)];
//         singleFingerOne.numberOfTouchesRequired = 1; //手指数
//        singleFingerOne.numberOfTapsRequired = 1; //tap次数
//    
//    [_topNameLable addGestureRecognizer:singleFingerOne];
//    
//}


#pragma mark -

// 设置Gallery
#define IMAGE_FRAME_X (ISIPAD ? 26:11)
#define IMAGE_FRAME_Y (ISIPAD ? 24:15)
#define IMAGE_FRAME_WIDTH (ISIPAD ? 716:298)
#define IMAGE_FRAME_HEIGHT (ISIPAD ? 250:120)
#define DEFAULT_GALLERY_IMAGE @"daguanka"
-(void)setGalleryView{
    BillboardManager *bbManager = [BillboardManager defaultManager];
    self.bbList = bbManager.bbList;
    //默认图片
    UIImage *image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE];
    [self.galleryImageView initWithImage:image];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray *itemList = [[[NSMutableArray alloc] init] autorelease];
        for(Billboard *bb in _bbList){
            NSString *galleryImage = bb.image;
            NSURL *galleryUrl = [NSURL URLWithString:galleryImage];
            
            UIImage *image = nil;
            //设置默认图片
            if(galleryUrl==nil||[galleryUrl isEqual:@""]){
                
                image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE] ;
                
            }
            //读取网上的图片数据
            //TODO 异步
            NSData* data = [NSData dataWithContentsOfURL:galleryUrl];
            
            if(data==nil){
                image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE] ;
                
            }
            image = [[[UIImage alloc] initWithData:data] autorelease];
            
            if(image==nil){
                image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE] ;
            }
            
            //添加到第三方框架
            SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithTitle:@"" image:image tag:bb.index] autorelease];
            
            
            [itemList addObject:item];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //新建滚动展览
            SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(IMAGE_FRAME_X, IMAGE_FRAME_Y, IMAGE_FRAME_WIDTH ,IMAGE_FRAME_HEIGHT)
                                                                            delegate:self
                                                                     focusImageItems:itemList, nil];
            [self.galleryView addSubview:imageFrame];
            [self.galleryView bringSubviewToFront:imageFrame];
            [imageFrame release];
        });
    });
    

}
-(void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item{
    NSLog(@"%@", item.title);
}

//根据字符串反射到方法
-(void)clickActionDelegate:(int)index{
    NSInteger *count = [self.bbList count];
    if(index >= count){
        return;
    }
    [[self.bbList objectAtIndex:index] clickAction:self];
}
-(void)adapt_iOS6{
    if([DeviceDetection isOS6]){
        [self.galleryButton setBackgroundColor:COLOR_YELLOW];
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-20, self.view.frame.size.width, self.view.frame.size.height)];
        
    }
}

- (void)dealloc {
    [_galleryView release];
    [_galleryImageView release];
    [_topView release];
    [_topNameLable release];
    [_topAnnounceView release];
    [_topAnnounceButton release];
    [_avatarView release];
    [_paintingView release];
    [_paintingViewButton release];
    [_learningView release];
    [_learningViewButton release];
    [_mainView release];
    [_bottomView release];
    [_indexButton release];
    [_documentButton release];
    [_messageButton release];
    [_moreButton release];
    [_topNameButton release];
    [_bottomBackground release];
    [_indexBadge release];
    [_documentBadge release];
    [_messageBadge release];
    [_moreBadge release];
    [_anounceBadge release];
    [_galleryButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setGalleryView:nil];
    [self setGalleryImageView:nil];
    [self setTopView:nil];
    [self setTopNameLable:nil];
    [self setTopAnnounceView:nil];
    [self setTopAnnounceButton:nil];
    [self setAvatarView:nil];
    [self setPaintingView:nil];
    [self setPaintingViewButton:nil];
    [self setLearningView:nil];
    [self setLearningViewButton:nil];
    [self setLearningView:nil];
    [self setLearningViewButton:nil];
    [self setMainView:nil];
    [self setBottomView:nil];
    [self setIndexButton:nil];
    [self setDocumentButton:nil];
    [self setMessageButton:nil];
    [self setMoreButton:nil];
    [self setTopNameButton:nil];
    [self setBottomBackground:nil];
    [self setIndexBadge:nil];
    [self setDocumentBadge:nil];
    [self setMessageBadge:nil];
    [self setMoreBadge:nil];
    [self setAnounceBadge:nil];
    [self setGalleryButton:nil];
    [super viewDidUnload];
}
@end
