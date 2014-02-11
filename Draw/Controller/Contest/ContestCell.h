//
//  ContestCell.h
//  Draw
//
//  Created by 王 小涛 on 13-12-24.
//
//

#import "PPTableViewCell.h"

@class Contest;
@class PBGroup;

@protocol ContestCellDelegate <NSObject>

- (void)didClickGroup:(PBGroup *)pbGroup;
- (void)didClickContest:(Contest *)contest;

@end

@interface ContestCell : PPTableViewCell

- (void)setCellInfo:(Contest *)contest;
- (void)showAward;

@end
