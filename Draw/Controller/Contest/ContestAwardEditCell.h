//
//  ContestAwardEditCell.h
//  Draw
//
//  Created by 王 小涛 on 14-1-3.
//
//

#import "PPTableViewCell.h"

@protocol ContestAwardEditCellDelegate <NSObject>

- (void)didEditRow:(int)row award:(int)award;

@end

@interface ContestAwardEditCell : PPTableViewCell<UITextFieldDelegate>

- (void)setRank:(NSString *)rank award:(int)award;

@end
