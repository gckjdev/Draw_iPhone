//
//  FreeCoinsControllerViewController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-10.
//
//

#import "PPViewController.h"
#import "MoneyTreeView.h"
#import "TapjoyConnect.h"

@interface FreeCoinsControllerViewController : PPViewController <MoneyTreeViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *titleTlabel;
@property (retain, nonatomic) IBOutlet UIButton *moneyTreePlaceHolder;
@property (retain, nonatomic) MoneyTreeView *moneyTreeView;

@property (retain, nonatomic) IBOutlet UIView *moneyTreeHolderView;

@property (retain, nonatomic) IBOutlet UIView *lmWallBtnHolderView;

@property (retain, nonatomic) IBOutlet UIView *helpBtnHolderView;
@property (retain, nonatomic) IBOutlet UILabel *noteLabel;
@property (retain, nonatomic) IBOutlet UILabel *remainTimesLabel;

@end
