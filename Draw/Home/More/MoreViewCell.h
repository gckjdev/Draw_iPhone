//
//  MoreViewCell.h
//  Draw
//
//  Created by ChaoSo on 14-7-14.
//
//

#import <UIKit/UIKit.h>
#import "StableView.h"
#import "MoreViewController.h"

@interface MoreViewCell : UICollectionViewCell
@property (retain, nonatomic) IBOutlet BadgeView *badgeView;
@property (retain, nonatomic) IBOutlet UIButton *itemButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) int currentRow;
@property (assign, nonatomic) MoreViewController* controller;


-(void)updateMoreCollectionCell:(NSInteger)row;
-(IBAction)clickButton:(id)sender;

@end
