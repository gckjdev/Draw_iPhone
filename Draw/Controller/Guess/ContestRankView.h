//
//  ContestRankView.h
//  Draw
//
//  Created by 王 小涛 on 13-9-12.
//
//

#import <UIKit/UIKit.h>
#import "Opus.pb.h"

@interface ContestRankView : UIView
@property (retain, nonatomic) IBOutlet UILabel *rankLabel;
@property (retain, nonatomic) IBOutlet UILabel *correctCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *costTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *awardCoinsLabel;

+ (id)createViewWithRank:(PBGuessRank *)rank;

@end
