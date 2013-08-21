//
//  SearchUserController.h
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"
#import "FriendService.h"
#import "FriendCell.h"
#import "CommonTabController.h"

typedef enum{
    ControllerTypeShowFriend = 0,
    ControllerTypeSelectFriend = 1,
    ControllerTypeInviteFriend = 2,
}ControllerType;

@class SearchUserController;
@protocol SearchUserControllerDelegate <NSObject>

@optional
- (void)searchUserController:(SearchUserController *)controller
             didSelectFriend:(MyFriend *)aFriend;
@end

@interface SearchUserController :CommonTabController <FriendServiceDelegate,UITextFieldDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UIImageView *inputImageView;
@property (retain, nonatomic) IBOutlet UITextField *inputTextField;
@property (assign, nonatomic) id<SearchUserControllerDelegate> delegate;

- (IBAction)clickSearch:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (id)initWithType:(ControllerType)type;

@end
