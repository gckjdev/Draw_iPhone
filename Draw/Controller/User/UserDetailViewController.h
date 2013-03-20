//
//  UserDetailViewController.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "PPTableViewController.h"
#import "UserDetailProtocol.h"

@class PBGameUser;

@protocol UserDetailCellProtocol <NSObject>

- (void)setCellWithPBGameUser:(PBGameUser*)pbUser;

@end

@interface UserDetailViewController : PPTableViewController
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (assign, nonatomic) id<UserDetailProtocol>detail;

- (id)initWithUserDetail:(id<UserDetailProtocol>)detail;

@end
