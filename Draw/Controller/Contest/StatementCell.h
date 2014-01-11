//
//  StatementCell.h
//  Draw
//
//  Created by 王 小涛 on 14-1-8.
//
//

#import "PPTableViewCell.h"


typedef enum{
    StatementCellTypeTitle = 0,
    StatementCellTypeTime = 1,
    StatementCellTypeDesc,
    StatementCellTypeAward,
}StatementCellType;

@interface StatementCell : PPTableViewCell

+ (float)getCellHeightWithType:(StatementCellType)type;

+ (float)getCellHeightWithContent:(NSString *)content;
- (void)setCellTitle:(NSString *)title content:(NSString *)content;

@end
