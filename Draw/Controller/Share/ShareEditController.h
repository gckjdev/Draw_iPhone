//
//  ShareEditController.h
//  Draw
//
//  Created by Orange on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SNSServiceDelegate.h"
@class SynthesisView;

@interface ShareEditController : UIViewController <UIActionSheetDelegate, SNSServiceDelegate, MFMailComposeViewControllerDelegate>
@property (retain, nonatomic) UIImage* myImage;
@property (retain, nonatomic) IBOutlet UIScrollView *patternsGallery;
@property (retain, nonatomic) NSMutableArray* patternsArray;
@property (retain, nonatomic) IBOutlet UIImageView *myImageView;
@property (retain, nonatomic) IBOutlet SynthesisView* infuseImageView;
@property (retain, nonatomic) IBOutlet UIImageView *inputBackground;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
- (id)initWithImage:(UIImage*)anImage;
@end
