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
#import "AlixPayOrderManager.h"
#import "AliPayManager.h"
#import "NotificationName.h"
#import "TimeUtils.h"
#import "UILabel+Touchable.h"
#import "TaoBaoController.h"
#import "StringUtil.h"
#import "MKBlockActionSheet.h"

#define PRODUCT_ID_BUY_VIP_MONTH    @"PRODUCT_BUY_VIP_MONTH"
#define PRODUCT_ID_BUY_VIP_YEAR     @"PRODUCT_BUY_VIP_YEAR"




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
    
//    [v setRightButtonTitle:NSLS(@"kSave")];
//    [v setRightButtonSelector:@selector(clickSaveButton:)];
    
    [self registerNotificationWithName:NOTIFICATION_ALIPAY_PAY_CALLBACK usingBlock:^(NSNotification *note) {
        [self handleAlipayCallBack:note];
    }];
    
    [self registerNotificationWithName:NOTIFICATION_JUMP_TO_ALIPAY_CLIENT usingBlock:^(NSNotification *note) {
        [self handleJumpToAlipayClient:note];
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
        msg = [NSString stringWithFormat:@"已有%d位热心用户购买会员支持小吉", [[UserManager defaultManager] buyVipUserCount]];
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
        [self showInfo:@"我们为会员特别提供了羽毛笔、雪糕笔、马克笔等4种之前的绝版画笔，让别人观看你的作品的时候，也看到漂亮的画笔。\n\n注：画笔仅提供漂亮趣味外观"];
    }
}

- (void)clickFeatureLabel2:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        [self showInfo:@"我们为会员特别提供了钻石笔、巧克力笔、甜甜圈笔等5种全新画笔，让别人观看你的作品的时候，也看到漂亮的画笔。\n\n注：画笔仅提供漂亮趣味外观"];
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
        [self showInfo:@"VIP会员可创建20级别以上，50级以下的家族"];
    }
}


//- (void)alipayClientPaymentForOrder:(AlixPayOrder *)order
//{
//    [[AccountService defaultService] setDelegate:self];
//    [[[AccountService defaultService] alipayManager] payWithOrder:order
//                                                        appScheme:[GameApp alipayCallBackScheme]
//                                                    rsaPrivateKey:[PPConfigManager getAlipayRSAPrivateKey]];
//}


- (void)alipayForOrder:(AlixPayOrder *)order
{
    if ([PPConfigManager useAlipyaWeb]){
        [self alipayWebPaymentForOrder:order];
    }
    else{
//        [self alipayClientPaymentForOrder:order];
    }
    return;
    
}

- (void)pushTaobao:(NSString *)taobaoUrl
{
    TaoBaoController *controller = [[TaoBaoController alloc] initWithURL:taobaoUrl title:NSLS(@"kTaoBaoChargeTitle")];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


- (NSString*)getTaobaoURL:(NSString*)productId
{
    if ([productId isEqualToString:PRODUCT_ID_BUY_VIP_YEAR]){
        return [PPConfigManager getVipYearTaobaoURL];
    }
    else{
        return [PPConfigManager getVipMonthTaobaoURL];
    }
}

- (void)handlePayFailure:(NSString*)alipayProductId
{    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:@"温馨提示"
                                                       message:@"支付宝支付被取消或者失败了，到官方淘宝店购买吧？"
                                                         style:CommonDialogStyleDoubleButton];
    
    [dialog setClickOkBlock:^(id view){
        [self pushTaobao:[self getTaobaoURL:self.currentProductId]];
    }];
    
    [dialog showInView:self.view];
}

- (void)handleAlipayCallBack:(NSNotification *)note
{
    PPDebug(@"receive message: %@", NOTIFICATION_ALIPAY_PAY_CALLBACK);
    NSDictionary *userInfo = note.userInfo;
    int resultCode = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_CODE] intValue];
//    NSString *msg = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_MESSAGE] intValue];
    AlixPayOrder *order = [userInfo objectForKey:ALIPAY_CALLBACK_RESULT_ORDER];
    NSString *alipayProductId = [AlixPayOrderManager productIdFromTradeNo:order.tradeNO];
    
    if (resultCode == ERROR_SUCCESS) {
        [self showActivityWithText:NSLS(@"kSendingRequest")];
        
        int type = [self getTypeByProductId:alipayProductId];
        
        // purchase VIP here
        [[UserService defaultService] purchaseVipService:type viewController:self resultBlock:^(int resultCode) {
            
            [self hideActivity];            
            if (resultCode == ERROR_SUCCESS){
                POSTMSG(@"已成功购买VIP会员资格");

                [self viewDidAppear:NO];
                [self updateBuyVipCount];
            }
            else{
                POSTMSG2(@"获取VIP会员资格失败，请马上联系客服支持解决问题（可到官方论坛直接反馈）", 3);
            }
            
        }];
        
    }else{
        [self handlePayFailure:alipayProductId];
    }
}

