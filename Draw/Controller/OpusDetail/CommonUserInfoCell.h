//
//  CommonUserInfoCell.h
//  Draw
//
//  Created by 王 小涛 on 13-6-8.
//
//

#import "PPTableViewCell.h"
#import "GameBasic.pb.h"

@interface CommonUserInfoCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *signatureLabel;

- (void)setUserInfo:(PBGameUser *)user;

@end
