//
//  LittleGeeHomeController.h
//  Draw
//
//  Created by Kira on 13-5-8.
//
//

#import "CommonTabController.h"
#import "HomeBottomMenuPanel.h"

typedef enum {
    LittleGeeHomeGalleryTypeAnnual = 0,
    LittleGeeHomeGalleryTypeWeekly,
    LittleGeeHomeGalleryTypeLatest,
    LittleGeeHomeGalleryTypeRecommend,
    LittleGeeHomeGalleryTypeFriend
    
}LittleGeeHomeGalleryType;

@interface LittleGeeHomeController : CommonTabController<HomeBottomMenuPanelDelegate>

@end
