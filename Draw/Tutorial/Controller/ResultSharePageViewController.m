//
//  ResultSharePageViewController.m
//  Draw
//
//  Created by ChaoSo on 14-7-22.
//
//

#import "ResultSharePageViewController.h"
#import "UserManager.h"
#import "UIViewController+BGImage.h"
@interface ResultSharePageViewController ()

@end

@implementation ResultSharePageViewController

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
    [CommonTitleView createTitleView:self.view];
    [COMMONTITLE_VIEW setTitle:NSLS(@"kResultSharePage")];
    [COMMONTITLE_VIEW setTarget:self];
    [COMMONTITLE_VIEW setBackButtonSelector:@selector(clickBack:)];
    [self setDefaultBGImage];
    
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

- (void)dealloc {
    [_opusImageView release];
    [_headImageView release];
    [_descLabel release];
    [_nameLabel release];
    [_shareButton release];
    [_continueButton release];
    [super dealloc];
}
//更新本页面控件
-(void)updateViewWidget{
    //button
    [self.shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [self.shareButton.titleLabel setFont:AD_BOLD_FONT(20, 15)];
    [self.shareButton setFrame:(CGRectMake((ISIPAD ? 75:75),(ISIPAD ? 533:533),110,30))];
    SET_BUTTON_ROUND_STYLE_ORANGE(self.shareButton);
    [self.continueButton setTitle:@"继续闯关" forState:UIControlStateNormal];
    [self.continueButton.titleLabel setFont:AD_BOLD_FONT(20, 15)];
    [self.continueButton setFrame:(CGRectMake((ISIPAD ? 265:260),(ISIPAD ? 533:533),110,30))];
    SET_BUTTON_ROUND_STYLE_ORANGE(self.continueButton);
    
    //Label
    NSMutableAttributedString *desc = [self getDesc];
    [self.nameLabel setText:@"皮皮彭"];
    self.descLabel.attributedText = desc;
    
    //head
    //TODO
//    UserManager* userManager = [UserManager defaultManager];
//    [self.headImageView setAvatarUrl:[userManager avatarURL]
//                           gender:[userManager gender]
//                   useDefaultLogo:NO];
//    self.headImageView.delegate = self;
    [self.headImageView setImage:[UIImage imageNamed:@"xiaoguanka"]];
    [self.headImageView setBackgroundColor:COLOR_BROWN];
    
    //opusImage
    [self.opusImageView setImage:[UIImage imageNamed:@"xiaoguanka"]];
    
}

-(NSMutableAttributedString *)getDesc{
    NSMutableAttributedString *attriString = [[[NSMutableAttributedString alloc] initWithString:@"本次作品得分為78分,耗時58秒\n闖關成功！\n"]autorelease];
    //把this的字体颜色变为红色
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:COLOR_RED
                        range:NSMakeRange(7, 2)];
    [attriString addAttribute:NSFontAttributeName
                        value:AD_FONT(20, 30)
                        range:NSMakeRange(7,2)];
    
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:COLOR_ORANGE
                        range:NSMakeRange(13,2)];
    [attriString addAttribute:NSFontAttributeName
                        value:AD_FONT(20, 30)
                        range:NSMakeRange(13,2)];
    
 
//    [attriString addAttribute:NSForegroundColorAttributeName
//                        value:(id)[UIColor yellowColor].CGColor
//                        range:NSMakeRange(5, 11)];
    return attriString;
}
-(IBAction)clickShareBtn:(id)sender{
    PPDebug(@"This is ShareButton");
}

- (void)viewDidUnload {
    [self setOpusImageView:nil];
    [self setHeadImageView:nil];
    [self setDescLabel:nil];
    [self setNameLabel:nil];
    [self setShareButton:nil];
    [self setContinueButton:nil];
    [super viewDidUnload];
}
@end
