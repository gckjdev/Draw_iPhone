//
//  StoreController.h
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "FriendController.h"

@interface StoreController : PPTableViewController <FriendControllerDelegate>

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *chargeButton;


@end
