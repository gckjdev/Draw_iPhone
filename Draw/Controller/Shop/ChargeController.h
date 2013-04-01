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
@property (retain, nonatomic) IBOutlet UILabel *ingotCountLabel;

@property (retain, nonatomic) IBOutlet UIView *taobaoLinkView;
@end
