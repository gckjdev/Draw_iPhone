//
//  UserDetailViewController.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "PPTableViewController.h"
#import "UserDetailProtocol.h"
#import "UserDetailCell.h"
#import "FriendService.h"
#import "ChangeAvatar.h"


@interface UserDetailViewController : PPTableViewController <UserDetailCellDelegate, FriendServiceDelegate, ChangeAvatarDelegate>
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) NSObject<UserDetailProtocol>* detail;

- (id)initWithUserDetail:(id<UserDetailProtocol>)detail;


@end
