//
//  ShowImageController.m
//  Draw
//
//  Created by gamy on 12-11-26.
//
//

#import "ShowImageController.h"
#import "UIImageView+WebCache.h"

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

- (void)showImage;
- (IBAction)clickMask:(id)sender;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _scale = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [super viewDidUnload];
}

//- (CGSize)
- (void)adjustImageSize
{
    CGSize imageSize = self.image.size;
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    if (imageSize.width <= scrollViewSize.width && imageSize.height <= scrollViewSize.height) {
        CGRect frame = self.scrollView.frame;
        frame.size = imageSize;
        self.scrollView.frame = frame;
        self.scrollView.contentSize = imageSize;
        self.imageView.frame = self.scrollView.bounds;
        self.imageView.center = self.scrollView.center;
        return;
    }
    
    if (_scale) {
        CGFloat xs = imageSize.width / scrollViewSize.width;
        CGFloat ys = imageSize.height / scrollViewSize.height;
        if (xs < ys) {
            
        }
        
    }else{
        CGRect frame = self.scrollView.frame;
        frame.size = imageSize;
//        self.scrollView.frame = self.fr;
        self.scrollView.contentSize = imageSize;
        self.imageView.frame = self.scrollView.bounds;
        self.imageView.center = self.scrollView.center;

    }
    _scale = !_scale;
}

- (void)showImage
{
    [self adjustImageSize];
}

- (IBAction)clickMask:(id)sender {
    [self adjustImageSize];
}
@end
