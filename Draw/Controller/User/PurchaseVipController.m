//
//  PurchaseVipController.m
//  Draw
//
//  Created by qqn_pipi on 14-1-24.
//
//

#import "PurchaseVipController.h"
#import "CommonTitleView.h"
#import "UIViewController+BGImage.h"
#import "AccountService.h"
#import "PPConfigManager.h"
#import "NotificationName.h"
#import "TimeUtils.h"
#import "UILabel+Touchable.h"
#import "StringUtil.h"
#import "MKBlockActionSheet.h"

#define PRODUCT_ID_BUY_VIP_MONTH    @"VIP_MONTH"
#define PRODUCT_ID_BUY_VIP_YEAR     @"VIP_YEAR"




@interface PurchaseVipController ()

@end

@implementation PurchaseVipController

+ (PurchaseVipController*)enter:(PPViewController*)fromController
{
    if ([PPConfigManager isInReviewVersion]){
        POSTMSG(NSLS(@"kTaskVipUnderDev"));
        return nil;
    }
    
    if ([[UserManager defaultManager].pbUser vip]){
        
        // still need to sync info
        [[UserService defaultService] getVipPurchaseInfo:nil];
        
        // already VIP, enter directly
        PurchaseVipController* vc = [[PurchaseVipController alloc] init];
        [fromController.navigationController pushViewController:vc animated:YES];
        [vc release];
        return vc;
    }
    
    [fromController showActivityWithText:NSLS(@"kLoading")];
    [[UserService defaultService] getVipPurchaseInfo:^(int resultCode) {
        [fromController hideActivity];
        if (resultCode == 0){
            if ([[UserService defaultService] canBuyVip] == NO){
                NSString* msg = [NSString stringWithFormat:@"还未到VIP购买日期 ^-^\n下一个购买开放日期是\n%@（%@）",
                                 dateToChineseString([[UserService defaultService] vipNextOpenDate]),
                                 chineseWeekDayFromDate([[UserService defaultService] vipNextOpenDate])];
                
                POSTMSG2(msg, 3);
                return;
            }
            
            PurchaseVipController* vc = [[PurchaseVipController alloc] init];
            [fromController.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        else{
            POSTMSG(NSLS(@"kSystemFailure"));
        }
    }];
    
    return nil;

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
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    [v setTarget:self];
    [v setBackButtonSelector:@selector(clickBack:)];
    [v setTransparentStyle];
    
    [self setDefaultBGImage];

    UIFont* featureFont = [UIFont boldSystemFontOfSize:(ISIPAD ? 26 : 14)];
    float radius = (ISIPAD ? 10  : 6);

    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel1, radius);
    self.featureLabel1.backgroundColor = COLOR_YELLOW;

    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel2, radius);
    self.featureLabel2.backgroundColor = COLOR_BLUE;

    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel3, radius);
    self.featureLabel3.backgroundColor = COLOR_YELLOW;

    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel4, radius);
    self.featureLabel4.backgroundColor = COLOR_GREEN;
    
    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel5, radius);
    self.featureLabel5.backgroundColor = COLOR_RED;
    
    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel6, radius);
    self.featureLabel6.backgroundColor = COLOR_GREEN;

    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel7, radius);
    self.featureLabel7.backgroundColor = COLOR_BLUE;

    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel8, radius);
    self.featureLabel8.backgroundColor = COLOR_YELLOW;

    SET_VIEW_ROUND_CORNER_RADIUS(self.featureLabel9, radius);
    self.featureLabel9.backgroundColor = COLOR_BLUE;
    
    self.featureLabel1.text = @"模糊笔\n土豪钢笔";
    self.featureLabel2.text = @"蜡笔、铅笔\n羽毛笔";
    self.featureLabel3.text = @"每月\n29999金币";

    self.featureLabel4.text = @"VIP\n专属标记";
    self.featureLabel5.text = @"VIP\n作品专区";
    self.featureLabel6.text = @"重复编辑\n已上传作品";
    
    self.featureLabel7.text = @"无限鲜花";
    self.featureLabel8.text = @"道具\n全部免费";
    self.featureLabel9.text = @"创建4个\n以上图层";
        
    self.purchaseYearLabel.text = @"包年购买\n99元/年";
    self.purchaseMonthLabel.text = @"包月购买\n10元/月";
    
    self.purchaseDescLabel.textColor = COLOR_BROWN;
    
    self.featureLabel1.font =
    self.featureLabel2.font =
    self.featureLabel3.font =
    self.featureLabel4.font =
    self.featureLabel5.font =
    self.featureLabel6.font =
    self.featureLabel7.font =
    self.featureLabel8.font =
    self.featureLabel9.font = featureFont;
    
    [self.featureLabel1 enableTapTouch:self selector:@selector(clickFeatureLabel1:)];
    [self.featureLabel2 enableTapTouch:self selector:@selector(clickFeatureLabel2:)];
    [self.featureLabel3 enableTapTouch:self selector:@selector(clickFeatureLabel3:)];
    [self.featureLabel4 enableTapTouch:self selector:@selector(clickFeatureLabel4:)];
    [self.featureLabel5 enableTapTouch:self selector:@selector(clickFeatureLabel5:)];
    [self.featureLabel6 enableTapTouch:self selector:@selector(clickFeatureLabel6:)];
    [self.featureLabel7 enableTapTouch:self selector:@selector(clickFeatureLabel7:)];
    [self.featureLabel8 enableTapTouch:self selector:@selector(clickFeatureLabel8:)];
    [self.featureLabel9 enableTapTouch:self selector:@selector(clickFeatureLabel9:)];
    
    [self.purchaseMonthLabel setFont:featureFont];
    [self.purchaseYearLabel setFont:featureFont];
    
    [self registerNotificationWithName:NOTIFICATION_SYNC_ACCOUNT usingBlock:^(NSNotification *note) {
        [self updateVipInfo];
    }];
    
    [self updateBuyVipCount];
}

