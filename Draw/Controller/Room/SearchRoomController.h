//
//  SearchRoomController.h
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "RoomService.h"

@class ShareImageManager;

@interface SearchRoomController : PPTableViewController<RoomServiceDelegate,UITextFieldDelegate>
{
    ShareImageManager *imageManager;
    RoomService *roomService;
}

- (IBAction)clickSearhButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UITextField *searchField;
@end
