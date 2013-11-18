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


@interface GroupDetailController : PPTableViewController<GroupDetailCellDelegate>

+ (GroupDetailController *)enterWithGroup:(PBGroup *)group
                           fromController:(PPViewController *)controller;


@end
