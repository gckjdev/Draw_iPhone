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
@class Opus;

//typedef enum {
//    ShareContentTypeTextAndImage = 1,
//    SHareContentTypeOnlyText = 2
//    
//} ShareContentType;

@interface CommonShareAction : NSObject<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CustomActionSheetDelegate, ShareEditControllerDelegate, DrawDataServiceDelegate, MyPaintManagerDelegate>

- (id)initWithOpus:(Opus*)opus;

- (void)displayWithViewController:(PPViewController<UserServiceDelegate>*)superViewController;

- (void)displayWithViewController:(PPViewController<UserServiceDelegate>*)superViewController onView:(UIView*)view;

- (void)saveToLocal;
@end
