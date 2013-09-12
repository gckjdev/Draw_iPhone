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
#import "ShareImageManager.h"

@interface GuessRankCell()
@property (retain, nonatomic) PBGuessRank *rank;

@end

@implementation GuessRankCell

- (void)dealloc {
    [_rank release];
    [_nickNameLabel release];
    [_signatureLable release];
    [_guessCountLabel release];
    [_costTimeLabel release];
    [_awardLabel release];
    [_rankLabel release];
    [_avatarView release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier{
    
    return @"GuessRankCell";
}

+ (CGFloat)getCellHeight{
    
    return 60 * (ISIPAD ? 2.18 : 1);
}

- (void)setCellInfo:(PBGuessRank *)rank {
    
    self.backgroundColor = [UIColor clearColor];
    
    self.rank = rank;
    
    _nickNameLabel.textColor = COLOR_ORANGE;
    _guessCountLabel.textColor = COLOR_ORANGE;
    _costTimeLabel.textColor = COLOR_ORANGE;
    _awardLabel.textColor = COLOR_ORANGE;
    
    [_avatarView setUrlString:rank.user.avatar];
//    [_avatarView setAsSquare];
    [_avatarView setDelegate:self];
    
    _nickNameLabel.text = rank.user.nickName;
    _signatureLable.text = rank.user.signature;
    
    _guessCountLabel.text = _rank.correctTimesDesc;
    _costTimeLabel.text = _rank.costTimeDesc;
    _awardLabel.text = _rank.earnDesc;
    
    _rankLabel.text = [NSString stringWithFormat:@"%d",rank.ranking];
}

- (void)didClickOnAvatar:(NSString*)userId{
    
    if ([delegate respondsToSelector:@selector(didClickAvatar:)]) {
        [delegate didClickAvatar:_rank];
    }
}

@end
