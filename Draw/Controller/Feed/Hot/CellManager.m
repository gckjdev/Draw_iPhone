//
//  CellManager.m
//  Draw
//
//  Created by 王 小涛 on 13-12-21.
//
//

#import "CellManager.h"
#import "NSArray+Ext.h"
#import "SingHotCell.h"
#import "NormalHotCell.h"
#import "FeedCell.h"
#import "MyCommentCell.h"
#import "Contest.h"
#import "ReportFeedCell.h"
#import "ContestPrizeCell.h"
#import "ContestCell.h"
#import "ContestManager.h"
#import "StatementCell.h"

#define NORMAL_CELL_VIEW_NUMBER 3
#define WHISPER_CELL_VIEW_NUMBER (ISIPAD? 3 : 2)

@implementation CellManager


+ (UITableViewCell *)getHotStyleCell:(UITableView *)tableView
                           indexPath:(NSIndexPath *)indexPath
                            delegate:(id)delegate
                            dataList:(NSArray *)dataList{
    
    if (isSingApp()) {
        
        return [self getSingHotStyleCell:tableView
                               indexPath:indexPath
                                delegate:delegate
                                dataList:dataList];
    }else if (isDrawApp()){
        
        return [self getDrawHotStyleCell:tableView
                               indexPath:indexPath
                                delegate:delegate
                                dataList:dataList];
    }else{
       return nil; 
    }
}

+ (UITableViewCell *)getSingHotStyleCell:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id)delegate
                                dataList:(NSArray *)dataList{
    
    NSString *indentifier = [SingHotCell getCellIdentifier];
    SingHotCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    
    if (cell == nil) {
        cell = [SingHotCell createCell:delegate];
    }
    
    NSArray *feeds = [dataList subarrayWithRangeSafe:NSMakeRange(indexPath.row * WHISPER_CELL_VIEW_NUMBER, WHISPER_CELL_VIEW_NUMBER)];
    [cell setCellInfo:feeds];
    
    return cell;
}

+ (UITableViewCell *)getDrawHotStyleCell:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id)delegate
                                dataList:(NSArray *)dataList{
    
    NormalHotCell *cell = nil;
    NSRange range;
    
    if (indexPath.row == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:[NormalHotCell getOneRankCellIdentifier]];
        if (cell == nil) {
            cell = [NormalHotCell createOneRankCell:delegate];
        }
        range = NSMakeRange(0, 1);
    }else if (indexPath.row == 1){
        
        cell = [tableView dequeueReusableCellWithIdentifier:[NormalHotCell getTwoRankCellIdentifier]];
        if (cell == nil) {
            cell = [NormalHotCell createTwoRankCell:delegate];
        }
        range = NSMakeRange(1, 2);
    }else{
        
        cell = [tableView dequeueReusableCellWithIdentifier:[NormalHotCell getThreeRankCellIdentifier]];
        if (cell == nil) {
            cell = [NormalHotCell createThreeRankCell:delegate];
        }
        
        int start = indexPath.row * NORMAL_CELL_VIEW_NUMBER - NORMAL_CELL_VIEW_NUMBER;
        range = NSMakeRange(start, NORMAL_CELL_VIEW_NUMBER);
    }

    NSArray *feeds = [dataList subarrayWithRangeSafe:range];
    [cell setCellInfo:feeds];

    return cell;
}

+ (int)getHotStyleCellCountWithDataCount:(int)count
                              roundingUp:(BOOL)roundingUp{
    
    if (isSingApp()) {
        
        return [self getSingHotStyleCellCountWithDataCount:count
                                                roundingUp:roundingUp];
    }else if (isDrawApp()){
        
        return [self getDrawHotStyleCellCountWithDataCount:count
                                                roundingUp:roundingUp];
    }
    
    return count;
}

