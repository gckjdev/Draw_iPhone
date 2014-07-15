//
//  NewHotControllerViewController.m
//  Draw
//
//  Created by qqn_pipi on 14-7-1.
//
//

#import "NewHotController.h"
#import "DAPagesContainer.h"
#import "FeedListController.h"
#import "UIViewController+BGImage.h"
#import "OpusClassInfo.h"
#import "OpusClassInfoManager.h"
#import "SelectOpusClassViewController.h"

@interface NewHotController ()

@property (nonatomic, retain) DAPagesContainer* pagesContainer;

@end

@implementation NewHotController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _pagesContainer = [[DAPagesContainer alloc] init];
    }
    return self;
}

#define BUTTON_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:28] : [UIFont boldSystemFontOfSize:14])

- (void)initPageContainer
{
    self.pagesContainer.topBarHeight = COMMON_TAB_BUTTON_HEIGHT;
    self.pagesContainer.topBarBackgroundColor = COLOR_RED;
    self.pagesContainer.pageItemsTitleColor = COLOR_WHITE;
    self.pagesContainer.selectedPageItemTitleColor = COLOR_YELLOW;
    self.pagesContainer.topBarItemLabelsFont = BUTTON_FONT;
    
    CGRect frame = CGRectMake(0, COMMON_TAB_BUTTON_Y, self.view.bounds.size.width, self.view.bounds.size.height - COMMON_TAB_BUTTON_Y);
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = frame; //self.view.bounds;
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];
}

- (void)initPageContainerData
{
    NSMutableArray* viewControllers = [[NSMutableArray alloc] init];
    
    FeedListController* alltime = [[FeedListController alloc] initWithFeedType:FeedListTypeHistoryRank
                                                                 opusClassInfo:nil
                                                                  displayStyle:FEED_DISPLAY_NORMAL
                                                           superViewController:self
                                                                         title:NSLS(@"kRankHistory")];
    
    [viewControllers addObject:alltime];
    [alltime release];
    
    FeedListController* hot = [[FeedListController alloc] initWithFeedType:FeedListTypeHot
                                                             opusClassInfo:nil
                                                              displayStyle:FEED_DISPLAY_BIG3
                                                       superViewController:self
                                                                     title:NSLS(@"kRankHot")];
    
    [viewControllers addObject:hot];
    [hot release];
    
    FeedListController* recommend = [[FeedListController alloc] initWithFeedType:FeedListTypeRecommend
                                                                   opusClassInfo:nil
                                                                    displayStyle:FEED_DISPLAY_NORMAL
                                                             superViewController:self
                                                                           title:NSLS(@"kLittleGeeRecommend")];
    
    [viewControllers addObject:recommend];
    [recommend release];
    
    NSArray* classList = [[OpusClassInfoManager defaultManager] userDisplayClassList];
    for (OpusClassInfo *classInfo in classList) {
        FeedListController* vc = [[FeedListController alloc] initWithFeedType:FeedListTypeClassAlltimeTop
                                                                opusClassInfo:classInfo
                                                                 displayStyle:FEED_DISPLAY_NORMAL
                                                          superViewController:self
                                                                        title:classInfo.name];
        
        [viewControllers addObject:vc];
        [vc release];
    }
    
    FeedListController* latest = [[FeedListController alloc] initWithFeedType:FeedListTypeLatest
                                                                opusClassInfo:nil
                                                                 displayStyle:FEED_DISPLAY_NORMAL
                                                          superViewController:self
                                                                        title:NSLS(@"kRankNew")];
    
    [viewControllers addObject:latest];
    [latest release];
    
    FeedListController* vip = [[FeedListController alloc] initWithFeedType:FeedListTypeVIP
                                                             opusClassInfo:nil
                                                              displayStyle:FEED_DISPLAY_NORMAL
                                                       superViewController:self
                                                                     title:NSLS(@"kRankVip")];
    
    [viewControllers addObject:vip];
    [vip release];
    
    self.pagesContainer.defaultSelectedIndex = 1;
    self.pagesContainer.viewControllers = viewControllers;
    
    [viewControllers release];
    
}

- (void)clearPageContainer
{
    [self.pagesContainer.view removeFromSuperview];
    self.pagesContainer = nil;
}

- (void)viewDidLoad
{
    // set title view
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kNewHotTitle")];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    [[CommonTitleView titleView:self.view] setRightButtonSelector:@selector(clickAdd:)];
    [[CommonTitleView titleView:self.view] setRightButtonTitle:NSLS(@"kConfigNewHot")];
    
    [self initPageContainer];
    
    [super viewDidLoad];
    
    [self setCanDragBack:NO];
    [self setDefaultBGImage];

	// Do any additional setup after loading the view.
    [self initPageContainerData];
}

- (void)clickAdd:(id)sender
{
    NSArray* selectedList = [[OpusClassInfoManager defaultManager] userDisplayClassList];
    
    // show set opus class
    [SelectOpusClassViewController showInViewController:self
                                           selectedTags:selectedList
                                      arrayForSelection:nil
                                         maxSelectCount:100     // no limit
                                               callback:^(int resultCode, NSArray *selectedArray, NSArray *arrayForSelection) {

                                                   [[OpusClassInfoManager defaultManager] saveUserDisplayList:selectedArray];
                                                   
                                                   // reload
                                                   [self clearPageContainer];
                                                   _pagesContainer = [[DAPagesContainer alloc] init];
                                                   [self initPageContainer];
                                                   [self initPageContainerData];
                                               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