- (void)updateVipInfo
{
    NSString* msg;
    NSDate* expireDate = [NSDate dateWithTimeIntervalSince1970:[UserManager defaultManager].pbUser.vipExpireDate];
    if ([[UserManager defaultManager].pbUser vip] && expireDate){
        NSString* expireDateString = dateToChineseStringByFormat(expireDate, @"yyyy年MM月dd日");
        if ([[UserManager defaultManager] isVip]){
            msg = [NSString stringWithFormat:@"已是小吉VIP，到期日为%@", expireDateString];
        }
        else{
            msg = [NSString stringWithFormat:@"你的小吉VIP已经于%@到期", expireDateString];
        }
        
        self.purchaseYearLabel.text = @"包年续费\n99元/年";
        self.purchaseMonthLabel.text = @"包月续费\n10元/月";
        
    }
    else{
        msg = [NSString stringWithFormat:@"已有%d位用户购买会员", [[UserManager defaultManager] buyVipUserCount]];
    }
    
    self.purchaseDescLabel.text = msg;}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateVipInfo];

    [[AccountService defaultService] syncAccountWithResultHandler:^(int resultCode) {
        if (resultCode == 0){
            [self updateVipInfo];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_currentProductId release];
    [_purchaseDescLabel release];
    [_featureLabel1 release];
    [_featureLabel2 release];
    [_featureLabel3 release];
    [_featureLabel4 release];
    [_featureLabel5 release];
    [_featureLabel6 release];
    [_featureLabel7 release];
    [_featureLabel8 release];
    [_featureLabel9 release];
    [_purchaseYearButton release];
    [_purchaseMonthButton release];
    [_purchaseYearLabel release];
    [_purchaseMonthLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPurchaseDescLabel:nil];
    [self setFeatureLabel1:nil];
    [self setFeatureLabel2:nil];
    [self setFeatureLabel3:nil];
    [self setFeatureLabel4:nil];
    [self setFeatureLabel5:nil];
    [self setFeatureLabel6:nil];
    [self setFeatureLabel7:nil];
    [self setFeatureLabel8:nil];
    [self setFeatureLabel9:nil];
    [self setPurchaseYearButton:nil];
    [self setPurchaseMonthButton:nil];
    [self setPurchaseYearLabel:nil];
    [self setPurchaseMonthLabel:nil];
    [super viewDidUnload];
}

- (void)showInfo:(NSString*)msg
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:@"会员功能说明"
                                                       message:msg
                                                         style:CommonDialogStyleSingleButton];
    [dialog showInView:self.view];
}