+ (int)getSingHotStyleCellCountWithDataCount:(int)count
                                  roundingUp:(BOOL)roundingUp{
    
    int cellCount = 0;
    
    if (roundingUp) {
        
        cellCount = ceil(count / (float)WHISPER_CELL_VIEW_NUMBER);
    }else{
        
        cellCount = count / WHISPER_CELL_VIEW_NUMBER;
    }
    
    return cellCount;
}

+ (int)getDrawHotStyleCellCountWithDataCount:(int)count
                                  roundingUp:(BOOL)roundingUp{
    
    if (count == 0) {
        
        return 0;
    }else if (count == 1){
        
        return 1;
    }else if (count == 2 || count == 3){
        
        return 2;
    }else{
        
        count -= NORMAL_CELL_VIEW_NUMBER;
        
        if (roundingUp) {
            count = ceil(count / (float)NORMAL_CELL_VIEW_NUMBER) + 2;
        }else{
            count = count / NORMAL_CELL_VIEW_NUMBER + 2;
        }
        
        return count;
    }
}

+ (float)getHotStyleCellHeightWithIndexPath:(NSIndexPath *)indexPath{

    if (isSingApp()) {
        
        return [self getSingHotStyleCellHeight:indexPath];
    }else if (isDrawApp()){
        
        return [self getDrawHotStyleCellHeight:indexPath];
    }else{
        
        return 0;
    }
}

+ (float)getSingHotStyleCellHeight:(NSIndexPath *)indexPath{
    
    return [SingHotCell getCellHeight];
}

+ (float)getDrawHotStyleCellHeight:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        return [NormalHotCell getOneRankCellHeight];
    }else if (indexPath.row == 1){
        return [NormalHotCell getTwoRankCellHeight];
    }else{
        return [NormalHotCell getThreeRankCellHeight];
    }
}

+ (UITableViewCell *)getLastStyleCell:(UITableView *)tableView
                            indexPath:(NSIndexPath *)indexPath
                             delegate:(id)delegate
                             dataList:(NSArray *)dataList{
    
    if (isSingApp()) {
        
        return [self getSingLastStyleCell:tableView
                               indexPath:indexPath
                                delegate:delegate
                                dataList:dataList];
    }else if (isDrawApp()){
        
        return [self getDrawLastStyleCell:tableView
                               indexPath:indexPath
                                delegate:delegate
                                dataList:dataList];
    }else{
        
        return nil;
    }
}

+ (UITableViewCell *)getSingLastStyleCell:(UITableView *)tableView
                                indexPath:(NSIndexPath *)indexPath
                                 delegate:(id)delegate
                                 dataList:(NSArray *)dataList{
    
    return [self getSingHotStyleCell:tableView
                           indexPath:indexPath
                            delegate:delegate
                            dataList:dataList];
}

+ (UITableViewCell *)getDrawLastStyleCell:(UITableView *)tableView
                                indexPath:(NSIndexPath *)indexPath
                                 delegate:(id)delegate
                                 dataList:(NSArray *)dataList{
    
    NormalHotCell *cell = [tableView dequeueReusableCellWithIdentifier:[NormalHotCell getThreeRankCellIdentifier]];
    if (cell == nil) {
        cell = [NormalHotCell createThreeRankCell:delegate];
    }
    
    NSRange range = NSMakeRange(indexPath.row * NORMAL_CELL_VIEW_NUMBER, NORMAL_CELL_VIEW_NUMBER);
    
    NSArray *feeds = [dataList subarrayWithRangeSafe:range];
    [cell setCellInfo:feeds];
    
    return cell;
}

+ (int)getLastStyleCellCountWithDataCount:(int)count
                               roundingUp:(BOOL)roundingUp{
    
    if (isSingApp()) {
        
        return [self getSingLastStyleCellCountWithDataCount:count
                                                 roundingUp:roundingUp];
    }else if (isDrawApp()){
        
        return [self getDrawLastStyleCellCountWithDataCount:count
                                                 roundingUp:roundingUp];
    }else{
        
        return count;
    }
}

