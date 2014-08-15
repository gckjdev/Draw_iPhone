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
@property (retain, nonatomic) IBOutlet UIView *alphaView;

@property (retain, nonatomic) IBOutlet UILabel *tutorialNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (retain, nonatomic) IBOutlet UILabel *tutorialDateLabel;
@property (retain, nonatomic) IBOutlet UIButton *tutorialStartBtn;
@property (retain, nonatomic) IBOutlet UIView *UIImageViewUpView;
@property (retain, nonatomic) IBOutlet UIView *vagueTopImageView;
@property (retain, nonatomic) IBOutlet UIView *labelBottomView;
@property (retain, nonatomic) IBOutlet UILabel *progressInfoLabel;
@property (retain, nonatomic) IBOutlet UILabel *othersProgressInfoLabel;
@property (retain, nonatomic) IBOutlet UIView *progressAndLabelView;
@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;

- (void)updateCellInfo:(PBUserTutorial*)ut WithRow:(NSInteger)row;
@end