- (void)clickFeatureLabel1:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"我们为会员特别提供了羽毛笔、钢笔、蜡笔等多种画笔，让别人观看你的作品的时候，也看到漂亮的画笔。"];
    }
}

- (void)clickFeatureLabel2:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"我们为会员特别提供了毛笔、铅笔等多种全新画笔，让别人观看你的作品的时候，也看到漂亮的画笔。"];
    }
}

- (void)clickFeatureLabel3:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"购买会员后，每个月增加29999金币（价值超过人民币20元），目前会一次性全部支付给用户"];
    }
}

- (void)clickFeatureLabel4:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"展示会员头像时候，会展示VIP会员专属标记"];
    }
}



- (void)clickFeatureLabel5:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"VIP会员在画家入口中，会有专属版块展示，给你增加更多的粉丝"];
    }
}

- (void)clickFeatureLabel6:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"VIP会员在画榜会有专属版块展示，让你的作品给更多的用户看到"];
    }
}

- (void)clickFeatureLabel7:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"VIP会员送花的时候，无需花费任何金币"];
    }
}

- (void)clickFeatureLabel8:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"VIP会员免费使用所有绘画道具"];
    }
}

- (void)clickFeatureLabel9:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"VIP会员可创建5级别以上，50级以下的家族"];
    }
}


- (int)getTypeByProductId:(NSString*)pid
{
    if ([pid isEqualToString:PRODUCT_ID_BUY_VIP_YEAR]){
        return VIP_BUY_TYPE_YEAR;
    }
    else{
        return VIP_BUY_TYPE_MONTH;
    }
}

- (void)choosePaymentForMonth
{
    MKBlockActionSheet* as = [[MKBlockActionSheet alloc] initWithTitle:@"请选择支付方式" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"支付宝" otherButtonTitles:@"淘宝", nil];
    
    [as showInView:self.view];
    [as release];
}

- (IBAction)clickBuyMonth:(id)sender
{
    if ([[UserManager defaultManager].pbUser vip] == 0 && [[UserService defaultService] vipMonthLeft] == 0){
        
        NSDate* nextDate = [NSDate dateWithTimeInterval:7*24*3600 sinceDate:[[UserService defaultService] vipNextOpenDate]];
        
        NSString* msg = [NSString stringWithFormat:@"本期包月VIP名额已经售完\n下次购买日期为\n%@（%@）",
                         dateToChineseString(nextDate),
                         chineseWeekDayFromDate(nextDate)];
        POSTMSG2(msg, 3);
        return;
    }
    
    self.currentProductId = PRODUCT_ID_BUY_VIP_MONTH;
    
    int amount = [PPConfigManager getVipMonthFee];
    NSString* name = [NSString stringWithFormat:@"小吉VIP会员包月（%d元/月），马上成为VIP，享受更多小吉特权！", amount];

    // TODO change to apple subscription payment
    PPDebug(@"click buy month, shift to apple subscription based charging");
}

- (IBAction)clickBuyYear:(id)sender
{
    self.currentProductId = PRODUCT_ID_BUY_VIP_YEAR;

    int amount = [PPConfigManager getVipYearFee];
    NSString* name = [NSString stringWithFormat:@"小吉VIP会员包年（%d元/年），马上成为VIP，享受更多小吉特权！", amount];

    // TODO change to apple subscription payment
    PPDebug(@"click buy year, shift to apple subscription based charging");

}

- (void)updateBuyVipCount
{
    [[UserService defaultService] getBuyVipUserCount:self resultBlock:^(int resultCode) {
        if (resultCode == 0){
            [self viewDidAppear:NO];
        }
    }];
}

@end
