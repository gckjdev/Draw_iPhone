//
//  GroupDetailController.h
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "PPTableViewController.h"
#import "Group.pb.h"

@interface GroupDetailController : PPTableViewController

+ (GroupDetailController *)enterWithGroup:(PBGroup *)group
                           fromController:(PPViewController *)controller;


@end
