//
//  JudgerScoreView.h
//  Draw
//
//  Created by Gamy on 13-8-28.
//
//

#import <UIKit/UIKit.h>
#import "DJQRateView.h"
#import "CustomInfoView.h"
#import "Contest.h"
#import "ContestFeed.h"

@interface JudgerScoreView : UIScrollView

@property (retain, nonatomic) IBOutlet DJQRateView *normalRateView;
@property (retain, nonatomic) CustomInfoView *infoView;

@property (retain, nonatomic) Contest *contest;
@property (retain, nonatomic) ContestFeed *opus;

+ (id)judgerScoreViewWithContest:(Contest *)contest opus:(ContestFeed *)opus;

- (void)showInView:(UIView *)view;
- (void)dismiss;

@end