+ (int)getSingLastStyleCellCountWithDataCount:(int)count
                                   roundingUp:(BOOL)roundingUp{
    
    int cellCount = 0;
    
    if (roundingUp) {
        
        cellCount = ceil(count / (float)WHISPER_CELL_VIEW_NUMBER);
    }else{
        
        cellCount = count / WHISPER_CELL_VIEW_NUMBER;
    }

    return cellCount;
}

+ (int)getDrawLastStyleCellCountWithDataCount:(int)count
                                   roundingUp:(BOOL)roundingUp{
    
    int cellCount = 0;

    if (roundingUp) {
        
        cellCount = ceil(count / (float)NORMAL_CELL_VIEW_NUMBER);
    }else{
        
        cellCount = count / NORMAL_CELL_VIEW_NUMBER;
    }
    
    return cellCount;
}

+ (float)getLastStyleCellHeightWithIndexPath:(NSIndexPath *)indexPath{
    
    if (isSingApp()) {
        
        return [self getSingLastStyleCellHeight:indexPath];
    }else if (isDrawApp()){
        
        return [self getDrawLastStyleCellHeight:indexPath];
    }else{
        
        return 0;
    }
}

+ (float)getSingLastStyleCellHeight:(NSIndexPath *)indexPath{
    
    return [SingHotCell getCellHeight];
}

+ (float)getDrawLastStyleCellHeight:(NSIndexPath *)indexPath{
    
    return [NormalHotCell getThreeRankCellHeight];
}



+ (UITableViewCell *)getTimelineStyleCell:(UITableView *)tableView
                                indexPath:(NSIndexPath *)indexPath
                                 delegate:(id)delegate
                                 dataList:(NSArray *)dataList{
    
    NSString *CellIdentifier = [FeedCell getCellIdentifier];
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [FeedCell createCell:delegate];
    }
    cell.indexPath = indexPath;
    cell.accessoryType = UITableViewCellAccessoryNone;
    Feed *feed = [dataList objectAtIndex:indexPath.row];
    [feed updateDesc];
    [cell setCellInfo:feed];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

+ (int)getTimelineStyleCellCountWithDataCount:(int)count{
    
    return count;
}

+ (float)getTimelineStyleCellHeight{
    
    return [FeedCell getCellHeight];
}

+ (UITableViewCell *)getCommentStyleCell:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id)delegate
                                dataList:(NSArray *)dataList{
    
    CommentFeed * commentFeed = [dataList objectAtIndex:indexPath.row];
    MyCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyCommentCell getCellIdentifier]];
    if (cell == nil) {
        cell = [MyCommentCell createCell:delegate];
        cell.superViewController = delegate;
    }
    [cell setCellInfo:commentFeed];
    return cell;
}

+ (int)getCommentStyleCellCountWithDataCount:(int)count{
    
    return count;
}

+ (float)getCommentStyleCellHeightWithDataList:(NSArray *)dataList
                                     indexPath:(NSIndexPath *)indexPath{
    
    CommentFeed * commentFeed = [dataList objectAtIndex:indexPath.row];
    return [MyCommentCell  getCellHeight:commentFeed];
}

+ (UITableViewCell *)getReportStyleCell:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                               delegate:(id)delegate
                               dataList:(NSArray *)dataList
                                contest:(Contest *)contest{
    
    NSString *CellIdentifier = [ReportFeedCell getCellIdentifier];
    ReportFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [ReportFeedCell createCell:delegate];
    }
    cell.indexPath = indexPath;
    cell.accessoryType = UITableViewCellAccessoryNone;
    CommentFeed *feed = [dataList objectAtIndex:indexPath.row];
    [feed updateDesc];
    cell.contestId = contest.contestId;
    [cell setCellInfo:feed];
    return cell;
}

+ (int)getReportStyleCellCountWithDataCount:(int)count{
    
    return count;
}

