//
//  SuperHomeController.m
//  Draw
//
//  Created by qqn_pipi on 12-10-6.
//
//

#import "SuperHomeController.h"

@interface SuperHomeController ()

@end

#define ISIPAD [DeviceDetection isIPAD]
#define MAIN_MENU_ORIGIN_Y ISIPAD ? 350 : 170
#define BOTTOM_MENU_ORIGIN_Y ISIPAD ? (1004-76) : 422

@implementation SuperHomeController

-(void)dealloc
{
    PPRelease(_bottomMenuPanel);
    PPRelease(_headerPanel);
    PPRelease(_mainMenuPanel);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateView:(UIView *)view originY:(CGFloat)y
{
    CGRect frame = view.frame;
    CGPoint origin = frame.origin;
    origin.y = y;
    frame.origin = origin;
    view.frame = frame;
}

- (void)addHeaderView
{
    self.headerPanel = [HomeHeaderPanel createView:self];
    [self.view addSubview:self.headerPanel];
    [self updateView:self.headerPanel originY:0];
}



- (void)addMainMenuView
{
    self.mainMenuPanel = [HomeMainMenuPanel createView:self];
    [self.view addSubview:self.mainMenuPanel];
//    self.mainMenuPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    //TODO update frame
    [self updateView:self.mainMenuPanel originY:MAIN_MENU_ORIGIN_Y];
}

- (void)addBottomMenuView
{
    self.bottomMenuPanel = [HomeBottomMenuPanel createView:self];
//    self.bottomMenuPanel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.bottomMenuPanel];
    //TODO update frame
    [self updateView:self.bottomMenuPanel originY:BOTTOM_MENU_ORIGIN_Y];
}

- (void)viewDidLoad
{
    PPDebug(@"SuperHomeController view did load");
    [super viewDidLoad];
    if (!ISIPAD) {
        self.view.frame = CGRectMake(0, 0, 320, 460);
    }
    [self addHeaderView];
    [self addMainMenuView];
    [self addBottomMenuView];
    
    if (!ISIPAD) {
        self.view.frame = [[UIScreen mainScreen] bounds];
    }
}


- (void)viewDidUnload
{
    self.headerPanel = nil;
    self.mainMenuPanel = nil;
    self.bottomMenuPanel = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
