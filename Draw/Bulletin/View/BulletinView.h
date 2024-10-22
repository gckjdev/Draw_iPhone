//
//  BulletinView.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "PPViewController.h"

@interface BulletinView : UIView <UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *bulletinsTableView;
@property (retain, nonatomic) IBOutlet UIButton *downCloseButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UIImageView *topImageView;
@property (retain, nonatomic) IBOutlet UIImageView *downImageView;
@property (assign, nonatomic) UIViewController* superController;
@property (retain, nonatomic) IBOutlet UILabel *noBulletinTips;

//+ (void)showBulletinInController:(PPViewController*)controller;
+ (id)createWithSuperController:(PPViewController *)controller;

@end
