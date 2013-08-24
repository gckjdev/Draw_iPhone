//
//  CommonShareAction.h
//  Draw
//
//  Created by  on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "CustomActionSheet.h"
#import "ShareEditController.h"
#import "DrawDataService.h"
#import "MyPaintManager.h"

typedef enum {
    ShareActionTagAlbum = 100,
    ShareActionTagEmail = 101,
    ShareActionTagWxTimeline = 102,
    ShareActionTagWxFriend = 103,
    ShareActionTagSinaWeibo = 104,
    ShareActionTagQQWeibo = 105,
    ShareActionTagFacebook = 106,
    ShareActionTagFavorite = 107,
    
}ShareActionTag;

@class Opus;

@interface CommonShareAction : NSObject<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CustomActionSheetDelegate, ShareEditControllerDelegate, DrawDataServiceDelegate, MyPaintManagerDelegate>

- (id)initWithOpus:(Opus*)opus;

- (void)displayWithViewController:(PPViewController*)viewController
                           onView:(UIView*)onView;

- (void)displayActionTags:(NSArray *)actionTags
           viewController:(PPViewController *)viewController
                   onView:(UIView *)onView;


- (void)displayActionTags:(NSArray *)actionTags
                shareText:(NSString *)shareText
           viewController:(PPViewController *)viewController
                   onView:(UIView *)onView;

@end
