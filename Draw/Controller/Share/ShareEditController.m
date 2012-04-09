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
#import "GifView.h"

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

- (void)dealloc
{
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

- (void)initPatterns
{
    UIImage* myPettern = [UIImage imageNamed:@"guess_pattern.png"];
    [self.patternsArray addObject:myPettern];
}

- (void)initPattenrsGallery
{
    float heigth = self.patternsGallery.frame.size.height;
    
    UIButton* noPatternButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, heigth, heigth)] autorelease];
    noPatternButton.tag = PATTERN_TAG_OFFSET;
    [self.patternsGallery addSubview:noPatternButton];
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
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == PATTERN_TAG_OFFSET) {
        [self.infuseImageView setPatternImage:nil];
        [self.infuseImageView setNeedsDisplay];
    } else {
        UIImage* patternImage = [_patternsArray objectAtIndex:0];
        [self.infuseImageView setPatternImage:patternImage];
    }
  
}

#pragma mark Navigation Controller

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate
enum {
    SAVE_TO_ALBUM = 0,
    SHARE_VIA_EMAIL,
    SHARE_VIA_SINA,
    SHARE_VIA_QQ
};
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case SAVE_TO_ALBUM: {
            UIImageWriteToSavedPhotosAlbum(self.myImage, nil, nil, nil);
        } break;
        case SHARE_VIA_EMAIL: {
            MFMailComposeViewController * compose = [[MFMailComposeViewController alloc] init];
            [compose setSubject:@"Gif Image"];
            [compose setMessageBody:@"I have kindly attached a GIF image to this E-mail. I made this GIF using ANGif, an open source Objective-C library for exporting animated GIFs." isHTML:NO];
            [compose addAttachmentData:[UIImage compressImage:self.myImage byQuality:0.3] mimeType:@"image/png" fileName:@"image.png"];
            [compose setMailComposeDelegate:self];
            [self presentModalViewController:compose animated:YES];
        } break;
        case SHARE_VIA_SINA: {
            
        } break;
        case SHARE_VIA_QQ: {
            
        } break;
        default:
            break;
    }
}


- (void)updatePhotoView
{
}

- (IBAction)publish:(id)sender
{
    if ([[UserManager defaultManager] hasBindQQWeibo]){
        
    }
    
    if ([[UserManager defaultManager] hasBindSinaWeibo]){
        [self showActivityWithText:NSLS(@"kSendingRequest")];
        [[SinaSNSService defaultService] publishWeibo:self.shareTextField.text imageFilePath:_imageFilePath delegate:self];
    }
    
    if ([[UserManager defaultManager] hasBindFacebook]){
        
    }
}

- (void)didPublishWeibo:(int)result
{
    [self hideActivity];
    if (result == 0){
        [self popupMessage:NSLS(@"kPublishWeiboSucc") title:nil];        
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
//    [self initPatterns];
//    [self initPattenrsGallery];
//    [self.infuseImageView setDrawImage:self.myImage];
    [self.shareButton setTitle:NSLS(@"kShareSend") forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] forState:UIControlStateNormal];
    [self.inputBackground setImage:[[ShareImageManager defaultManager] inputImage]];
    
    if ([self.imageFilePath hasSuffix:@"gif"]){                              
        GifView* view = [[GifView alloc] initWithFrame:CGRectMake(self.myImageView.frame.origin.x, 
                                                                  self.myImageView.frame.origin.y, 304/2, 320/2)
                                                filePath:self.imageFilePath
                                        playTimeInterval:0.5];    
        [self.view addSubview:view];
    }
    else{
        [self.myImageView setImage:self.myImage];
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
