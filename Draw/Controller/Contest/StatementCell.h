//
//  StatementCell.h
//  Draw
//
//  Created by 王 小涛 on 14-1-8.
//
//

#import "PPTableViewCell.h"

@interface StatementCell : PPTableViewCell

+ (float)getCellHeightWithContent:(NSString *)content;
- (void)setCellTitle:(NSString *)title content:(NSString *)content;

@end
