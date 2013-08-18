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
#import "CommonDialog.h"
#import "DrawGameService.h"

@class ShareImageManager;
@class Room;
@interface SearchRoomController : PPTableViewController<RoomServiceDelegate,UITextFieldDelegate, CommonDialogDelegate,DrawGameServiceDelegate>
{
    ShareImageManager *imageManager;
    RoomService *roomService;
    Room *_currentSelectRoom;
    UserManager *_userManager;
    BOOL _isTryJoinGame;    

    
//    BOOL _hasMoreRow;
    NSInteger _currentStartIndex;
//    BOOL _moreCellLoadding;
    NSString *_keyword;

}

- (IBAction)clickSearhButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UIImageView *searchFieldBg;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;
@property (retain, nonatomic) IBOutlet UITextField *searchField;
//@property (retain, nonatomic) Room *selectedRoom;
@end
