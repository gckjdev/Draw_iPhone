//
//  SuperHomeController.m
//  Draw
//
//  Created by qqn_pipi on 12-10-6.
//
//

#import "SuperHomeController.h"
#import "HomeMenuView.h"
#import "CoinShopController.h"

@interface SuperHomeController ()

@end

#define ISIPAD [DeviceDetection isIPAD]
#define MAIN_MENU_ORIGIN_Y ISIPAD ? 365 : 170
#define BOTTOM_MENU_ORIGIN_Y ISIPAD ? (1004-97) : 422

@implementation SuperHomeController

-(void)dealloc
{
    PPRelease(_homeBottomMenuPanel);
    PPRelease(_homeHeaderPanel);
    PPRelease(_homeMainMenuPanel);
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
    self.homeHeaderPanel = [HomeHeaderPanel createView:self];
    [self.view addSubview:self.homeHeaderPanel];
    [self updateView:self.homeHeaderPanel originY:0];
}



- (void)addMainMenuView
{
    self.homeMainMenuPanel = [HomeMainMenuPanel createView:self];
    [self.view addSubview:self.homeMainMenuPanel];
//    self.mainMenuPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    //TODO update frame
    [self updateView:self.homeMainMenuPanel originY:MAIN_MENU_ORIGIN_Y];
}

- (void)addBottomMenuView
{
    self.homeBottomMenuPanel = [HomeBottomMenuPanel createView:self];
//    self.bottomMenuPanel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.homeBottomMenuPanel];
    //TODO update frame
    [self updateView:self.homeBottomMenuPanel originY:BOTTOM_MENU_ORIGIN_Y];
}

- (void)viewDidLoad
{
    PPDebug(@"SuperHomeController view did load");
    [super viewDidLoad];
    if (!ISIPAD) {
        self.view.frame = CGRectMake(0, 0, 320, 460);
    }
    [self addMainMenuView];
    [self addHeaderView];
    [self addBottomMenuView];
    
    if (!ISIPAD) {
        self.view.frame = [[UIScreen mainScreen] bounds];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.homeMainMenuPanel animatePageButtons];
}

- (void)viewDidUnload
{
    self.homeHeaderPanel = nil;
    self.homeMainMenuPanel = nil;
    self.homeBottomMenuPanel = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Panels Delegate

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickChargeButton:(UIButton *)button
{
    CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
    
}


@end
