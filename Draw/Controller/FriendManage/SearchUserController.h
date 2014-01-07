//
//  SearchUserController.h
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "FriendService.h"
#import "FriendCell.h"
#import "SearchController.h"


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

@interface SearchUserController :SearchController <FriendServiceDelegate>
{
    
}
@property (assign, nonatomic) id<SearchUserControllerDelegate> delegate;

- (id)initWithType:(ControllerType)type;

@end
