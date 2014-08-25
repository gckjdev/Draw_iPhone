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
+ (float)getHotStyleCellHeightWithIndexPath:(NSIndexPath *)indexPath;

+ (UITableViewCell *)getLastStyleCell:(UITableView *)tableView
                           indexPath:(NSIndexPath *)indexPath
                            delegate:(id)delegate
                            dataList:(NSArray *)dataList;
+ (int)getLastStyleCellCountWithDataCount:(int)count
                               roundingUp:(BOOL)roundingUp;
+ (float)getLastStyleCellHeightWithIndexPath:(NSIndexPath *)indexPath;

+ (UITableViewCell *)getTimelineStyleCell:(UITableView *)tableView
                                indexPath:(NSIndexPath *)indexPath
                                 delegate:(id)delegate
                                 dataList:(NSArray *)dataList;
+ (int)getTimelineStyleCellCountWithDataCount:(int)count;
+ (float)getTimelineStyleCellHeight;

+ (UITableViewCell *)getCommentStyleCell:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id)delegate
                                dataList:(NSArray *)dataList;
+ (int)getCommentStyleCellCountWithDataCount:(int)count;
+ (float)getCommentStyleCellHeightWithDataList:(NSArray *)dataList
                                     indexPath:(NSIndexPath *)indexPath;

+ (UITableViewCell *)getReportStyleCell:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                               delegate:(id)delegate
                               dataList:(NSArray *)dataList
                                contest:(Contest *)contest;
+ (int)getReportStyleCellCountWithDataCount:(int)count;
+ (float)getReportStyleCellheightWithDataList:(NSArray *)dataList
                                    indexPath:(NSIndexPath *)indexPath;



+ (UITableViewCell *)getPrizeStyleCell:(UITableView *)tableView
                             indexPath:(NSIndexPath *)indexPath
                              delegate:(id)delegate
                              dataList:(NSArray *)dataList
                               contest:(Contest *)contest;
+ (int)getPrizeStyleCellCountWithDataCount:(int)count;
+ (float)getPrizeStyleCellHeight;


+ (UITableViewCell *)getContestStyleCell:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id)delegate
                                dataList:(NSArray *)dataList;
+ (int)getContestStyleCellCountWithDataCount:(int)count;
+ (float)getContestStyleCellHeight;



+ (UITableViewCell *)getContestRuleCell:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                               delegate:(id)delegate
                                contest:(Contest *)contest;
+ (int)getContestRuleCellCount;
+ (float)getContestRuleCellHeight:(NSIndexPath *)indexPath
                          contest:(Contest *)contest;



+ (UITableViewCell *)getPrizeStyleTowCell:(UITableView *)tableView
                                indexPath:(NSIndexPath *)indexPath
                                 delegate:(id)delegate
                                 dataList:(NSArray *)dataList;
+ (int)getPrizeStyleTowCellCountWithDataCount:(int)count;
+ (float)getPrizeStyleTowCellheight;
@end
