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
    DJQRateView *rateView = (id)[self viewWithTag:type];
    if ([rateView isKindOfClass:[DJQRateView class]]) {
        return rateView.rate;
    }
    return 0;
}

- (NSDictionary *)currentRateDict
{
    NSArray *rankTypes = _contest.pbContest.rankTypesList;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (PBIntKeyValue *rankType in rankTypes) {
        [dict setObject:@([self currentRateForType:rankType.key]) forKey:@(rankType.key)];
    }
    return dict;
}

- (void)updateView
{
    self.infoView = [CustomInfoView createWithTitle:NSLS(@"kContestScore") infoView:self hasCloseButton:YES buttonTitles:@[NSLS(@"kConfirm")]];
    __block JudgerScoreView *cp = self;
    self.infoView.actionBlock = ^(UIButton*button, UIView *infoView){
        //TODO send rate request
        PPDebug(@"Rate feed = %@, in contset = %@", cp.opus.feedId, cp.contest.contestId);
        [(PPViewController *)[cp theViewController] showActivityWithText:NSLS(@"kScoring")];
        
        [[FeedService defaultService] rankOpus:cp.opus.feedId
                                     contestId:cp.contest.contestId
                                          rank:[cp currentRateDict]
                                   resultBlock:^(int resultCode) {
            [(PPViewController *)[cp theViewController] hideActivity];
            if (resultCode == 0) {
                [cp updateRankInfoList];
                [cp dismiss];
            }else{
                PPDebug(@"Rank Failed!!!");
            }
        }];
    };
    
    [self updateRateViews];
}

- (void)updateRateViews
{
    CGFloat lx = 20, ly = 10;
    CGFloat space = 30;
    CGFloat rx = 100;
    //140 40
    for (PBIntKeyValue *rankTypeValue in _contest.pbContest.rankTypesList) {
        NSInteger type = rankTypeValue.key;
        NSString *title = rankTypeValue.value;
        NSInteger rate = [[self myRateWithType:type] value];
        UILabel *name = [self reuseLabelWithTag:type+100
                                           frame:CGRectMake(lx, ly, 1, 30)
                                            font:[UIFont systemFontOfSize:15]
                                            text:title];
        DJQRateView *rateView = (id)[self reuseViewWithTag:type viewClass:[DJQRateView class] frame:CGRectMake(rx, ly+10, 140, 40)];
        rateView.center = CGPointMake(rateView.center.x, name.center.y);
        rateView.rate = rate;
        ly +=  space;
        
    }
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
