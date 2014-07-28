//
//  ResultShareAlertPageViewController.m
//  Draw
//
//  Created by ChaoSo on 14-7-22.
//
//

#import "ResultShareAlertPageViewController.h"
#import "UserManager.h"
#import "UIViewController+BGImage.h"
#import "Tutorial.pb.h"
#import "UserTutorialService.h"

@interface ResultShareAlertPageViewController ()

@property (nonatomic, retain) UIImage* resultImage;
@property (nonatomic, retain) PBUserStage* userStage;
@property (nonatomic, assign) int score;
@property (nonatomic, copy) ResultShareAlertPageViewResultBlock nextBlock;
@property (nonatomic, copy) ResultShareAlertPageViewResultBlock retryBlock;
@property (nonatomic, copy) ResultShareAlertPageViewResultBlock backBlock;

@end

@implementation ResultShareAlertPageViewController

+ (void)show:(PPViewController*)superController
       image:(UIImage*)resultImage
   userStage:(PBUserStage*)userStage
       score:(int)score
   nextBlock:(ResultShareAlertPageViewResultBlock)nextBlock
  retryBlock:(ResultShareAlertPageViewResultBlock)retryBlock
   backBlock:(ResultShareAlertPageViewResultBlock)backBlock
{
    ResultShareAlertPageViewController *rspc = [[ResultShareAlertPageViewController alloc] init];
    rspc.nextBlock = nextBlock;
    rspc.retryBlock = retryBlock;
    rspc.backBlock = backBlock;
    rspc.userStage = userStage;
    rspc.score = score;
    rspc.resultImage = resultImage;
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kResultSharePage") customView:rspc.view style:CommonDialogStyleCross];
    [dialog showInView:superController.view];
    
    [superController addChildViewController:superController];
    [rspc release];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define COMMONTITLE_VIEW [CommonTitleView titleView:self.view]
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [CommonTitleView createTitleView:self.view];
//    [self setDefaultBGImage];
    
    //更新页面
    [self updateViewWidget];
    
    //    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.opusImageView
    //                                                                  attribute:NSLayoutAttributeTop
    //                                                                  relatedBy:NSLayoutRelationEqual
    //                                                                     toItem:[CommonTitleView titleView:self.view]
    //                                                                  attribute:NSLayoutAttributeBottom
    //                                                                 multiplier:1.0
    //                                                                   constant:10.0];
    //    [self.view addConstraint:constraint];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//更新本页面控件
-(void)updateViewWidget{
    //button
    [self.shareButton setTitle:NSLS(@"kShare") forState:UIControlStateNormal];
    [self.shareButton.titleLabel setFont:AD_BOLD_FONT(18, 15)];
    [self.shareButton setFrame:(CGRectMake((ISIPAD ? 75:75),(ISIPAD ? 533:533),110,30))];
    SET_BUTTON_ROUND_STYLE_ORANGE(self.shareButton);
    [self.continueButton setTitle:NSLS(@"kContinue") forState:UIControlStateNormal];
    [self.continueButton.titleLabel setFont:AD_BOLD_FONT(18, 15)];
    [self.continueButton setFrame:(CGRectMake((ISIPAD ? 265:260),(ISIPAD ? 533:533),110,30))];
    SET_BUTTON_ROUND_STYLE_ORANGE(self.continueButton);
    
    //Label
    NSMutableAttributedString *desc = [self getDesc];
    [self.nameLabel setText:@"皮皮彭"];
    [self.nameLabel setFont:AD_FONT(20, 13)];
    self.decsLabel.attributedText = desc;

    
    //head
    //TODO
    //    UserManager* userManager = [UserManager defaultManager];
    //    [self.headImageView setAvatarUrl:[userManager avatarURL]
    //                           gender:[userManager gender]
    //                   useDefaultLogo:NO];
    //    self.headImageView.delegate = self;
    [self.avatarImageView setImage:[UIImage imageNamed:@"xiaoguanka"]];
    [self.avatarImageView setBackgroundColor:COLOR_BROWN];
    
    //opusImage
    [self.opusImageView setImage:[UIImage imageNamed:@"xiaoguanka"]];
    
}
-(NSMutableAttributedString *)getDesc{
    NSMutableAttributedString *attriString = [[[NSMutableAttributedString alloc]                  initWithString:@"恭喜皮皮彭！\n本次作品得分為78分,\n耗時58秒\n闖關成功！\n"]    autorelease];
    //所有字体
    [attriString addAttribute:NSFontAttributeName
                        value:AD_FONT(20, 13)
                        range:NSMakeRange(0,22)];
    
    //人名
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:COLOR_RED
                        range:NSMakeRange(2, 3)];
    [attriString addAttribute:NSFontAttributeName
                        value:AD_FONT(30, 20)
                        range:NSMakeRange(2,3)];
    
    //分数
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:COLOR_RED
                        range:NSMakeRange(14, 2)];
    [attriString addAttribute:NSFontAttributeName
                        value:AD_FONT(30, 20)
                        range:NSMakeRange(14,2)];
    //时间
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:COLOR_ORANGE
                        range:NSMakeRange(21,2)];
    [attriString addAttribute:NSFontAttributeName
                        value:AD_FONT(30, 20)
                        range:NSMakeRange(21,2)];
    
    
    return attriString;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    
    self.nextBlock = nil;
    self.retryBlock = nil;
    self.backBlock = nil;
    
    PPRelease(_userStage);
    PPRelease(_resultImage);
    
    [_opusImageView release];
    [_avatarImageView release];
    [_nameLabel release];
    [_decsLabel release];
    [_shareButton release];
    [_continueButton release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setOpusImageView:nil];
    [self setAvatarImageView:nil];
    [self setNameLabel:nil];
    [self setDecsLabel:nil];
    [self setShareButton:nil];
    [self setContinueButton:nil];
    [super viewDidUnload];
}

@end
