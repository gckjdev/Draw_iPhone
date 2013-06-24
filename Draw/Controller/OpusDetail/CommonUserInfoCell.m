//
//  CommonUserInfoCell.m
//  Draw
//
//  Created by 王 小涛 on 13-6-8.
//
//

#import "CommonUserInfoCell.h"
#import "UIImageView+WebCache.h"
#import "UIViewUtils.h"

@implementation CommonUserInfoCell

- (void)dealloc {
    [_avatarImageView release];
    [_nickNameLabel release];
    [_signatureLabel release];

    [super dealloc];
}

- (void)setUserInfo:(PBGameUser *)user{
    
    NSURL *url = [NSURL URLWithString:user.avatar];
    [self.avatarImageView setImageWithURL:url placeholderImage:nil];
    if ([user hasSignature]) {
        self.nickNameLabel.text = user.nickName;
        self.signatureLabel.text = user.signature;
    }else{
        [self.signatureLabel removeFromSuperview];
        self.nickNameLabel.text = user.nickName;
        [self.nickNameLabel updateCenterY:_avatarImageView.center.y];
    }
}

@end
