//
//  FreeIngotCell.h
//  Draw
//
//  Created by Kira on 13-3-12.
//
//

#import "PPTableViewCell.h"

@class PBAppReward;
@class PBRewardWall;

@interface FreeIngotCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *appImageView;
@property (retain, nonatomic) IBOutlet UILabel *appNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *appDescriptionLabel;
@property (retain, nonatomic) IBOutlet UILabel *rewardCurrencyCountLabel;

@property (retain, nonatomic) IBOutlet UIImageView *rewardCurrencyImageView;
@property (retain, nonatomic) IBOutlet UIImageView *customAccessoryImageView;

- (void)setCellWithPBAppReward:(PBAppReward*)pbAppReward;
- (void)setCellWithPBRewardWall:(PBRewardWall*)pbRewardWall;

@end
