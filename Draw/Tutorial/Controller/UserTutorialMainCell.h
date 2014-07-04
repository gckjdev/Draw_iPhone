//
//  UserTutorialMainCell.h
//  Draw
//
//  Created by qqn_pipi on 14-6-30.
//
//

#import <UIKit/UIKit.h>
#import "Tutorial.pb.h"

@interface UserTutorialMainCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *tutorialNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (retain, nonatomic) IBOutlet UILabel *tutorialDateLabel;
@property (retain, nonatomic) IBOutlet UIButton *tutorialStartBtn;
@property (retain, nonatomic) IBOutlet UIView *UIImageViewUpView;

- (void)updateCellInfo:(PBUserTutorial*)ut;
@end
