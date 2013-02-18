//
//  ShareEditController.m
//  Draw
//
//  Created by Orange on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareEditController.h"
#import "SynthesisView.h"
#import "ShareImageManager.h"
#import "UIImageUtil.h"
#import "UserManager.h"
#import "GifView.h"
#import "StringUtil.h"
#import "PPDebug.h"
#import "AccountService.h"
#import "DeviceDetection.h"
#import "CommonMessageCenter.h"
#import "MyFriend.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"
#import "PPSNSCommonService.h"
#import "FeedService.h"
#import "ShareService.h"
#import "ConfigManager.h"
#import "UIImageExt.h"

#define PATTERN_TAG_OFFSET 20120403
#define IPAD_INFUSEVIEW_FRAME CGRectMake(31*2.4,130*2.13,259*2.4,259*2.13)
#define IPHONE_INFUSEVIEW_FRAME CGRectMake(31,130,259,259)
#define INFUSE_VIEW_FRAME ([DeviceDetection isIPAD] ? IPAD_INFUSEVIEW_FRAME : IPHONE_INFUSEVIEW_FRAME)

@interface ShareEditController ()
- (IBAction)publish:(id)sender;
- (IBAction)clickBackButon:(id)sender;
@end

@implementation ShareEditController
@synthesize myImage = _myImage;
//@synthesize patternsGallery = _patternsGallery;
//@synthesize patternsArray = _patternsArray;
@synthesize myImageView = _myImageView;
@synthesize paperBackground = _paperBackground;
//@synthesize infuseImageView = _infuseImageView;
@synthesize inputBackground = _inputBackground;
@synthesize shareButton = _shareButton;
@synthesize shareTextField = _shareTextField;
@synthesize imageFilePath = _imageFilePath;
//@synthesize patternBar = _patternBar;
@synthesize text = _text;
@synthesize myImageBackground = _myImageBackground;
@synthesize shareTitleLabel;
@synthesize isDrawByMe = _isDrawByMe;
@synthesize drawUserId = _drawUserId;

- (void)dealloc
{
    [shareTitleLabel release];
    [_imageFilePath release];
    [_text release];
    [_myImage release];
//    [_patternsGallery release];
//   [_patternsArray release];
//    [_infuseImageView release];
    [_inputBackground release];
    [_myImageView release];
    [_shareButton release];
    [_shareTextField release];
    [_myImageBackground release];
//    [_patternBar release];
    [_paperBackground release];
    [_drawUserId release];
    [super dealloc];
}

//- (void)putUpInputDialog
//{
//    if ([DeviceDetection isIPAD]) {
//        [self.shareTextField setFrame:CGRectMake(7*2.4, 50*2.13, 306*2.4, 60*2.13)];
//        [self.inputBackground setFrame:CGRectMake(7*2.4, 50*2.13, 306*2.4, 60*2.13)];
//    } else {
//        [self.shareTextField setFrame:CGRectMake(7, 50, 306, 60)];
//        [self.inputBackground setFrame:CGRectMake(7, 50, 306, 60)];
//    }    
//    [self.view bringSubviewToFront:self.inputBackground];
//    [self.view bringSubviewToFront:self.shareTextField];
////    self.patternBar.hidden = YES;
////    self.patternsGallery.hidden = YES;
//}
//
//- (void)resetInputDialog
//{
//    if ([DeviceDetection isIPAD]) {
//        [self.shareTextField setFrame:CGRectMake(7*2.4, 389*2.13, 306*2.4, 61*2.13)];
//        [self.inputBackground setFrame:CGRectMake(7*2.4, 389*2.13, 306*2.4, 61*2.13)];
//    } else {
//        [self.shareTextField setFrame:CGRectMake(7, 389, 306, 61)];
//        [self.inputBackground setFrame:CGRectMake(7, 389, 306, 61)];
//    }
//    
//    
//}

