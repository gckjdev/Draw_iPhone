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

@interface CommonShareAction : NSObject<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CustomActionSheetDelegate, ShareEditControllerDelegate, DrawDataServiceDelegate, MyPaintManagerDelegate>

- (id)initWithOpus:(Opus*)opus;

- (void)displayWithViewController:(PPViewController*)viewController
                           onView:(UIView*)onView;


@end
