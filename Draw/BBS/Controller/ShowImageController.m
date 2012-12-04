//
//  ShowImageController.m
//  Draw
//
//  Created by gamy on 12-11-26.
//
//

#import "ShowImageController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface ShowImageController ()
{
    UIImage *_image;
    NSURL *_url;
    BOOL _scale;
}

@property(nonatomic, retain)UIImage *image;
@property(nonatomic, retain)NSURL *url;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIView *topBarView;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;

- (void)showImage;
- (IBAction)clickMask:(id)sender;
- (IBAction)clickCloseButton:(id)sender;
- (IBAction)clickSaveButton:(id)sender;
- (IBAction)singleClickMask:(id)sender;

@end

@implementation ShowImageController
@synthesize image = _image;
@synthesize url = _url;

- (void)dealloc
{
    PPRelease(_image);
    PPRelease(_url);
    [_scrollView release];
    [_imageView release];
    [_topBarView release];
    [_closeButton release];
    [_saveButton release];
    [super dealloc];
}

+ (ShowImageController *)enterControllerWithImage:(UIImage *)image
                                   fromController:(UIViewController *)fromController
                                         animated:(BOOL)animated
{
    ShowImageController *sic = [[[ShowImageController alloc] init] autorelease];
    sic.image = image;
    [fromController presentModalViewController:sic animated:animated];
    return sic;
}

+ (ShowImageController *)enterControllerWithImageURL:(NSURL *)imageURL
                                      fromController:(UIViewController *)fromController
                                            animated:(BOOL)animated
{
    ShowImageController *sic = [[[ShowImageController alloc] init] autorelease];
    sic.url = imageURL;
    [fromController presentModalViewController:sic animated:animated];
    return sic;
}


- (BOOL)imageNeedScale:(UIImage *)image
{
    CGSize imageSize = image.size;
    CGSize scrollViewSize = self.scrollView.frame.size;
    if (imageSize.width > scrollViewSize.width) {
        return YES;
    }
    if (imageSize.height > scrollViewSize.height) {
        return YES;
    }
    return NO;
}

- (CGSize)sizeOfScaleImage:(UIImage *)image
{
    if (![self imageNeedScale:image]) {
        return image.size;
    }
    CGSize imageSize = image.size;
    CGSize scrollViewSize = self.scrollView.frame.size;
    CGFloat w = imageSize.width / scrollViewSize.width;
    CGFloat h = imageSize.height / scrollViewSize.height;
    CGFloat width = 0;
    CGFloat height = 0;
    if (w > h) {
        width = scrollViewSize.width;
        height = imageSize.height / w;
    }else{
        height = scrollViewSize.height;
        width = imageSize.width / h;
    }
    return CGSizeMake(width, height);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _scale = YES;
    }
    return self;
}

#define RADIUS [DeviceDetection isIPAD] ? 10 : 5

- (void)initViews
{
    [self.closeButton setTitle:NSLS(@"kClose") forState:UIControlStateNormal];
    [self.saveButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
    [self.closeButton.layer setCornerRadius:RADIUS];
    [self.saveButton.layer setCornerRadius:RADIUS];
    [self.closeButton.layer setMasksToBounds:YES];
    [self.saveButton.layer setMasksToBounds:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.saveButton setEnabled:NO];
}

- (void)setTopBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat toAlpha = hidden ? 0 : 1;
    if (animated) {
        [UIView animateWithDuration:0.8 animations:^{
            self.topBarView.alpha = toAlpha;
        } completion:^(BOOL finished) {
            self.topBarView.hidden = hidden;
            self.topBarView.alpha = toAlpha;
        }];
    }else{
        self.topBarView.hidden = hidden;
        self.topBarView.alpha = toAlpha;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];

    if (self.image) {
        [self showImage];
    }else{
        [self.imageView setImageWithURL:self.url placeholderImage:nil success:^(UIImage *image, BOOL cached) {
            self.image = image;
            [self showImage];
        } failure:^(NSError *error) {
            PPDebug(@"show image fail!, url = %@",[self.url description]);
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setImageView:nil];
    [self setTopBarView:nil];
    [self setCloseButton:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}

//- (CGSize)
- (void)adjustImageSize
{
    CGSize size;
    if (_scale) {
        size = [self sizeOfScaleImage:self.image];
    }else{
        size = self.image.size;
    }
    self.scrollView.contentSize = size;
    CGRect frame = self.imageView.frame;
    frame.size = size;
    self.imageView.frame = frame;
    if (_scale) {
        self.imageView.center = self.scrollView.center;
    }else{
        CGPoint center = CGPointMake(size.width/2, size.height/2);
        center.x = MAX(center.x, self.scrollView.center.x);
        center.y = MAX(center.y, self.scrollView.center.y);
        self.imageView.center = center;
    }
    
    _scale = !_scale;
}

- (void)showImage
{
    [self.saveButton setEnabled:YES];
    [self adjustImageSize];
}

- (IBAction)clickMask:(id)sender {
    [self adjustImageSize];
}

- (IBAction)clickCloseButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clickSaveButton:(id)sender {
    if (self.image) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [self showActivityWithText:NSLS(@"kSaving")];
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self hideActivity];
    [self popupHappyMessage:NSLS(@"kSaveImageSuccess") title:nil];
}
- (IBAction)singleClickMask:(id)sender {
    [self setTopBarHidden:!self.topBarView.hidden animated:YES];
}
@end