//- (void)initPatternsWithImagesName:(NSArray*)names
//{
//    for (NSString* name in names) {
//        UIImage* myPettern = [UIImage imageNamed:name];
//        [self.patternsArray addObject:myPettern];
//    }
//        
//}
//
//- (void)initPattenrsGallery
//{
//    float heigth = self.patternsGallery.frame.size.height;
//    
//    UIButton* noPatternButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, heigth, heigth)] autorelease];
//    noPatternButton.tag = PATTERN_TAG_OFFSET;
//    [self.patternsGallery addSubview:noPatternButton];
//    [noPatternButton setTitle:NSLS(@"kNone") forState:UIControlStateNormal];
//    [noPatternButton addTarget:self action:@selector(selectPattern:) forControlEvents:UIControlEventTouchUpInside];
    
    
//    for (int index = 0; index < self.patternsArray.count; index ++) {
//        UIButton* btn = [[[UIButton alloc] initWithFrame:CGRectMake(heigth*index, 0, heigth, heigth)] autorelease];
//        btn.tag = PATTERN_TAG_OFFSET+index;
//        [btn setBackgroundColor:[UIColor whiteColor]];
//        [btn setImage:[_patternsArray objectAtIndex:index] forState:UIControlStateNormal];
//        [self.patternsGallery addSubview:btn];
//        [btn addTarget:self action:@selector(selectPattern:) forControlEvents:UIControlEventTouchUpInside];
//    }
//
//}

//- (void)selectPattern:(id)sender
//{
//    [self resignFirstResponder];
//    UIButton* btn = (UIButton*)sender;
//    if (btn.tag-PATTERN_TAG_OFFSET < self.patternsArray.count){
//        UIImage* patternImage = [_patternsArray objectAtIndex:btn.tag-PATTERN_TAG_OFFSET];
//        [self.infuseImageView setPatternImage:patternImage];
//        
//    }
//  
//}

#pragma mark Navigation Controller

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    [self putUpInputDialog];
    if (![DeviceDetection isIPAD]) {
        [self addBlankView:self.shareTextField];
    }    
    return YES;
}

#pragma mark - UIActionSheetDelegate
enum {
    SAVE_TO_ALBUM = 0,
    SHARE_VIA_EMAIL,
    SHARE_VIA_SINA,
    SHARE_VIA_QQ
};

- (void)updatePhotoView
{
}

- (void)publishWeibo:(NSString*)text imagePath:(NSString*)imagePath
{
    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:_snsType];
    
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishingWeibo") delayTime:5 isHappy:YES];
    NSString* synthesisImagePath = [[ShareService defaultService] synthesisImageFile:imagePath waterMarkText:[ConfigManager getShareImageWaterMark]];
    if (synthesisImagePath != nil) {
        [snsService publishWeibo:text imageFilePath:synthesisImagePath successBlock:^(NSDictionary *userInfo) {
            
            
            PPDebug(@"%@ publish weibo succ", [snsService snsName]);
            int earnCoins = [[AccountService defaultService] rewardForShareWeibo];
            if (earnCoins > 0){
                NSString* msg = [NSString stringWithFormat:NSLS(@"kPublishWeiboSuccAndEarnCoins"), earnCoins];
                [self popupMessage:msg title:nil];
            }
            else{
                //[self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil];
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
            }
            
            // report action, doesn't work here, need to fix later
            /*
             if (_delegate && [_delegate respondsToSelector:@selector(didPublishSnsMessage:)]) {
             [_delegate didPublishSnsMessage:_snsType];
             }
             */
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failureBlock:^(NSError *error) {
            [self hideActivity];
            PPDebug(@"%@ publish weibo failure", [snsService snsName]);
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboFail") delayTime:1 isHappy:NO];
        }];
    }
    
    return;
    
    /*
     [[PPSNSIntegerationService defaultService] publishWeiboToAll:text
     imageFilePath:imagePath
     successBlock:^(int snsType, PPSNSCommonService *snsService, NSDictionary *userInfo) {
     PPDebug(@"%@ publish weibo succ", [snsService snsName]);
     
     [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
     
     int earnCoins = [[AccountService defaultService] rewardForShareWeibo];
     if (earnCoins > 0){
     NSString* msg = [NSString stringWithFormat:NSLS(@"kPublishWeiboSuccAndEarnCoins"), earnCoins];
     [self popupMessage:msg title:nil];
     }
     else{
     //[self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil];
     [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
     }
     [self.navigationController popViewControllerAnimated:YES];
     
     }
     failureBlock:^(int snsType, PPSNSCommonService *snsService, NSError *error) {
     
     PPDebug(@"%@ publish weibo failure", [snsService snsName]);
     [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboFail") delayTime:1 isHappy:NO];
     
     }];
     */
}

