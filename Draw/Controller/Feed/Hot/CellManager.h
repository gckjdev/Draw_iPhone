//
//  CellManager.h
//  Draw
//
//  Created by 王 小涛 on 13-12-21.
//
//

#import <Foundation/Foundation.h>

@class Contest;

@interface CellManager : NSObject

+ (UITableViewCell *)getHotStyleCell:(UITableView *)tableView
                           indexPath:(NSIndexPath *)indexPath
                            delegate:(id)delegate
                            dataList:(NSArray *)dataList;
+ (int)getHotStyleCellCountWithDataCount:(int)count
                              roundingUp:(BOOL)roundingUp;
+ (CGFloat)getHotStyleCellHeightWithIndexPath:(NSIndexPath *)indexPath;

+ (UITableViewCell *)getLastStyleCell:(UITableView *)tableView
                           indexPath:(NSIndexPath *)indexPath
                            delegate:(id)delegate
                            dataList:(NSArray *)dataList;
+ (int)getLastStyleCellCountWithDataCount:(int)count
                               roundingUp:(BOOL)roundingUp;
+ (CGFloat)getLastStyleCellHeightWithIndexPath:(NSIndexPath *)indexPath;

+ (UITableViewCell *)getTimelineStyleCell:(UITableView *)tableView
                                indexPath:(NSIndexPath *)indexPath
                                 delegate:(id)delegate
                                 dataList:(NSArray *)dataList;
+ (int)getTimelineStyleCellCountWithDataCount:(int)count;
+ (CGFloat)getTimelineStyleCellHeight;

+ (UITableViewCell *)getCommentStyleCell:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id)delegate
                                dataList:(NSArray *)dataList;
+ (int)getCommentStyleCellCountWithDataCount:(int)count;
+ (CGFloat)getCommentStyleCellHeightWithDataList:(NSArray *)dataList
                                     indexPath:(NSIndexPath *)indexPath;

+ (UITableViewCell *)getReportStyleCell:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                               delegate:(id)delegate
                               dataList:(NSArray *)dataList
                                contest:(Contest *)contest;
+ (int)getReportStyleCellCountWithDataCount:(int)count;
+ (CGFloat)getReportStyleCellheightWithDataList:(NSArray *)dataList
                                    indexPath:(NSIndexPath *)indexPath;



+ (UITableViewCell *)getPrizeStyleCell:(UITableView *)tableView
                             indexPath:(NSIndexPath *)indexPath
                              delegate:(id)delegate
                              dataList:(NSArray *)dataList
                               contest:(Contest *)contest;
+ (int)getPrizeStyleCellCountWithDataCount:(int)count;
+ (CGFloat)getPrizeStyleCellHeight;


+ (UITableViewCell *)getContestStyleCell:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id)delegate
                                dataList:(NSArray *)dataList;
+ (NSInteger)getContestStyleCellCountWithDataCount:(NSInteger)count;
+ (CGFloat)getContestStyleCellHeight;



+ (UITableViewCell *)getContestRuleCell:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                               delegate:(id)delegate
                                contest:(Contest *)contest;
+ (int)getContestRuleCellCount;
+ (CGFloat)getContestRuleCellHeight:(NSIndexPath *)indexPath
                          contest:(Contest *)contest;



+ (UITableViewCell *)getPrizeStyleTowCell:(UITableView *)tableView
                                indexPath:(NSIndexPath *)indexPath
                                 delegate:(id)delegate
                                 dataList:(NSArray *)dataList;
+ (int)getPrizeStyleTowCellCountWithDataCount:(int)count;
+ (CGFloat)getPrizeStyleTowCellheight;
@end
