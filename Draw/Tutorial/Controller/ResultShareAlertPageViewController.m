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
#import "PBTutorial+Extend.h"
#import "UserTutorialManager.h"
#import "GameSNSService.h"
#import "BBSActionSheet.h"
#import "MKBlockActionSheet.h"
#import "PPSNSConstants.h"
#import "PPConfigManager.h"
#import "UIViewUtils.h"
#import "UIImageUtil.h"
#import "FileUtil.h"

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
                                        delegate:rspc];
    
    dialog.manualClose = YES;
    
    
    // 根据评分结果跳转
    BOOL isPass = [[UserTutorialManager defaultManager] isPass:score];
    NSString *resultMessage = @"";
    
    if (isPass){
        
        BOOL isTutorialComplete = [[UserTutorialManager defaultManager] isLastStage:userStage];
        if (isTutorialComplete){

            // 及格，最后一关
            resultMessage = [NSString stringWithFormat:NSLS(@"kConquerResultPassComplete")];

            // 左边按钮为【返回】
            [dialog.oKButton setTitle:NSLS(@"Back") forState:UIControlStateNormal];
            [dialog setClickOkBlock:^(id view){
                
                // close dialog
                [dialog disappear];
                
                EXECUTE_BLOCK(rspc.backBlock)
            }];
            
        }
        else{
        
            // 及格，提示闯下一关
            resultMessage = [NSString stringWithFormat:NSLS(@"kConquerResultPassNext")];
            
            // 左边按钮为【下一关】
            [dialog.oKButton setTitle:NSLS(@"kTryConquerNext") forState:UIControlStateNormal];
            [dialog setClickOkBlock:^(id view){
                
                // close dialog
                [dialog disappear];

                EXECUTE_BLOCK(rspc.nextBlock);
            }];
        
        }
    }
    else{
        
        // 闯关失败，建议再来一次        
        resultMessage = [NSString stringWithFormat:NSLS(@"kConquerFailureResult")];
        
        // 左边按钮为【下一关】
        [dialog.oKButton setTitle:NSLS(@"kConquerAgain") forState:UIControlStateNormal];
        [dialog setClickOkBlock:^(id view){
            
            // close dialog
            [dialog disappear];

            EXECUTE_BLOCK(rspc.retryBlock);
        }];
    }
    
    [dialog.cancelButton setTitle:NSLS(@"kShare") forState:UIControlStateNormal];
    
//    [dialog.cancelButton.titleLabel setFont:AD_FONT(20, 12)];
    
    dialog.clickCancelBlock = ^(id infoView){
        [rspc shareSNS:superController.view];
    };

    dialog.clickCloseBlock = ^(id infoView){
        
        // close dialog
        [dialog disappear];
        
        EXECUTE_BLOCK(rspc.backBlock);
    };

    
    [dialog showInView:superController.view];
    [superController addChildViewController:rspc];
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
#define DEFAULT_OPUS @"xiaoguanka"

-(void)updateViewWidget{
    //button
    [self.shareButton setTitle:NSLS(@"kShare") forState:UIControlStateNormal];
    [self.shareButton.titleLabel setFont:AD_BOLD_FONT(18, 15)];
    [self.shareButton setFrame:(CGRectMake((ISIPAD ? 75:75),(ISIPAD ? 533:533),110,30))];
    SET_BUTTON_ROUND_STYLE_ORANGE(self.shareButton);
    [self.continueButton setTitle:NSLS(@"kTryConquerNext") forState:UIControlStateNormal];
    [self.continueButton.titleLabel setFont:AD_BOLD_FONT(18, 15)];
    [self.continueButton setFrame:(CGRectMake((ISIPAD ? 265:260),(ISIPAD ? 533:533),110,30))];
    SET_BUTTON_ROUND_STYLE_ORANGE(self.continueButton);
    
    //Label
//    NSMutableAttributedString *desc = [self getDesc];
//    [self.nameLabel setText:@"皮皮彭"];
//    [self.nameLabel setFont:AD_FONT(18, 13)];

    [self setDesc];
 
    //avatar
    UserManager *user = [UserManager defaultManager];
    [self.avatarImageView setAvatarUrl:user.avatarURL
                                gender:user.gender
                        useDefaultLogo:NO];
    
    //opusImage
    UIImage *opus = [[ShareImageManager defaultManager] unloadBg];
    if(self.resultImage!=nil){
        opus = self.resultImage;
    }
    [self.opusImageView setImage:opus];
    
}
-(void)setDesc{
    
    //@"恭喜皮皮彭！\n本次作品得分為%@分,\n耗時58秒,击败了宇宙%%%@的用户,\n闖關成功！"
    
    
    UserManager *user = [UserManager defaultManager];
    
    
    
    
    
    NSString *name = user.nickName;
    NSMutableAttributedString *nameMutableString = [[[NSMutableAttributedString alloc]                  initWithString:[NSString stringWithFormat:@"%@\n",name]]autorelease];
    //人名
    [nameMutableString addAttribute:NSForegroundColorAttributeName
                        value:COLOR_BROWN
                        range:NSMakeRange(0, [name length])];
    [nameMutableString addAttribute:NSFontAttributeName
                        value:AD_FONT(18, 12)
                        range:NSMakeRange(0,[name length])];
    self.lineOneLabel.attributedText = nameMutableString;
    
    
    NSString *score = [NSString stringWithFormat:@"%d",self.score];
    NSMutableAttributedString *scoreMutableString = [[[NSMutableAttributedString alloc]                  initWithString:[NSString stringWithFormat:@"本次作品得分為%@分\n",score]]autorelease];
    //人名
    [scoreMutableString addAttribute:NSForegroundColorAttributeName
                              value:COLOR_RED
                              range:NSMakeRange(7, [score length]+1)];
    [scoreMutableString addAttribute:NSFontAttributeName
                              value:AD_FONT(30, 18)
                              range:NSMakeRange(7,[score length]+1)];
    self.lineTwoLabel.attributedText = scoreMutableString;
    
    // TODO localization
    // TODO calculate length/location by code
    NSString *result = NSLS(@"kConquerSuccessResult");
    BOOL isPass = [[UserTutorialManager defaultManager] isPass:score];
    if (isPass == NO){
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
    NSMutableAttributedString *countMutable = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"击败了宇宙%@%%的用户！",count]]autorelease];
    [countMutable addAttribute:NSForegroundColorAttributeName
                               value:COLOR_RED
                               range:NSMakeRange(5, [count length]+1)];
    [countMutable addAttribute:NSFontAttributeName
                               value:AD_FONT(30, 18)
                               range:NSMakeRange(5,[count length]+1)];
    
    self.lineThreeLabel.attributedText = countMutable;
}

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



