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
#import "PPViewController.h"
#import "CommonDialog.h"

@class SynthesisView;

@interface ShareEditController : PPViewController <UIActionSheetDelegate, SNSServiceDelegate, MFMailComposeViewControllerDelegate, CommonDialogDelegate>

@property (nonatomic, copy) NSString* imageFilePath;
@property (retain, nonatomic) IBOutlet UIImageView *patternBar;
@property (nonatomic, copy) NSString* text;
@property (retain, nonatomic) IBOutlet UIImageView *myImageBackground;
@property (retain, nonatomic) UIImage* myImage;
@property (retain, nonatomic) IBOutlet UIScrollView *patternsGallery;
@property (retain, nonatomic) NSMutableArray* patternsArray;
@property (retain, nonatomic) IBOutlet UIImageView *myImageView;
@property (retain, nonatomic) IBOutlet SynthesisView* infuseImageView;
@property (retain, nonatomic) IBOutlet UIImageView *inputBackground;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UITextView *shareTextField;
@property (retain, nonatomic) IBOutlet UILabel *shareTitleLabel;

- (id)initWithImageFile:(NSString*)imageFile
                   text:(NSString*)text;
@end
