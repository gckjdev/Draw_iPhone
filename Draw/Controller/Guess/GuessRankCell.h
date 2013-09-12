//
//  GuessRankCell.h
//  Draw
//
//  Created by 王 小涛 on 13-7-25.
//
//

#import "PPTableViewCell.h"
#import "Opus.pb.h"
#import "StableView.h"

@protocol GuessRankCellDelegate <NSObject>

@optional
- (void)didClickAvatar:(PBGuessRank *)rank;

@end

@interface GuessRankCell : PPTableViewCell<AvatarViewDelegate>;

@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *geniusTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *signatureLable;
@property (retain, nonatomic) IBOutlet UILabel *guessCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *costTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *awardLabel;
@property (retain, nonatomic) IBOutlet UILabel *rankLabel;
@property (retain, nonatomic) IBOutlet UIImageView *awardImageView;

- (void)setCellInfo:(PBGuessRank *)rank;
- (void)hideAwardInfo;

@end
