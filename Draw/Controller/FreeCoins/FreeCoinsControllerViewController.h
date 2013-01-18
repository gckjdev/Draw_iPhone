//
//  FreeCoinsControllerViewController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-10.
//
//

#import "PPViewController.h"
#import "TapjoyConnect.h"
#import "MoneyTree.h"

@interface FreeCoinsControllerViewController : PPViewController<MoneyTreeDelegate>
@property (retain, nonatomic) IBOutlet MoneyTree *moneyTree;

@property (retain, nonatomic) IBOutlet UILabel *titleTlabel;
@property (retain, nonatomic) IBOutlet UIView *moneyTreeHolderView;
@property (retain, nonatomic) IBOutlet UIView *lmWallBtnHolderView;
@property (retain, nonatomic) IBOutlet UIView *helpBtnHolderView;
@property (retain, nonatomic) IBOutlet UILabel *noteLabel;
@property (retain, nonatomic) IBOutlet UILabel *remainTimesLabel;
@property (retain, nonatomic) IBOutlet UIImageView *cannotGetFreeCoinsImageView;
@property (retain, nonatomic) IBOutlet UILabel *cannotGetFreeCoinsLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

@end
