//
//  GroupDetailController.h
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "PPTableViewController.h"
#import "Group.pb.h"
#import "GroupDetailCell.h"
#import "BBSActionSheet.h"
#import "FriendController.h"

@interface GroupDetailController : PPTableViewController<GroupDetailCellDelegate, FriendControllerDelegate>

+ (GroupDetailController *)enterWithGroup:(PBGroup *)group
                           fromController:(PPViewController *)controller;


@end
