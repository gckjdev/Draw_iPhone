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
@property (nonatomic, retain) UIButton* rankTypeButton;
@property (nonatomic, assign) int currentRankType;

@end

@implementation NewHotController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _pagesContainer = [[DAPagesContainer alloc] init];
        _currentRankType = FeedListTypeHot;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_rankTypeButton);
    PPRelease(_pagesContainer);
    [super dealloc];
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

- (void)initPageContainerData:(int)selectIndex
{
    NSMutableArray* viewControllers = [[NSMutableArray alloc] init];
    
    
    if (_currentRankType == FeedListTypeHot){
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
        
        FeedListController* latest = [[FeedListController alloc] initWithFeedType:FeedListTypeLatest
                                                                    opusClassInfo:nil
                                                                     displayStyle:FEED_DISPLAY_NORMAL
                                                              superViewController:self
                                                                            title:NSLS(@"kRankNew")];
        
        [viewControllers addObject:latest];
        [latest release];
        
    }
    else{
        FeedListController* alltime = [[FeedListController alloc] initWithFeedType:FeedListTypeHistoryRank
                                                                     opusClassInfo:nil
                                                                      displayStyle:FEED_DISPLAY_NORMAL
                                                               superViewController:self
                                                                             title:NSLS(@"kRankHistory")];
        
        [viewControllers addObject:alltime];
        [alltime release];
    }
    
    int feedListTypeForClass = FeedListTypeClassAlltimeTop;
    if (_currentRankType == FeedListTypeHot){
        feedListTypeForClass = FeedListTypeClassHotTop;
    }
    
    NSArray* classList = [[OpusClassInfoManager defaultManager] userDisplayClassList];
    for (OpusClassInfo *classInfo in classList) {
        FeedListController* vc = [[FeedListController alloc] initWithFeedType:feedListTypeForClass
                                                                opusClassInfo:classInfo
                                                                 displayStyle:FEED_DISPLAY_NORMAL
                                                          superViewController:self
                                                                        title:classInfo.name];
        
        [viewControllers addObject:vc];
        [vc release];
    }
    
    FeedListController* vip = [[FeedListController alloc] initWithFeedType:FeedListTypeVIP
                                                             opusClassInfo:nil
                                                              displayStyle:FEED_DISPLAY_NORMAL
                                                       superViewController:self
                                                                     title:NSLS(@"kRankVip")];
    
    [viewControllers addObject:vip];
    [vip release];
    
    self.pagesContainer.defaultSelectedIndex = selectIndex;
    self.pagesContainer.viewControllers = viewControllers;
    
    [viewControllers release];
    
}

- (void)clearPageContainer
{
    [self.pagesContainer.view removeFromSuperview];
    self.pagesContainer = nil;
}

- (NSString*)getRankTypeTitle
{
    if (_currentRankType == FeedListTypeHistoryRank){
        return NSLS(@"kSetRanTypeButtonWeek");
    }
    else{
        return NSLS(@"kSetRanTypeButtonYear");
    }
}

- (void)createRankTypeButton{
    
    CGRect frame = [[CommonTitleView titleView:self.view] rectFromButtonBeforeRightButton];
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    
    NSString* title = [self getRankTypeTitle];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = BUTTON_FONT;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button setBackgroundImage:[[ShareImageManager defaultManager] greenButtonImage:title]
                      forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(clickRankType:) forControlEvents:UIControlEventTouchUpInside];
    
    [[CommonTitleView titleView:self.view] addSubview:button];
    self.rankTypeButton = button;
}

- (void)updateRankTypeButtonTitle
{
    NSString* title = [self getRankTypeTitle];
    [self.rankTypeButton setTitle:title forState:UIControlStateNormal];
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

    [self createRankTypeButton];
    
    [self initPageContainer];
    
    [super viewDidLoad];
    
    [self setCanDragBack:NO];
    [self setDefaultBGImage];

	// Do any additional setup after loading the view.
    [self initPageContainerData:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateRankTypeButtonTitle];
    [super viewDidAppear:animated];
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
                                                   [self reloadPageContainer:0];
                                               }];
}

- (void)reloadPageContainer:(int)selectIndex
{
    // reload
    [self clearPageContainer];
    _pagesContainer = [[DAPagesContainer alloc] init];
    [self initPageContainer];
    [self initPageContainerData:selectIndex];
}

- (void)clickRankType:(id)sender
{
    if (self.currentRankType == FeedListTypeHistoryRank){
        self.currentRankType = FeedListTypeHot;
    }
    else{
        self.currentRankType = FeedListTypeHistoryRank;
    }
    [self updateRankTypeButtonTitle];
    
    int currentSelectIndex = self.pagesContainer.selectedIndex;
    [self reloadPageContainer:currentSelectIndex];
    
//    [self.navigationController popViewControllerAnimated:NO];
//    
//    NewHotController* vc = [[NewHotController alloc] init];
//    if (self.currentRankType == FeedListTypeHistoryRank){
//        vc.currentRankType = FeedListTypeHot;
//    }
//    else{
//        vc.currentRankType = FeedListTypeHistoryRank;
//    }
//    
//    [self.navigationController pushViewController:vc animated:YES];
//    [vc release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
