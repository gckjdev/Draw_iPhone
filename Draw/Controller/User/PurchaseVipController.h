//
//  PurchaseVipController.h
//  Draw
//
//  Created by qqn_pipi on 14-1-24.
//
//

#import <UIKit/UIKit.h>
#import "AccountService.h"
#import "PPViewController.h"

@interface PurchaseVipController : PPViewController<AccountServiceDelegate>
@property (retain, nonatomic) IBOutlet UILabel *purchaseDescLabel;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel1;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel2;

@property (retain, nonatomic) IBOutlet UILabel *featureLabel3;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel4;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel5;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel6;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel7;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel8;
@property (retain, nonatomic) IBOutlet UILabel *featureLabel9;

@property (retain, nonatomic) IBOutlet UIButton *purchaseYearButton;
@property (retain, nonatomic) IBOutlet UIButton *purchaseMonthButton;

@property (retain, nonatomic) IBOutlet UILabel *purchaseYearLabel;
@property (retain, nonatomic) IBOutlet UILabel *purchaseMonthLabel;

- (IBAction)clickBuyMonth:(id)sender;
- (IBAction)clickBuyYear:(id)sender;

+ (PurchaseVipController*)enter:(UIViewController*)fromController;

@end
