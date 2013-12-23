//
//  NormalHotCell.h
//  Draw
//
//  Created by 王 小涛 on 13-12-21.
//
//

#import "PPTableViewCell.h"

@interface NormalHotCell : PPTableViewCell

+ (id)createOneRankCell:(id)delegate;
+ (id)createTwoRankCell:(id)delegate;
+ (id)createThreeRankCell:(id)delegate;

+ (NSString *)getOneRankCellIdentifier;
+ (NSString *)getTwoRankCellIdentifier;
+ (NSString *)getThreeRankCellIdentifier;

+ (float)getOneRankCellHeight;
+ (float)getTwoRankCellHeight;
+ (float)getThreeRankCellHeight;

- (void)setCellInfo:(NSArray *)feeds;

@end
