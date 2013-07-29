//
//  GuessRankCell.h
//  Draw
//
//  Created by 王 小涛 on 13-7-25.
//
//

#import "PPTableViewCell.h"
#import "Opus.pb.h"

@interface GuessRankCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *signatureLable;
@property (retain, nonatomic) IBOutlet UILabel *guessCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *costTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *awardLabel;
@property (retain, nonatomic) IBOutlet UILabel *rankLabel;

- (void)setCellInfo:(PBGuessRank *)rank;


@end