+ (float)getReportStyleCellheightWithDataList:(NSArray *)dataList
                                    indexPath:(NSIndexPath *)indexPath{
    
    return [ReportFeedCell getCellHeightWithFeed:[dataList objectAtIndex:indexPath.row]];
}


+ (UITableViewCell *)getPrizeStyleCell:(UITableView *)tableView
                             indexPath:(NSIndexPath *)indexPath
                              delegate:(id)delegate
                              dataList:(NSArray *)dataList
                               contest:(Contest *)contest{
    
    NSString *CellIdentifier = [ContestPrizeCell getCellIdentifier];
    ContestPrizeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [ContestPrizeCell createCell:delegate];
    }
    cell.indexPath = indexPath;
    if (indexPath.row < [dataList count]) {
        PBUserAward *aw = [dataList objectAtIndex:indexPath.row];
        ContestFeed *opus = [contest getOpusWithAwardType:aw.awardType.key rank:aw.rank];
        [cell setPrize:[self prizeFromAward:aw] title:aw.awardType.value opus:opus];
    }else{
        cell.opus = nil;
    }
    [cell setShowBg:!(indexPath.row & 0x1)];
    return cell;

}

+ (ContestPrize)prizeFromAward:(PBUserAward *)award
{
    PPDebug(@"prize From Award: key = %d, value = %@", award.awardType.key, award.awardType.value);
    if (award.awardType.key == 1) {
        return award.rank;
    }else {
        return ContestPrizeSpecial;
    }
}

+ (int)getPrizeStyleCellCountWithDataCount:(int)count{
    
    return count;
}

+ (float)getPrizeStyleCellHeight{
    
    return [ContestPrizeCell getCellHeight];
}


+ (UITableViewCell *)getContestStyleCell:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id)delegate
                                dataList:(NSArray *)dataList{
    
    ContestCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContestCell getCellIdentifier]];
    if (cell == nil) {
        cell = [ContestCell createCell:delegate];
    }
    
    Contest *contest = [dataList objectAtIndex:indexPath.row];
    [cell setCellInfo:contest];
    return cell;
}

+ (int)getContestStyleCellCountWithDataCount:(int)count{
    
    return count;
}

+ (float)getContestStyleCellHeight{
    
    return [ContestCell getCellHeight];
}



+ (UITableViewCell *)getContestRuleCell:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                               delegate:(id)delegate
                                contest:(Contest *)contest{
    
    StatementCell *cell = [tableView dequeueReusableCellWithIdentifier:[StatementCell getCellIdentifier]];
    if (cell == nil) {
        cell = [StatementCell createCell:self];
    }
    
    if (indexPath.row == 1){
        NSString *contestingTimeDesc = [NSString stringWithFormat:NSLS(@"kContestingTimeIs"), [contest contestingTimeDesc]];
        NSString *votingTimeDesc = [NSString stringWithFormat:NSLS(@"kVotingTimeIs"), [contest votingTimeDesc]];
        
        NSString *content = [[contestingTimeDesc stringByAppendingString:@"\n"] stringByAppendingString:votingTimeDesc];
        [cell setCellTitle:NSLS(@"kTime") content:content];
    }else if (indexPath.row == 0){
        [cell setCellTitle:NSLS(@"kSubject") content:[contest title]];
    }else if (indexPath.row == 2){
        [cell setCellTitle:NSLS(@"kDesc") content:[contest desc]];
    }else if (indexPath.row == 3){
        [cell setCellTitle:NSLS(@"kAward") content:[contest awardRulesDesc]];
    }
    
    cell.indexPath = indexPath;
    
    return cell;
}

+ (int)getContestRuleCellCount{
    
    return 4;
}

+ (float)getContestRuleCellHeight:(NSIndexPath *)indexPath
                          contest:(Contest *)contest{
    
    if(indexPath.row != StatementCellTypeDesc){
        return [StatementCell getCellHeightWithType:indexPath.row];
    }else{
        return [StatementCell getCellHeightWithContent:[contest desc]];
    }
}

@end
