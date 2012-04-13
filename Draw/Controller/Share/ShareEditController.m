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
#import "SinaSNSService.h"
#import "FacebookSNSService.h"
#import "QQWeiboService.h"
#import "GifView.h"
#import "StringUtil.h"
#import "PPDebug.h"

#define PATTERN_TAG_OFFSET 20120403

@interface ShareEditController ()

@end

@implementation ShareEditController
@synthesize myImage = _myImage;
@synthesize patternsGallery = _patternsGallery;
@synthesize patternsArray = _patternsArray;
@synthesize myImageView = _myImageView;
@synthesize infuseImageView = _infuseImageView;
@synthesize inputBackground = _inputBackground;
@synthesize shareButton = _shareButton;
@synthesize shareTextField = _shareTextField;
@synthesize imageFilePath = _imageFilePath;
@synthesize text = _text;
@synthesize shareTitleLabel;

- (void)dealloc
{
    [shareTitleLabel release];
    [_imageFilePath release];
    [_text release];
    [_myImage release];
    [_patternsGallery release];
    [_patternsArray release];
    [_infuseImageView release];
    [_inputBackground release];
    [_myImageView release];
    [_shareButton release];
    [_shareTextField release];
    [super dealloc];
}

- (void)putUpInputDialog
{
    [self.shareTextField setFrame:CGRectMake(7, 123, 306, 121)];
    [self.inputBackground setFrame:CGRectMake(7, 123, 306, 121)];
    [self.view bringSubviewToFront:self.inputBackground];
    [self.view bringSubviewToFront:self.shareTextField];
}

- (void)resetInputDialog
{
    [self.shareTextField setFrame:CGRectMake(7, 399, 306, 61)];
    [self.inputBackground setFrame:CGRectMake(7, 399, 306, 61)];
    
}

- (void)initPatternsWithImagesName:(NSArray*)names
{
    for (NSString* name in names) {
        UIImage* myPettern = [UIImage imageNamed:name];
        [self.patternsArray addObject:myPettern];
    }
        
}

- (void)initPattenrsGallery
{
    float heigth = self.patternsGallery.frame.size.height;
    
    UIButton* noPatternButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, heigth, heigth)] autorelease];
    noPatternButton.tag = PATTERN_TAG_OFFSET;
    [self.patternsGallery addSubview:noPatternButton];
    [noPatternButton setTitle:NSLS(@"kNone") forState:UIControlStateNormal];
    [noPatternButton addTarget:self action:@selector(selectPattern:) forControlEvents:UIControlEventTouchUpInside];
    
    
    for (int index = 1; index <= self.patternsArray.count; index ++) {
        UIButton* btn = [[[UIButton alloc] initWithFrame:CGRectMake(heigth*index, 0, heigth, heigth)] autorelease];
        btn.tag = PATTERN_TAG_OFFSET+index;
        [btn setBackgroundImage:[_patternsArray objectAtIndex:index-1] forState:UIControlStateNormal];
        [self.patternsGallery addSubview:btn];
        [btn addTarget:self action:@selector(selectPattern:) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (void)selectPattern:(id)sender
{
    [self resignFirstResponder];
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == PATTERN_TAG_OFFSET) {
        [self.infuseImageView setPatternImage:nil];
        [self.infuseImageView setNeedsDisplay];
    } else if (btn.tag-PATTERN_TAG_OFFSET <= self.patternsArray.count){
        UIImage* patternImage = [_patternsArray objectAtIndex:btn.tag-PATTERN_TAG_OFFSET-1];
        [self.infuseImageView setPatternImage:patternImage];
    }
  
}

#pragma mark Navigation Controller

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self putUpInputDialog];
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

- (IBAction)publish:(id)sender
{
    UIImage* image = [self.infuseImageView createImage];
    NSData* imageData = UIImagePNGRepresentation(image);
    NSString* path = [NSString stringWithFormat:@"%@/%@.png", NSTemporaryDirectory(), [NSString GetUUID]];
    BOOL result=[imageData writeToFile:path atomically:YES];
    if (!result) {
        PPDebug(@"creat temp image failed");
        return;
    }
    if ([[UserManager defaultManager] hasBindQQWeibo]){
        [self showActivityWithText:NSLS(@"kSendingRequest")];
        [[QQWeiboService defaultService] publishWeibo:self.shareTextField.text 
                                        imageFilePath:path 
                                             delegate:self];        
    }
    
    if ([[UserManager defaultManager] hasBindSinaWeibo]){
        [self showActivityWithText:NSLS(@"kSendingRequest")];
        [[SinaSNSService defaultService] publishWeibo:self.shareTextField.text 
                                        imageFilePath:path 
                                             delegate:self];
    }
    
    if ([[UserManager defaultManager] hasBindFacebook]){
        [[FacebookSNSService defaultService] publishWeibo:self.shareTextField.text 
                                            imageFilePath:path 
                                                 delegate:self];        
        
        [self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil];        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didPublishWeibo:(int)result
{
    [self hideActivity];
    if (result == 0){
        [self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil];        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self popupMessage:NSLS(@"kPublishWeiboFail") title:nil];
    }
    
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithImageFile:(NSString*)imageFile
                         text:(NSString*)text
{
    self = [super init];
    if (self) {
        self.imageFilePath = imageFile;
        self.text = text;
        NSData* data = [NSData dataWithContentsOfFile:imageFile];
        self.myImage = [UIImage imageWithData:data];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _patternsArray = [[NSMutableArray alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPatternsWithImagesName:[NSArray arrayWithObjects:@"pic_template1", @"pic_template2", @"pic_template3",  @"pic_template4", @"pic_template5", nil]];
    [self initPattenrsGallery];
    
    
    self.shareTitleLabel.text = NSLS(@"kShareWeiboTitle");
    [self.shareButton setTitle:NSLS(@"kShareSend") forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] 
                                forState:UIControlStateNormal];
    [self.inputBackground setImage:[[ShareImageManager defaultManager] inputImage]];
    
    if ([self.imageFilePath hasSuffix:@"gif"]){                              
        GifView* view = [[GifView alloc] initWithFrame:self.myImageView.frame
                                                filePath:self.imageFilePath
                                        playTimeInterval:0.3];    
        [self.view addSubview:view];
    }
    else{
        [self.myImageView setImage:self.myImage];
        _infuseImageView = [[SynthesisView alloc] init];
        [self.infuseImageView setDrawImage:self.myImage];
        [self.infuseImageView setFrame:self.myImageView.frame];
        [self.view addSubview:self.infuseImageView];
        [self.infuseImageView setPatternImage:nil];
        [self.infuseImageView setNeedsDisplay];
    }        
    
    self.shareTextField.text = self.text;    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self addBlankView:self.shareTextField];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setPatternsGallery:nil];
    [self setInputBackground:nil];
    [self setMyImageView:nil];
    [self setShareButton:nil];
    [self setShareTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
