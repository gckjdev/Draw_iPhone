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
#import "SpotHelpView.h"

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
    
//#ifdef DEBUG
//    FeedListController* hot1 = [[FeedListController alloc] initWithFeedType:FeedListTypeConquerDrawStageTop
//                                                                 tutorialId:@"tutorialId-2"
//                                                                    stageId:@"stageId-0-0"
//                                                              displayStyle:FEED_DISPLAY_NORMAL
//                                                       superViewController:self
//                                                                     title:NSLS(@"kRankHot")];
//    
//    [viewControllers addObject:hot1];
//    [hot1 release];
//#endif
    
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
    
    self.pagesContainer.viewControllers = viewControllers;
    self.pagesContainer.defaultSelectedIndex = selectIndex;
    self.pagesContainer.selectedIndex = selectIndex;

    [viewControllers release];
    
}

- (void)clearPageContainer
{
    for (UIViewController* vc in self.pagesContainer.viewControllers){
        if ([vc isKindOfClass:[FeedListController class]]){
            FeedListController* fvc = (FeedListController*)vc;
            [fvc cleanDataBeforeRemoveView];
        }
    }
    
    [self.pagesContainer viewDidUnload];
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
    
    [self showHelpView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateRankTypeButtonTitle];
    [super viewDidAppear:animated];
}

- (void)showHelpView
{
//    CGRect frame1 = [CommonTitleView titleView:self.view].frame;
//    frame1.origin.x += self.submitButton.superview.frame.origin.x;
//    frame1.origin.y += self.submitButton.superview.frame.origin.y;
//    SpotHelpObject* obj1 = [SpotHelpObject objectWithRect:frame1
//                                                     text:NSLS(@"kHelpNewHotRight")
//                                                      dir:(ISIPAD? CRArrowPositionTopRight:CRArrowPositionTopRight)];
    
//    CGRect frame2 = self.pagesContainer.topBarBackgroundColor.frame;
//    frame2.origin.x += self.helpButton.superview.frame.origin.x;
//    frame2.origin.y += self.helpButton.superview.frame.origin.y;
//    SpotHelpObject* obj2 = [SpotHelpObject objectWithRect:frame2
//                                                     text:NSLS(@"kHelpViewInOfflineDrawHelpButtonGuide")
//                                                      dir:(ISIPAD? CRArrowPositionTopRight:CRArrowPositionTopRight)];
    
    //本来spotlight是对targetview内接圆打光，为了改成对外切圆打光，通过几何计算得出调整
    //临摹框
//    CGRect frame = self.copyView.frame;
//    frame.origin.x += self.copyView.superview.frame.origin.x - 0.2*self.copyView.frame.size.width;
//    frame.origin.y += self.copyView.superview.frame.origin.y - 0.2*self.copyView.frame.size.height;
//    frame.size.width += 2*0.2*self.copyView.frame.size.width;
//    frame.size.height += 2*0.2*self.copyView.frame.size.height;
//    SpotHelpObject* obj3 = [SpotHelpObject objectWithRect:frame
//                                                     text:NSLS(@"kHelpViewInOfflineDrawCopyViewGuide")
//                                                      dir:(ISIPAD?CRArrowPositionTopLeft:CRArrowPositionTopLeft)];
//    
//    [SpotHelpView show:self.view
//          spotHelpList:@[obj1, obj2, obj3]
//                   key:KEY_LEARN_DRAW_HELP
//               perUser:YES
//              callback:callback];

}

- (void)clickAdd:(id)sender
{
    NSArray* selectedList = [[OpusClassInfoManager defaultManager] userDisplayClassList];
    
    // show set opus class
    [SelectOpusClassViewController showInViewController:self
                                           selectedTags:selectedList
                                      arrayForSelection:[[OpusClassInfoManager defaultManager] defaultUserSetList]
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
    int currentSelectIndex = self.pagesContainer.selectedIndex;
    if (self.currentRankType == FeedListTypeHistoryRank){
        self.currentRankType = FeedListTypeHot;
        
        if (currentSelectIndex > 0){
            currentSelectIndex = currentSelectIndex+2;
        }
    }
    else{
        self.currentRankType = FeedListTypeHistoryRank;
        
        if (currentSelectIndex == 0){
        }
        else if (currentSelectIndex == 1 || currentSelectIndex == 2){
            currentSelectIndex = 0;
        }
        else{
            currentSelectIndex -= 2;
        }
    }
    
    [self updateRankTypeButtonTitle];
    
    [self reloadPageContainer:currentSelectIndex];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
