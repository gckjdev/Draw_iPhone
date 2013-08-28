//
//  JudgerScoreView.m
//  Draw
//
//  Created by Gamy on 13-8-28.
//
//

#import "JudgerScoreView.h"
#import "ContestService.h"
#import "FeedService.h"

@implementation JudgerScoreView

- (NSInteger)rateForType:(NSInteger)type
{
    return [[self myRateWithType:type] value];
}

- (PBOpusRank *)myRateWithType:(NSInteger)type
{
    NSString *uid = [[UserManager defaultManager] userId];
    NSArray *ranks = self.opus.rankInfoList;
    for (PBOpusRank *rank in ranks) {
        if ([rank.userId isEqualToString:uid]&& rank.type == type) {
            return rank;
        }
    }
    return nil;
}
- (void)updateRankInfoList
{
    NSArray *rankTypes = _contest.pbContest.rankTypesList;
    NSMutableArray *rates = [NSMutableArray arrayWithArray:self.opus.rankInfoList];
    for (PBIntKeyValue *rankType in rankTypes) {
        PBOpusRank *ork =[self myRateWithType:rankType.key];
        if (ork && ork.value != [self currentRateForType:rankType.key]) {
            NSInteger index = [rates indexOfObject:ork];
            PBOpusRank_Builder *builder = [PBOpusRank builderWithPrototype:ork];
            [builder setValue:[self currentRateForType:rankType.key]];
            PBOpusRank *nr = [builder build];
            [rates replaceObjectAtIndex:index withObject:nr];
        }
    }
    self.opus.rankInfoList = rates;
}

- (NSInteger)currentRateForType:(NSInteger)type
{
    if (type == 1) {
        return self.normalRateView.rate;
    }
    return 0;
}

- (void)updateView
{
    self.infoView = [CustomInfoView createWithTitle:NSLS(@"kContestScore") infoView:self hasCloseButton:YES buttonTitles:@[NSLS(@"kConfirm")]];
    __block JudgerScoreView *cp = self;
    self.infoView.actionBlock = ^(UIButton*button, UIView *infoView){
        //TODO send rate request
        PPDebug(@"Rate feed = %@, in contset = %@", cp.opus.feedId, cp.contest.contestId);
        [(PPViewController *)[cp theViewController] showActivityWithText:NSLS(@"kScoring")];
        [[FeedService defaultService] rankOpus:cp.opus.feedId contestId:cp.contest.contestId rankType:1 rankValue:[cp currentRateForType:1] resultBlock:^(int resultCode) {
            [(PPViewController *)[cp theViewController] hideActivity];
            if (resultCode == 0) {
                [cp updateRankInfoList];
                [cp dismiss];
            }else{
                PPDebug(@"Rank Failed!!!");
            }
        }];
    };
    self.normalRateView.rate = [self rateForType:1];

}


+ (id)judgerScoreViewWithContest:(Contest *)contest opus:(ContestFeed *)opus
{
    JudgerScoreView *view = [self createViewWithXibIdentifier:@"JudgerScoreView"];
    view.contest = contest;
    view.opus = opus;
    [view updateView];
    return view;
}

- (void)showInView:(UIView *)view
{
    [self.infoView showInView:view];
}

- (void)dismiss
{
    [self.infoView dismiss];
}


- (void)dealloc {
    PPRelease(_opus);
    PPRelease(_contest);
    PPRelease(_normalRateView);
    PPRelease(_infoView);    
    [super dealloc];
}
@end