- (void)handleJumpToAlipayClient:(NSNotification *)note
{
    PPDebug(@"receive message: %@", NOTIFICATION_JUMP_TO_ALIPAY_CLIENT);
    NSDictionary *userInfo = note.userInfo;
    int resultCode = [[userInfo objectForKey:ALIPAY_CALLBACK_RESULT_STATUS_CODE] intValue];
    AlixPayOrder *order = [userInfo objectForKey:ALIPAY_CALLBACK_RESULT_ORDER];
    NSString *alipayProductId = [AlixPayOrderManager productIdFromTradeNo:order.tradeNO];
    
    if (resultCode != ERROR_SUCCESS) {
        [self handlePayFailure:alipayProductId];
    }
}

- (AlixPayOrder*)createOrder:(int)amount
                   productId:(NSString*)productId
                 productName:(NSString*)productName
                        type:(int)type
                       value:(int)value
{
    AlixPayOrder *order = [[[AlixPayOrder alloc] init] autorelease];
    order.partner = [PPConfigManager getAlipayPartner];
    order.seller = [PPConfigManager getAlipaySeller];
    order.tradeNO =  [AlixPayOrderManager tradeNoWithProductId:productId];
    order.productName = productName;

    NSString* amountString = [NSString stringWithFormat:@"%d", amount];
    
#ifdef DEBUG
    order.amount = @"0.01";
#else
    order.amount = amountString;
#endif

    PPDebug(@"charge price in RMB is %@, %@", order.amount, amountString);
    
    [[AlixPayOrderManager defaultManager] addOrder:order];
    return order;
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
    NSString* nick = @""; //[[UserManager defaultManager] nickName];
    NSString* name = [NSString stringWithFormat:@"小吉VIP会员包月（%d元/月），谢谢%@对小吉的热心支持！", amount, nick];
    
    AlixPayOrder* order = [self createOrder:amount
                                  productId:PRODUCT_ID_BUY_VIP_MONTH
                                productName:name
                                       type:VIP_BUY_TYPE_MONTH
                                      value:1];
    [self alipayForOrder:order];
}

- (IBAction)clickBuyYear:(id)sender
{
//    if ([[UserManager defaultManager].pbUser vip] == 0 && [[UserService defaultService] vipMonthLeft] == 0){
//        NSDate* nextDate = [NSDate dateWithTimeInterval:7*24*3600 sinceDate:[[UserService defaultService] vipNextOpenDate]];
//
//        NSString* msg = [NSString stringWithFormat:@"本期包年VIP名额已经售完\n下次购买日期为\n%@（%@）",
//                         dateToChineseString(nextDate),
//                         chineseWeekDayFromDate(nextDate)];
//        POSTMSG2(msg, 3);
//        return;
//    }

    
    self.currentProductId = PRODUCT_ID_BUY_VIP_YEAR;

    int amount = [PPConfigManager getVipYearFee];
    NSString* nick = @""; //[[UserManager defaultManager] nickName];
    NSString* name = [NSString stringWithFormat:@"小吉VIP会员包年（%d元/年），谢谢%@对小吉的热心支持！", amount, nick];
    
    AlixPayOrder* order = [self createOrder:amount
                                  productId:PRODUCT_ID_BUY_VIP_YEAR
                                productName:name
                                       type:VIP_BUY_TYPE_YEAR
                                      value:1];
    [self alipayForOrder:order];
}

- (void)updateBuyVipCount
{
    [[UserService defaultService] getBuyVipUserCount:self resultBlock:^(int resultCode) {
        if (resultCode == 0){
            [self viewDidAppear:NO];
        }
    }];
}

- (void)alipayWebPaymentForOrder:(AlixPayOrder *)order
{
    NSString* PRODUCT = @"buyVip";
    
    NSString* url = [PPConfigManager getAlipayWebUrl];
    url = [url stringByAddQueryParameter:METHOD value:@"charge"];
    url = [url stringByAddQueryParameter:PARA_APPID value:[GameApp appId]];
    url = [url stringByAddQueryParameter:PARA_GAME_ID value:[GameApp gameId]];
    url = [url stringByAddQueryParameter:PARA_AMOUNT value:order.amount];
    url = [url stringByAddQueryParameter:PARA_DESC value:order.productName];
    url = [url stringByAddQueryParameter:PARA_XIAOJI_NUMBER value:[[UserManager defaultManager] xiaojiNumber]];

//    url = [url stringByAddQueryParameter:PARA_URL value:product.taobaoUrl];
    url = [url stringByAddQueryParameter:PARA_USERID value:[[UserManager defaultManager] userId]];
    url = [url stringByAddQueryParameter:PARA_TYPE intValue:[self getTypeByProductId:self.currentProductId]];
    url = [url stringByAddQueryParameter:PARA_COUNT intValue:1];
    url = [url stringByAddQueryParameter:PARA_PRODUCT value:PRODUCT];
    
    
    NSString* title = [NSString stringWithFormat:@"%@", order.productName];
    TaoBaoController* vc = [[TaoBaoController alloc] initWithURL:url title:title taobaoURL:[self getTaobaoURL:self.currentProductId]];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

@end
