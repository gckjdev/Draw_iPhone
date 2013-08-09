//
//  GuessSelectCell.h
//  Draw
//
//  Created by 王 小涛 on 13-7-30.
//
//

#import "PPTableViewCell.h"

@protocol GuessSelectCellProtocol <NSObject>

- (void)didClickOpusWithIndex:(int)index;
 
@end


@interface GuessSelectCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UIButton *awardButton;

- (void)setCellInfo:(NSArray *)opuses;
- (void)setCurrentGuessIndex:(int)index;
@end