- (void)clickOk:(CommonDialog *)dialog
{
    
    [self publishWeibo:self.shareTextField.text imagePath:self.imageFilePath];

    
//    [self hideActivity];
//    if (result == 0){
//        int earnCoins = [[AccountService defaultService] rewardForShareWeibo];
//        if (earnCoins > 0){
//            NSString* msg = [NSString stringWithFormat:NSLS(@"kPublishWeiboSuccAndEarnCoins"), earnCoins];
//            [self popupMessage:msg title:nil];
//        }
//        else{
//            //[self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil];
//            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
//        }
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else{
//        //[self popupMessage:NSLS(@"kPublishWeiboFail") title:nil];
//        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboFail") delayTime:1 isHappy:NO];
//    }
    
    /*
    if ([[UserManager defaultManager] hasBindQQWeibo] && _snsType == QQ_WEIBO){
//        [self showActivityWithText:NSLS(@"kSendingRequest")];
        PPDebug(@"publish to qq!");
        [[QQWeiboService defaultService] publishWeibo:self.shareTextField.text
                                        imageFilePath:self.imageFilePath 
                                             delegate:nil];        
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
        
    }
    
    if ([[UserManager defaultManager] hasBindSinaWeibo] && _snsType == SINA_WEIBO){
//        [self showActivityWithText:NSLS(@"kSendingRequest")];
        PPDebug(@"publish to sina!");
        [[SinaSNSService defaultService] publishWeibo:self.shareTextField.text 
                                        imageFilePath:self.imageFilePath  
                                             delegate:nil];
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
        
    }
    
    if ([[UserManager defaultManager] hasBindFacebook] && _snsType == FACEBOOK){
        [[FacebookSNSService defaultService] publishWeibo:self.shareTextField.text 
                                            imageFilePath:self.imageFilePath  
                                                 delegate:self];        
        
        //[self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil];
        PPDebug(@"publish to facebook!");
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
     */
}

- (IBAction)publish:(id)sender
{
    NSString* path;
    if ([self.imageFilePath hasSuffix:@"gif"]) {
        path = self.imageFilePath;
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        float size = ((NSNumber*)[attributes objectForKey:NSFileSize]).floatValue/1024.0/1024.0;
        if (size > 1.0) {
            NSString* gifNotice = [NSString stringWithFormat:NSLS(@"kGifNotice"),size];
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGifTips") 
                                                               message:gifNotice
                                                                 style:CommonDialogStyleDoubleButton 
                                                             delegate:self];
            [dialog showInView:self.view];
            [self.shareTextField resignFirstResponder];
            return;
        }
        
    } else {
        
        path = self.imageFilePath;
        
        /* rem by Benson, share image directly, improve compose image later
        UIImage* background = [UIImage imageNamed:@"share_bg.png"];
        UIImage* title = [UIImage imageNamed:@"name.png"];
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(48, 90, 224, 25)] autorelease];
        if (self.isDrawByMe) {
            [label setText:NSLS(@"kGuessWhatIDraw")];
        } else {
            [label setText:NSLS(@"kGuessWhatTheyDraw")];
        }
        
        [label setTextAlignment:UITextAlignmentCenter];
        UIGraphicsBeginImageContext(background.size);  

        [background drawInRect:CGRectMake(0, 0, background.size.width, background.size.height)];
        [title drawInRect:CGRectMake(48, 8, 224, 95)];
        [label drawTextInRect:CGRectMake(48, 90, 224, 25)];
        [self.myImage drawInRect:CGRectMake(32, 136, 256, 245)];        
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext(); 

        NSData* imageData = UIImagePNGRepresentation(resultingImage);
        path = [NSString stringWithFormat:@"%@/%@.png", NSTemporaryDirectory(), [NSString GetUUID]];
        BOOL result=[imageData writeToFile:path atomically:YES];
        if (!result) {
            PPDebug(@"creat temp image failed");
            [self popupMessage:NSLS(@"kPublishWeiboFail") title:nil];
            return;
        }
        */
    }
    
    [self publishWeibo:self.shareTextField.text imagePath:path];
    
    /*
    if ([[UserManager defaultManager] hasBindQQWeibo] && _snsType == QQ_WEIBO){
//        [self showActivityWithText:NSLS(@"kSendingRequest")];
        [[QQWeiboService defaultService] publishWeibo:self.shareTextField.text 
                                        imageFilePath:path 
                                             delegate:self];        
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
        PPDebug(@"publish to qq!");
    }
    
    if ([[UserManager defaultManager] hasBindSinaWeibo] && _snsType == SINA_WEIBO){
//        [self showActivityWithText:NSLS(@"kSendingRequest")];
        [[SinaSNSService defaultService] publishWeibo:self.shareTextField.text 
                                        imageFilePath:path 
                                             delegate:nil];
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
        PPDebug(@"publish to sina!");
    }
    
    if ([[UserManager defaultManager] hasBindFacebook] && _snsType == FACEBOOK){
        [[FacebookSNSService defaultService] publishWeibo:self.shareTextField.text 
                                            imageFilePath:path 
                                                 delegate:self];        
        
        //[self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil]; 
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
        [self.navigationController popViewControllerAnimated:YES];
        PPDebug(@"publish to facebook!");
    }
     */
}


