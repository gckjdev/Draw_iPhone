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

- (void)dealloc
{
    [_myImage release];
    [_patternsGallery release];
    [_patternsArray release];
    [_infuseImageView release];
    [_inputBackground release];
    [_myImageView release];
    [_shareButton release];
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
        case SAVE_TO_ALBUM:
            //
            break;
        case SHARE_VIA_EMAIL: {
            
        } break;
        case SHARE_VIA_SINA: {
            
        } break;
        case SHARE_VIA_QQ: {
            
        } break;
        default:
            break;
    }
}

- (IBAction)publish:(id)sender
{
    if ([LocaleUtils isChina]) {
        UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_via") delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kSave_to_album") otherButtonTitles:NSLS(@"kShare_via_Email"), NSLS(@"kShare_via_Sina_weibo"), NSLS(@"kShare_via_tencent_weibo"), nil];
        [shareOptions showInView:self.view];
        [shareOptions release];
    } else {
        UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_via") delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kSave_to_album") otherButtonTitles:NSLS(@"kShare_via_Email"), NSLS(@"kShare_via_Facebook"), NSLS(@"kShare_via_Twitter"), nil];
        [shareOptions showInView:self.view];
        [shareOptions release];
    }
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithImage:(UIImage*)anImage
{
    self = [super init];
    if (self) {
        self.myImage = anImage;
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
    [self.shareButton setTitle:NSLS(@"kShare") forState:UIControlStateNormal];
    [self.inputBackground setImage:[[ShareImageManager defaultManager] inputImage]];
    [self.myImageView setImage:self.myImage];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPatternsGallery:nil];
    [self setInputBackground:nil];
    [self setMyImageView:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
