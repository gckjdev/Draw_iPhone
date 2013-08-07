//
//  GuessRankCell.m
//  Draw
//
//  Created by 王 小涛 on 13-7-25.
//
//

#import "GuessRankCell.h"
#import "UIImageView+WebCache.h"
#import "PBGuessRank+Extend.h"

@interface GuessRankCell()
@property (retain, nonatomic) PBGuessRank *rank;

@end

@implementation GuessRankCell

- (void)dealloc {
    [_rank release];
    [_avatarImageView release];
    [_nickNameLabel release];
    [_signatureLable release];
    [_guessCountLabel release];
    [_costTimeLabel release];
    [_awardLabel release];
    [_rankLabel release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier{
    
    return @"GuessRankCell";
}

+ (CGFloat)getCellHeight{
    
    return 70;
}

- (void)setCellInfo:(PBGuessRank *)rank{
    
    self.rank = rank;
    
    [_avatarImageView setImageWithURL:[NSURL URLWithString:rank.user.avatar]];
    _nickNameLabel.text = rank.user.nickName;
    _signatureLable.text = rank.user.signature;
    
    _guessCountLabel.text = _rank.correctTimesDesc;
    _costTimeLabel.text = _rank.costTimeDesc;
    _awardLabel.text = _rank.earnDesc;
}

@end
