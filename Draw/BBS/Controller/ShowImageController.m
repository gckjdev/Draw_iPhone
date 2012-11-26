//
//  ShowImageController.m
//  Draw
//
//  Created by gamy on 12-11-26.
//
//

#import "ShowImageController.h"

@interface ShowImageController ()
{
    UIImage *_image;
    NSURL *_url;
}

@property(nonatomic, retain)UIImage *image;
@property(nonatomic, retain)NSURL *url;

@end

@implementation ShowImageController
@synthesize image = _image;
@synthesize url = _url;

- (void)dealloc
{
    PPRelease(_image);
    PPRelease(_url);
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
