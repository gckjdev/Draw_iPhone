//
//  CommonActionCell.h
//  Draw
//
//  Created by 王 小涛 on 13-7-1.
//
//

#import "PPTableViewCell.h"
#import "Opus.pb.h"
#import "StableView.h"

@protocol CommonActionCellDelegate <NSObject>

- (void)didClickOnUser:(PBGameUser *)user;
- (void)didClickOnCommentButton:(PBOpusAction *)action;

@end

@interface CommonActionCell : PPTableViewCell<AvatarViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *contentLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *flowerImageView;

+ (CGFloat)getCellHeight:(PBOpusAction *)action;
- (void)setCellInfo:(PBOpusAction *)action;

@end
