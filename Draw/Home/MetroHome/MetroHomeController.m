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

#define TRENDS_BUTTON_TITLE_EDGEINSETS   (ISIPAD ? -52 : -30)
#define DOCUMENT_BUTTON_TITLE_EDGEINSETS (ISIPAD ? -46 : -34)
#define MESSAGE_BUTTON_TITLE_EDGEINSET   (ISIPAD ? -46 : -34)
#define MORE_BUTTON_TITLE_EDGEINSETS     (ISIPAD ? -42 : -34)
#define BOTTOM_BUTTON_HEIGHT (ISIPAD ? 52 : 43)
-(void)setButtonTitleBottom{
    [self.indexButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT, TRENDS_BUTTON_TITLE_EDGEINSETS, 0, 0)];
    [self.documentButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT, DOCUMENT_BUTTON_TITLE_EDGEINSETS, 0, 0)];
    [self.messageButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT, MESSAGE_BUTTON_TITLE_EDGEINSET, 0, 0)];
    [self.moreButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT,                        MORE_BUTTON_TITLE_EDGEINSETS, 0, 0)];
    
    //title label font
//    [self.indexButton.titleLabel setFont:AD_FONT(8, 11)];
//    
//    [self.documentButton.titleLabel setFont:AD_FONT(8, 11)];
//    
//    [self.messageButton.titleLabel setFont:AD_FONT(8, 11)];
//    
//    [self.moreButton.titleLabel setFont:AD_FONT(8, 11)];

    
    
}


#define DEFAUT_IMAGE_NAME "dialogue@2x"
#define TEST_DATA_GALLERYIMAGE "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg"
- (void)viewDidLoad
{
//    
//    [CommonTitleView createTitleView:self.view];
//    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kMetroMainHome")];
    
    
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
    [_topNameButton setTitle:name forState:UIControlStateNormal];
    [_topNameButton setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    [_topNameButton.titleLabel setFont:AD_FONT(20, 15)];
    
//    [[UINavigationBar appearance] setBarTintColor:[UIColor yellowColor]];
    
//    //加阴影
//    UIView *shadowView = [self createShadow:self.paintingView];
//    [self.paintingView addSubview:shadowView];
    [self setButtonTitleBottom];
    [self goToUserDetail];
    
    //TEST
    [self setBadgeView];

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

-(void)goToUserDetail{
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(labelClicked:)];
         singleFingerOne.numberOfTouchesRequired = 1; //手指数
        singleFingerOne.numberOfTapsRequired = 1; //tap次数
    
    [_topNameLable addGestureRecognizer:singleFingerOne];
    
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
    [super viewDidUnload];
}
@end
