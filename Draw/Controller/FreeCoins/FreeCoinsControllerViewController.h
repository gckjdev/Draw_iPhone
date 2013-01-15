//
//  FreeCoinsControllerViewController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-10.
//
//

#import "PPViewController.h"
#import "MoneyTreeView.h"

@interface FreeCoinsControllerViewController : PPViewController <MoneyTreeViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *titleTlabel;
@property (retain, nonatomic) IBOutlet UIButton *moneyTreePlaceHolder;
@property (retain, nonatomic) MoneyTreeView *moneyTreeView;
@end