- (void)didPublishWeibo:(int)result
{
    [self hideActivity];
    if (result == 0){
        int earnCoins = [[AccountService defaultService] rewardForShareWeibo];
        if (earnCoins > 0){
            NSString* msg = [NSString stringWithFormat:NSLS(@"kPublishWeiboSuccAndEarnCoins"), earnCoins];
            [self popupMessage:msg title:nil]; 
        }
        else{
            //[self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil]; 
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboSucc") delayTime:1 isHappy:YES];
        }
        [self.navigationController popViewControllerAnimated:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(didPublishSnsMessage:)]) {
            [_delegate didPublishSnsMessage:_snsType];
        }
    }
    else{
        //[self popupMessage:NSLS(@"kPublishWeiboFail") title:nil];
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPublishWeiboFail") delayTime:1 isHappy:NO];
    }
    
}

- (IBAction)clickBackButon:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithImageFile:(NSString*)imageFile
                   text:(NSString*)text 
             isDrawByMe:(BOOL)isDrawByMe 
                snsType:(SnsType)type
{
    self = [super init];
    if (self) {
        self.imageFilePath = imageFile;
        self.text = text;
        NSData* data = [NSData dataWithContentsOfFile:imageFile];
        self.myImage = [UIImage imageWithData:data];
        self.isDrawByMe = isDrawByMe;
        _snsType = type;
    }
    return self;
}

- (id)initWithImageFile:(NSString*)imageFile
                   text:(NSString*)text
             drawUserId:(NSString*)drawUserId 
                snsType:(SnsType)type
{
    self = [super init];
    if (self) {
        self.imageFilePath = imageFile;
        self.text = text;
        NSData* data = [NSData dataWithContentsOfFile:imageFile];
        self.myImage = [UIImage imageWithData:data];
        self.drawUserId = drawUserId;
        self.isDrawByMe = ([[UserManager defaultManager].userId isEqualToString:drawUserId]);
        _snsType = type;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        _patternsArray = [[NSMutableArray alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)initShareText
{
    self.shareTextField.text = self.text;
    if (!_isDrawByMe) {
        [[UserService defaultService] getUserSimpleInfoByUserId:self.drawUserId delegate:self];
        [self showActivityWithText:NSLS(@"kQueryingDrawer")];
    } 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shareTitleLabel.text = NSLS(@"kShareWeiboTitle");
    [self.shareButton setTitle:NSLS(@"kShareSend") forState:UIControlStateNormal];
    [self.inputBackground setImage:[[ShareImageManager defaultManager] inputImage]];
    
    if ([self.imageFilePath hasSuffix:@"gif"]){                              
        GifView* view = [[GifView alloc] initWithFrame:self.myImageView.frame
                                                filePath:self.imageFilePath
                                        playTimeInterval:0.3]; 
        [self.paperBackground setHidden:NO];
        [self.view addSubview:view];
        [view release];
        
    }
    else{
        [self.myImageView setImage:self.myImage];
    }        
    [self initShareText];
        
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self addBlankView:self.shareTextField];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
//    [self setPatternsGallery:nil];
    [self setInputBackground:nil];
    [self setMyImageView:nil];
    [self setShareButton:nil];
    [self setShareTextField:nil];
    [self setMyImageBackground:nil];
//    [self setPatternBar:nil];
    [self setPaperBackground:nil];
    [self setMyImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma user service delegate

- (void)didGetUserInfo:(MyFriend *)user resultCode:(NSInteger)resultCode
{
    
    [self hideActivity];
    NSString* publishText = self.text;
    if (user.isQQUser 
        && [[UserManager defaultManager] hasBindQQWeibo]
        && [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired] == NO
        && _snsType == QQ_WEIBO){
        publishText = [publishText stringByAppendingFormat:@" (via@%@)",user.qqId];       
    }
    
    if (user.isSinaUser 
        && [[UserManager defaultManager] hasBindSinaWeibo]
        && [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired] == NO
        && _snsType == SINA_WEIBO){
        publishText = [publishText stringByAppendingFormat:@" (via@%@)",user.sinaNick];
    }
    
    if (user.isFacebookUser 
        && [[UserManager defaultManager] hasBindFacebook]        
        && _snsType == FACEBOOK){
        //publishText = [publishText stringByAppendingString:facebookId];          
    }
    self.shareTextField.text = publishText;
}

@end
