//
//  ChargeController.h
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "ChargeCell.h"
#import "AccountService.h"

@interface ChargeController : PPTableViewController<ChargeCellDelegate, AccountServiceDelegate>
{
    PBGameCurrency _saleCurrency;
}

@property (retain, nonatomic) IBOutlet UIImageView *currencyImageView;
@property (retain, nonatomic) IBOutlet UIImageView *countBgImageView;
@property (retain, nonatomic) IBOutlet UILabel *countLabel;
@property (retain, nonatomic) IBOutlet UIView *taobaoLinkView;
@property (retain, nonatomic) IBOutlet UIButton *restoreButton;

@end
