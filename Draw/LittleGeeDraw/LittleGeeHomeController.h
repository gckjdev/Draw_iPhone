//
//  LittleGeeHomeController.h
//  Draw
//
//  Created by Kira on 13-5-8.
//
//

#import "CommonTabController.h"
#import "HomeBottomMenuPanel.h"
#import "FeedService.h"
#import "UserService.h"
#import "CustomActionSheet.h"
#import "FriendController.h"

typedef enum {
    LittleGeeHomeGalleryTypeAnnual = 0,
    LittleGeeHomeGalleryTypeWeekly,
    LittleGeeHomeGalleryTypeLatest,
    LittleGeeHomeGalleryTypeRecommend,
    LittleGeeHomeGalleryTypeFriend
    
}LittleGeeHomeGalleryType;

@interface LittleGeeHomeController : CommonTabController<HomeBottomMenuPanelDelegate, FeedServiceDelegate, UserServiceDelegate, CustomActionSheetDelegate, FriendControllerDelegate>


@end
