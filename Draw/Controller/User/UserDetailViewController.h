//
//  UserDetailViewController.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "PPTableViewController.h"
#import "UserDetailProtocol.h"

@interface UserDetailViewController : PPTableViewController
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) NSObject<UserDetailProtocol>* detail;

- (id)initWithUserDetail:(id<UserDetailProtocol>)detail;


@end
