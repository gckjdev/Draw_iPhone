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

#define BUTTON_FONT (ISIPAD ? [UIFont systemFontOfSize:28] : [UIFont systemFontOfSize:14])


- (void)viewDidLoad
{
    // set title view
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kUserTutorialMainTitle")];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    [[CommonTitleView titleView:self.view] setRightButtonSelector:@selector(clickAdd:)];
    [[CommonTitleView titleView:self.view] setRightButtonTitle:NSLS(@"kAddTutorial")];
    
    self.pagesContainer.topBarHeight = COMMON_TAB_BUTTON_HEIGHT;
    self.pagesContainer.topBarBackgroundColor = COLOR_YELLOW;
    self.pagesContainer.pageItemsTitleColor = COLOR_WHITE;
    self.pagesContainer.selectedPageItemTitleColor = COLOR_BROWN;
//    self.pagesContainer.pageIndicatorImage = IMAGE_FROM_COLOR(COLOR_YELLOW);
    self.pagesContainer.topBarItemLabelsFont = BUTTON_FONT;
    
    [super viewDidLoad];
    
    [self setCanDragBack:NO];

	// Do any additional setup after loading the view.
    CGRect frame = CGRectMake(0, COMMON_TAB_BUTTON_Y, self.view.bounds.size.width, self.view.bounds.size.height - COMMON_TAB_BUTTON_Y);
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = frame; //self.view.bounds;
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];
    
//    NSLayoutConstraint* constraintTop = [NSLayoutConstraint constraintWithItem:self.pagesContainer.view
//                                                                  attribute:NSLayoutAttributeTop
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:[CommonTitleView titleView:self.view]
//                                                                  attribute:NSLayoutAttributeBottom
//                                                                 multiplier:1.0
//                                                                   constant:0.0];
//    [self.view addConstraint:constraintTop];
//
//    NSLayoutConstraint* constraintBottom = [NSLayoutConstraint constraintWithItem:self.pagesContainer.view
//                                                                  attribute:NSLayoutAttributeBottom
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:self.view
//                                                                  attribute:NSLayoutAttributeBottom
//                                                                 multiplier:1.0
//                                                                   constant:0.0];
//    [self.view addConstraint:constraintBottom];
    
//    NSArray* feedListTypeArray = @[@(FeedListTypeHistoryRank), @(FeedListTypeHot) ];
    
    
    
    FeedListController* vc1 = [[FeedListController alloc] init];
    vc1.title = @"周榜";
    FeedListController* vc2 = [[FeedListController alloc] init];
    vc2.superViewController = self;
    vc2.title = @"年榜";
    FeedListController* vc3 = [[FeedListController alloc] init];
    vc3.title = @"人物";
    FeedListController* vc4 = [[FeedListController alloc] init];
    vc4.title = @"风景";
    FeedListController* vc5 = [[FeedListController alloc] init];
    vc5.title = @"动漫";
    FeedListController* vc6 = [[FeedListController alloc] init];
    vc6.title = @"推荐";
    FeedListController* vc7 = [[FeedListController alloc] init];
    vc7.title = @"中国风";
    
    self.pagesContainer.defaultSelectedIndex = 1;
    self.pagesContainer.viewControllers = @[vc1, vc2, vc3, vc4, vc5, vc6, vc7];

//    [self.pagesContainer setSelectedIndex:1 animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
