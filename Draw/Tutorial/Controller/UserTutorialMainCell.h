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

- (void)updateCellInfo:(PBUserTutorial*)ut;

@end
