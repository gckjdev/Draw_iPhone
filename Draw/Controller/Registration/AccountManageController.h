//
//  AccountManageController.h
//  Draw
//
//  Created by Gamy on 13-9-27.
//
//

#import "PPTableViewController.h"
#import "PPTableViewCell.h"

@interface AccountManageController : PPTableViewController

@end


@class AvatarView;
@interface AccountCell : PPTableViewCell

@property (nonatomic, retain) PBGameUser *user;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *xjNumber;

- (void)updateCellWithAccount:(PBGameUser*)user;

@end
