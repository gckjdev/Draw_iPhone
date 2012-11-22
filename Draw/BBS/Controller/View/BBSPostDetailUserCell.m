//
//  BBSPostDetailUserCell.m
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "BBSPostDetailUserCell.h"
#import "Bbs.pb.h"
#import "UIImageView+WebCache.h"
#import "UserManager.h"
#import "ShareImageManager.h"

@implementation BBSPostDetailUserCell

+ (BBSPostDetailUserCell *)createCell:(id)delegate
{
    NSString *identifier = [BBSPostDetailUserCell getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BBSPostDetailUserCell *view = [topLevelObjects objectAtIndex:0];
//    view.delegate = delegate;
    return  view;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSPostDetailUserCell";
}

+ (CGFloat)getCellHeight
{
    return 60.0f;
}

- (void)updateNickNameWithUser:(PBBBSUser *)user
{
    NSString *nick = user.nickName;
    if ([[UserManager defaultManager] isMe:user.userId]) {
        nick = NSLS(@"kMe");
    }
    [self.nickName setText:nick];
}

- (void)updateAvatarWithUser:(PBBBSUser *)user
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    UIImage *defaultAvatar = user.gender ? [imageManager maleDefaultAvatarImage] : [imageManager femaleDefaultAvatarImage];
    if ([user.avatar length] != 0) {
        NSURL *url = [NSURL URLWithString:user.avatar];
        [self.avatar setImageWithURL:url placeholderImage:defaultAvatar];
    }else{
        [self.avatar setImage:defaultAvatar];
    }
}
- (void)updateCellWithUser:(PBBBSUser *)user
{
    [self updateAvatarWithUser:user];
    [self updateNickNameWithUser:user];
}


- (void)dealloc {
    [_avatar release];
    [_nickName release];
    [super dealloc];
}
@end
