//
//  BulletinView.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "CommonInfoView.h"
#import "PPViewController.h"

@interface BulletinView : CommonInfoView <UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *bulletinsTableView;
@property (retain, nonatomic) IBOutlet UIButton *downCloseButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UIImageView *topImageView;
@property (retain, nonatomic) IBOutlet UIImageView *downImageView;

+ (void)showBulletinInController:(PPViewController*)controller;

@end
