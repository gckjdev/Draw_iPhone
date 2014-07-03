//
//  TaskInfoCell.h
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import <UIKit/UIKit.h>

@interface StageBasicInfoCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *taskNumber;
@property (retain, nonatomic) IBOutlet UIImageView *taskImage;
@property (retain, nonatomic) IBOutlet UILabel *taskName;
@property (retain, nonatomic) IBOutlet UILabel *taskDesc;

@end