#define TITLE_SHARE_WEIXIN_FRIEND   NSLS(@"kConquerDrawShareWeixinFriend")
#define TITLE_SHARE_WEIXIN_TIMELINE NSLS(@"kConquerDrawSharekWeixinTimeline")
#define TITLE_SHARE_SINA_WEIBO      NSLS(@"kConquerDrawShareSinaWeibo")
#define TITLE_SHARE_QQ_WEIBO        NSLS(@"kConquerDrawShareQQWeibo")

- (int)defeatPercent
{
    return [self.userStage defeatPercent];
}

#define TEMP_SHARE_FILE_NAME        @"conquer_draw_share.png"

- (NSString*)createShareImagePath
{
    UIImage* image = [self.view createSnapShotWithScale:1.0f];
    NSString* path = nil;
    if (image){
        path = [[FileUtil getAppTempDir] stringByAppendingPathComponent:TEMP_SHARE_FILE_NAME];
        BOOL result = [image saveImageToFile:path];
        if (result == NO){
            path = nil;
        }
    }

    PPDebug(@"<createShareImagePath> path=%@", path);
    return path;
}

- (NSString*)createShareText
{
    NSString* shareText = [NSString stringWithFormat:NSLS(@"kConquerDrawShareText"),
                           [PPConfigManager shareAppName],
                           self.score,
                           [self defeatPercent]];
    PPDebug(@"<createShareText> text=%@", shareText);
    return shareText;
}

- (void)shareSNS:(UIView*)superView
{
    NSString* imageFilePath = [self createShareImagePath];
    NSString* text = [self createShareText];
    
    if ([imageFilePath length] == 0){
        POSTMSG(NSLS(@"kCreateImageShareFail"));
        return;
    }

    NSArray *titles = @[TITLE_SHARE_WEIXIN_FRIEND,
                        TITLE_SHARE_WEIXIN_TIMELINE,
                        TITLE_SHARE_SINA_WEIBO,
                        TITLE_SHARE_QQ_WEIBO];
    
    BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:titles callback:^(NSInteger index) {
        NSString *t = titles[index];
        if ([t isEqualToString:TITLE_SHARE_WEIXIN_FRIEND]) {
            
            [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_SESSION
                                                     text:text
                                            imageFilePath:imageFilePath
                                                   inView:superView
                                               awardCoins:0
                                           successMessage:NSLS(@"kShareWeiboSucc")
                                           failureMessage:NSLS(@"kShareWeiboFailure")];
            
        }else if([t isEqualToString:TITLE_SHARE_WEIXIN_TIMELINE]){

            [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_TIMELINE
                                                     text:text
                                            imageFilePath:imageFilePath
                                                   inView:superView
                                               awardCoins:0
                                           successMessage:NSLS(@"kShareWeiboSucc")
                                           failureMessage:NSLS(@"kShareWeiboFailure")];
            
        }
        else if([t isEqualToString:TITLE_SHARE_SINA_WEIBO]){
            
            [[GameSNSService defaultService] publishWeibo:TYPE_SINA
                                                     text:text
                                            imageFilePath:imageFilePath
                                                   inView:superView
                                               awardCoins:0
                                           successMessage:NSLS(@"kShareWeiboSucc")
                                           failureMessage:NSLS(@"kShareWeiboFailure")];

        }
        else if([t isEqualToString:TITLE_SHARE_QQ_WEIBO]){

            [[GameSNSService defaultService] publishWeibo:TYPE_QQ
                                                     text:text
                                            imageFilePath:imageFilePath
                                                   inView:superView
                                               awardCoins:0
                                           successMessage:NSLS(@"kShareWeiboSucc")
                                           failureMessage:NSLS(@"kShareWeiboFailure")];
            
        }
    }];
    [sheet showInView:superView showAtPoint:superView.center animated:YES];
    [sheet release];
}

@end
