//
//  TaskCell.h
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "StableView.h"

@interface TaskCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *taskDescLabel;
@property (retain, nonatomic) IBOutlet UILabel *taskStatusLabel;
@property (retain, nonatomic) IBOutlet BadgeView *badgeView;


@end
