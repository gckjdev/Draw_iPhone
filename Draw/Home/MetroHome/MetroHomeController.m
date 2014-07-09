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

#define DEFAUT_IMAGE_NAME "dialogue@2x"
#define TEST_DATA_GALLERYIMAGE "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg"
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBackground];
    
    // Do any additional setup after loading the view from its nib.
    UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE_NAME];
    
    
    //读取网上图片
    NSString *galleryImage = @TEST_DATA_GALLERYIMAGE;
    NSURL *galleryUrl = [NSURL URLWithString:galleryImage];
    [_galleryImageView setImageWithUrl:galleryUrl
                       placeholderImage:placeHolderImage
                            showLoading:YES
                               animated:YES];
    


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

//    //加阴影
//    UIView *shadowView = [self createShadow:self.paintingView];
//    [self.paintingView addSubview:shadowView];
    
}

-(IBAction)goToLearning:(id)sender{
    UserTutorialMainController* uc = [[UserTutorialMainController alloc] init];
    [self.navigationController pushViewController:uc animated:YES];
    [uc release];    
}


-(UIView *)createShadow:(UIView *)view{
    
    UIView *shadowView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)] autorelease];
    shadowView.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *shadow = [CAGradientLayer layer];
    UIColor *color = [UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.5];
    
    
    shadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 5);
    [shadow setStartPoint:CGPointMake(0.5, 1.0)];
    [shadow setEndPoint:CGPointMake(0.5, 3.0)];
    
    shadow.frame = CGRectMake(0, 0, 3, self.view.bounds.size.height);
    PPDebug(@"%i",self.view.bounds.size.height);
    [shadow setStartPoint:CGPointMake(0.0, 0.5)];
    [shadow setEndPoint:CGPointMake(1.0, 0.5)];
    
    shadow.colors = [NSArray arrayWithObjects:(id)[color CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [shadowView.layer insertSublayer:shadow atIndex:0];
    
    return shadowView;
    
}

- (void)setBackground
{
    UIImage *bgImg = [UIImage imageNamed:@"beijing.png"];
    UIColor *color = [[UIColor alloc] initWithPatternImage:bgImg];
    
    CGRect frame = CGRectMake(0, STATUSBAR_DELTA, self.view.frame.size.width, self.view.frame.size.height - STATUSBAR_DELTA);
    UIView *bg = [[UIView alloc] initWithFrame:frame];
    [bg setBackgroundColor:color];
    [color release];

    self.view.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:bg atIndex:0];
    [bg release];
}

- (IBAction)goTolearning:(id)sender {
}

- (IBAction)goToBBS:(id)sender {
    [self enterBBS];
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
    [self enterMore];
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
    [super viewDidUnload];
}
@end
