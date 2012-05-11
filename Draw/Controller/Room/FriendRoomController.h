//
//  FriendRoomController.h
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"

@interface FriendRoomController : PPTableViewController
{
    
}
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *createButton;
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)clickEditButton:(id)sender;
- (IBAction)clickCreateButton:(id)sender;
- (IBAction)clickSearchButton:(id)sender;
- (IBAction)clickMyFriendButton:(id)sender;

@end
