//
//  UserDetailCell.h
//  Draw
//
//  Created by Kira on 13-3-20.
//
//

#import "PPTableViewCell.h"

@class PBGameUser;
@class CommonRoundAvatarView;

@interface UserDetailCell : PPTableViewCell

- (void)setCellWithPBGameUser:(PBGameUser *)pbUser;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *signLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet UILabel *birthLabel;
@property (retain, nonatomic) IBOutlet UILabel *zodiacLabel;
@property (retain, nonatomic) IBOutlet UILabel *bloodTypeLabel;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet CommonRoundAvatarView *avatarView;

@end
