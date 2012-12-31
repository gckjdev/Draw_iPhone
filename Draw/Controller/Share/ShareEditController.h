//
//  ShareEditController.h
//  Draw
//
//  Created by Orange on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PPViewController.h"
#import "CommonDialog.h"
#import "UserService.h"
#import "PPSNSConstants.h"

typedef enum {
    SINA_WEIBO = TYPE_SINA,
    QQ_WEIBO = TYPE_QQ,
    FACEBOOK = TYPE_FACEBOOK,
}SnsType;

//@class SynthesisView;
@protocol ShareEditControllerDelegate <NSObject>
 @optional
- (void)didPublishSnsMessage:(int)snsType;

@end

@interface ShareEditController : PPViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CommonDialogDelegate, UserServiceDelegate> {
    SnsType _snsType;
}

@property (nonatomic, copy) NSString* imageFilePath;
//@property (retain, nonatomic) IBOutlet UIImageView *patternBar;
@property (nonatomic, copy) NSString* text;
@property (retain, nonatomic) IBOutlet UIImageView *myImageBackground;
@property (retain, nonatomic) UIImage* myImage;
//@property (retain, nonatomic) IBOutlet UIScrollView *patternsGallery;
//@property (retain, nonatomic) NSMutableArray* patternsArray;
@property (retain, nonatomic) IBOutlet UIImageView *myImageView;
@property (retain, nonatomic) IBOutlet UIImageView *paperBackground;
//@property (retain, nonatomic) SynthesisView* infuseImageView;
@property (retain, nonatomic) IBOutlet UIImageView *inputBackground;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UITextView *shareTextField;
@property (retain, nonatomic) IBOutlet UILabel *shareTitleLabel;
@property (assign, nonatomic) BOOL isDrawByMe;
@property (retain, nonatomic) NSString* drawUserId;
@property (assign, nonatomic) id<ShareEditControllerDelegate>delegate;

- (id)initWithImageFile:(NSString*)imageFile
                   text:(NSString*)text 
             isDrawByMe:(BOOL)isDrawByMe 
                snsType:(SnsType)type;
- (id)initWithImageFile:(NSString*)imageFile
                   text:(NSString*)text
             drawUserId:(NSString*)drawUserId 
                snsType:(SnsType)type;
@end
