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

@interface PurchaseVipController ()

@end

@implementation PurchaseVipController

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

    SET_VIEW_ROUND(self.featureLabel5);
    self.featureLabel5.backgroundColor = COLOR_RED;
    
    
    self.featureLabel1.text = @"5种\n绝版画笔";
    self.featureLabel2.text = @"5种\n全新画笔";
    self.featureLabel3.text = @"可创建20级\n以上家族";

    self.featureLabel4.text = @"VIP\n专属标记";
    self.featureLabel5.text = @"VIP\n画家专区";
    self.featureLabel6.text = @"VIP\n作品专区";
    
    self.featureLabel7.text = @"无限鲜花";
    self.featureLabel8.text = @"道具\n全部免费";
    self.featureLabel9.text = @"可创建20级\n以上家族";
        
    self.purchaseYearLabel.text = @"购买包年\n99元/年";
    self.purchaseMonthLabel.text = @"购买包月\n10元/月";
    
//    [v setRightButtonTitle:NSLS(@"kSave")];
//    [v setRightButtonSelector:@selector(clickSaveButton:)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
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
@end
