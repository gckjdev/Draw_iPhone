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
    
    CommonDialog *dialog = [CommonDialog
                            createDialogWithTitle:NSLS(@"kResultSharePage")
                                      customView:rspc.view
                                           style:CommonSquareDialogStyleCross
                                        delegate:rspc
            ];
    [dialog showInView:superController.view];
    dialog.clickOkBlock = ^(id infoView){
        PPDebug(@"click OK");
        rspc.nextBlock();
    };
    dialog.clickCancelBlock = ^(id infoView){
        PPDebug(@"click cancel");
        rspc.retryBlock();
    };
    dialog.clickCloseBlock = ^(id infoView){
        PPDebug(@"click close");
//        rspc.nextBlock();
    };
    
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
#define DEFAULT_AVATAR @"xiaoguanka"
#define DEFAULT_OPUS @"xiaoguanka"
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
//    NSMutableAttributedString *desc = [self getDesc];
//    [self.nameLabel setText:@"皮皮彭"];
//    [self.nameLabel setFont:AD_FONT(18, 13)];

    [self setDesc];
 
    //avatar
//    UIImage *avatar = self.userStage.;
//    if(self.resultImage!=nil){
//        avatar = self.resultImage;
//    }
//    if(avatar==nil){
//        PPDebug(@"<updateViewWidget> but the avatar is nil");
//    }
//    [self.avatarImageView setImage:avatar];
//    [self.avatarImageView setBackgroundColor:COLOR_BROWN];
    //opusImage
    UIImage *opus = [UIImage imageNamed:DEFAULT_OPUS];
    if(self.resultImage!=nil){
        opus = self.resultImage;
    }
    if(opus==nil){
        PPDebug(@"<updateViewWidget> but the opus is nil");
    }
    [self.opusImageView setImage:opus];
    
}
-(void *)setDesc{
    
    //@"恭喜皮皮彭！\n本次作品得分為%@分,\n耗時58秒,击败了宇宙%%%@的用户,\n闖關成功！"
    
    
    UserManager *user = [UserManager defaultManager];
    
    
    
    
    
    NSString *name = user.nickName;
    NSMutableAttributedString *nameMutableString = [[[NSMutableAttributedString alloc]                  initWithString:[NSString stringWithFormat:@"恭喜玩家%@！\n",name]]autorelease];
    //人名
    [nameMutableString addAttribute:NSForegroundColorAttributeName
                        value:COLOR_RED
                        range:NSMakeRange(4, [name length])];
    [nameMutableString addAttribute:NSFontAttributeName
                        value:AD_FONT(30, 18)
                        range:NSMakeRange(4,[name length])];
    self.lineOneLabel.attributedText = nameMutableString;
    
    
    NSString *score = [NSString stringWithFormat:@"%d",self.score];
    NSMutableAttributedString *scoreMutableString = [[[NSMutableAttributedString alloc]                  initWithString:[NSString stringWithFormat:@"本次作品得分為%@分,耗时58秒\n",score]]autorelease];
    //人名
    [scoreMutableString addAttribute:NSForegroundColorAttributeName
                              value:COLOR_RED
                              range:NSMakeRange(7, [score length]+1)];
    [scoreMutableString addAttribute:NSFontAttributeName
                              value:AD_FONT(30, 18)
                              range:NSMakeRange(7,[score length]+1)];
    self.lineTwoLabel.attributedText = scoreMutableString;
    
    
    NSString *result = NSLS(@"kConquerSuccessResult");
    if(self.score<60){
        result = NSLS(@"kConquerFailureResult");
    }
    NSMutableAttributedString *resultMutable = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@！",result]]autorelease];
    [resultMutable addAttribute:NSForegroundColorAttributeName
                         value:COLOR_RED
                         range:NSMakeRange(0, [result length])];
    [resultMutable addAttribute:NSFontAttributeName
                         value:AD_FONT(30, 18)
                         range:NSMakeRange(0,[result length])];
    self.lineFourLabel.attributedText = resultMutable;
    
    
    NSString *count = [NSString stringWithFormat:@"%d",self.userStage.defeatCount];
    NSMutableAttributedString *countMutable = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"击败了宇宙%%%@的用户！",count]]autorelease];
    [countMutable addAttribute:NSForegroundColorAttributeName
                               value:COLOR_RED
                               range:NSMakeRange(5, [count length]+1)];
    [countMutable addAttribute:NSFontAttributeName
                               value:AD_FONT(30, 18)
                               range:NSMakeRange(5,[count length]+1)];
    
    self.lineThreeLabel.attributedText = countMutable;
}

//按分享button时候


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
    [_shareButton release];
    [_continueButton release];
    [_lineOneLabel release];
    [_lineTwoLabel release];
    [_lineThreeLabel release];
    [_lineFourLabel release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setOpusImageView:nil];
    [self setAvatarImageView:nil];
    [self setNameLabel:nil];
    [self setShareButton:nil];
    [self setContinueButton:nil];
    [self setLineOneLabel:nil];
    [self setLineTwoLabel:nil];
    [self setLineThreeLabel:nil];
    [self setLineFourLabel:nil];
    [super viewDidUnload];
}
//#pragma mark - Delegate
//-(void)didClickCancel:(CommonDialog *)dialog{
//    PPDebug(@"click Cancel");
//    (void)(ResultShareAlertPageViewResultBlock) _retryBlock;
//    
//}
//-(void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView{
//    
//    PPDebug(@"click OK");
//    (void)(ResultShareAlertPageViewResultBlock) _nextBlock;
//}
//-(void)didClickClose:(CommonDialog *)dialog{
//    
//    PPDebug(@"click Close");
//    
//}



@end
