//
//  ContestRankView.m
//  Draw
//
//  Created by 王 小涛 on 13-9-12.
//
//

#import "ContestRankView.h"
#import "AutoCreateViewByXib.h"


@implementation ContestRankView

AUTO_CREATE_VIEW_BY_XIB(ContestRankView);

- (void)dealloc {
    [_rankLabel release];
    [_correctCountLabel release];
    [_costTimeLabel release];
    [_awardCoinsLabel release];
    [super dealloc];
}

+ (id)createViewWithRank:(PBGuessRank *)rank{
    
    ContestRankView *v = [self createView];
    
    v.rankLabel.textColor = COLOR_BROWN;
    v.correctCountLabel.textColor = COLOR_BROWN;
    v.costTimeLabel.textColor = COLOR_BROWN;
    v.awardCoinsLabel.textColor = COLOR_BROWN;
    
    v.rankLabel.text = [NSString stringWithFormat:NSLS(@"kContestRanking"), rank.ranking];
    v.correctCountLabel.text = [NSString stringWithFormat:NSLS(@"kContestGuessCorrect"), rank.pass];
    v.costTimeLabel.text = [NSString stringWithFormat:NSLS(@"kContestSpendTime"), rank.spendTime];
    v.awardCoinsLabel.text = [NSString stringWithFormat:NSLS(@"kContestEarn"), rank.earn];
    
    return v;
}



@end
