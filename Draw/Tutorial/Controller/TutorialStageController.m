//
//  TutorialStageController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "TutorialStageController.h"
#import "StageCell.h"
#import "UIViewController+BGImage.h"
#import "UserTutorialMainController.h"
#import "UIImageView+Extend.h"
#import "PBTutorial+Extend.h"
#import "OfflineDrawViewController.h"
#import "UserTutorialService.h"
#import "TutorialInfoController.h"
#import "TutorialCoreManager.h"
#import "UserTutorialManager.h"
#import "StageAlertViewController.h"

#import "DrawFeed.h"
#import "FeedManager.h"
#import "FeedService.h"
#import "UIViewController+CommonHome.h"
#import "REPagedScrollView.h"


@interface TutorialStageController ()
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UIImage *image;
@property (nonatomic,retain)PBUserTutorial* pbUserTutorial;
@property(nonatomic,retain)NSArray *feedList;
@property(nonatomic,retain)UIView *rankView;
@property(nonatomic,retain)REPagedScrollView *rankViewsList;
@property (nonatomic,retain)NSMutableArray *list;
@property(nonatomic ,retain)UIView *introductionView;
@end

@implementation TutorialStageController
{
    int stageIndex;
    int usersTotalCount;
    
}
#define INTRODUCTION_HEIGHT (ISIPAD ? 60 : 30)
#define RANK_HEIGHT (ISIPAD ? 160 : 80)
#define SINGLE_GESTURE_RECONGNIEZER 0
#define RIGHT_GESTURE_RECONGNIEZER 1
#define LEFT_GESTURE_RECONGNIEZER 2
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#define COLLECTION_CELL_WIDTH (ISIPAD ? 220 : 140)
#define COLLECTION_CELL_HEIGHT (ISIPAD ? 200 : 100)
-(void)viewDidLoad{
    
    NSString *title = [[self.pbUserTutorial tutorial] name]; // 实现 国际化
    [super viewDidLoad];
    stageIndex = _pbUserTutorial.currentStageIndex;
    
    // set title view
    CommonTitleView *headerView = [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:title];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    [[CommonTitleView titleView:self.view] setRightButtonSelector:@selector(clickEnterInfo:)];
    [[CommonTitleView titleView:self.view] setRightButtonTitle:NSLS(@"kUserTutorialInfo")];
    [self setIntroductionView:headerView];
    [self setRankView];
    [self setViewStyle];
    [self setCanDragBack:NO];
    
}
-(void)setViewStyle{
    //流布局
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    [flowLayout setItemSize:CGSizeMake(COLLECTION_CELL_WIDTH,COLLECTION_CELL_HEIGHT)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumLineSpacing:20];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    //指定xib文件
    UINib *nib = [UINib nibWithNibName:@"StageCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"StageCell"];
    
    //autolayout
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[CommonTitleView titleView:self.view]
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:5.0];
    [self.view addConstraint:constraint];
    
    //背景
    [self setDefaultBGImage];
    //    [self.view setBackgroundColor:CO]
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.collectionView setContentInset:UIEdgeInsetsMake(INTRODUCTION_HEIGHT, 0, RANK_HEIGHT,0 )];
    self.collectionView.alwaysBounceVertical = YES;
    
    
}


#define INTRODUCTION_LEISURE_TUTORIAL NSLS(@"kIntroduceLeisureTutorial")
#define INTRODUCTION_PRO_TUTORIAL NSLS(@"kIntroduceProTutorial")
#define INTRODUCTION_CREATE_TUTORIAL NSLS(@"kIntroduceCreateTutorial")
-(void)setIntroductionView:(CommonTitleView *)headerTitle{
    
    NSArray *tutorialTypeDescList = @[INTRODUCTION_PRO_TUTORIAL,
                                      INTRODUCTION_PRO_TUTORIAL,
                                      INTRODUCTION_LEISURE_TUTORIAL,
                                      INTRODUCTION_CREATE_TUTORIAL];
    
    //新建介绍view
    _introductionView = [[UIView alloc] initWithFrame:CGRectMake(0, headerTitle.bounds.size.height, headerTitle.bounds.size.width, INTRODUCTION_HEIGHT)];
    [_introductionView setBackgroundColor:COLOR_GRAY];
    //新建Label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _introductionView.frame.size.width, _introductionView.frame.size.height)];
    
    //在介绍的View写进文字
     NSString *introduction = @"";
    int tutorialType = self.pbUserTutorial.tutorial.type;
    if(tutorialType>=0 && tutorialType <= tutorialTypeDescList.count-1){
        introduction = [tutorialTypeDescList objectAtIndex:tutorialType];
    }
    [label setText:introduction];
    [label setTextColor:COLOR_BROWN];
    [label setFont:AD_FONT(24, 12)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [_introductionView addSubview:label];
    [label release];
    [self.view addSubview:_introductionView];

    
    
}


-(void)setRankView{
    
    _rankView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-RANK_HEIGHT, [[UIScreen mainScreen] bounds].size.width,RANK_HEIGHT)];
//    _rankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,RANK_HEIGHT)];
    
    [_rankView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_rankView setBackgroundColor:COLOR_GRAY];
    
    
    [self.view addSubview:_rankView];
    [self initRankViewAvatar:_rankView];
    [self setupListeningRankView:_rankView];
    
    
}



//初始化排行榜
-(void)initRankViewAvatar:(UIView *)superView{
    [self getAvatarDataIntoRankView];
}
//拿到头像数据
#define RANK_LIST_LIMIT 10
-(void)getAvatarDataIntoRankView{
    NSArray *stageList = [[_pbUserTutorial tutorial] stagesList];
    PBStage *stageWithRow = [stageList objectAtIndex:stageIndex];
    NSString *stageId = stageWithRow.stageId;
    NSString *tutorialId = [[_pbUserTutorial tutorial] tutorialId];
    
    //运行之后调用delegate 的didGetFeedList
    [[FeedService defaultService] getFeedList:FeedListTypeConquerDrawStageTop
                                      classId:nil
                                   tutorialId:tutorialId
                                      stageId:stageId
                                       offset:0
                                        limit:RANK_LIST_LIMIT
                                     delegate:self];
    
}

//设置rankView的头像和样式
#define AVATAR_SQUARE_SIDE (ISIPAD?90.0:40.0)
#define LABEL_HEIGHT (ISIPAD?23:12)
#define LIST_LIMIT (ISIPAD?5:4)
#define BOTTOM_MARGIN (ISIPAD?18:5)
#define LEFT_RIGHT_MARGIN (ISIPAD?10:5)
-(void)setRankViewAvatarAndStyle:(UIView *)superView WithRankList:(NSArray *)list{
    
    [superView removeAllSubviews];
    
    CGFloat avatarSquareSide = AVATAR_SQUARE_SIDE;
    CGFloat superViewWidth = superView.frame.size.width;
    
    int avatarSum =0;
    CGFloat widthInterval = (superViewWidth-2*(avatarSquareSide/3*2)-LIST_LIMIT*avatarSquareSide)/(LIST_LIMIT+1.0);
    CGFloat totalLength = 0;
    UIButton *left = [[UIButton alloc] initWithFrame:CGRectMake(LEFT_RIGHT_MARGIN,
                                                                       superView.frame.size.height - avatarSquareSide,
                                                                       avatarSquareSide/3*2,
                                                                       avatarSquareSide/3*2)];
    
    [left setCenter:CGPointMake(left.center.x, superView.frame.size.height - avatarSquareSide+(avatarSquareSide/2.0f)-BOTTOM_MARGIN)];
    [left setBackgroundImage:[UIImage imageNamed:@"rankLeft"] forState:UIControlStateNormal];
    [left addTarget:self action:@selector(prePage) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:left];
    totalLength = totalLength + avatarSquareSide;
    for(DrawFeed *feed in list){
        //当头像大于4个之后跳出
        if(avatarSum>LIST_LIMIT-1){
            break;
        }
        
        AvatarView *avatar = [[AvatarView alloc] initWithUrlString:feed.pbFeed.avatar
                                                             frame:
                                                            CGRectMake(totalLength,
                                                                     superView.frame.size.height - avatarSquareSide-BOTTOM_MARGIN,
                                                                     avatarSquareSide,
                                                                     avatarSquareSide)
                                                            gender:feed.pbFeed.gender level:0 vip:0];
        
        [avatar.delegate self];
        
        [superView addSubview:avatar];
        [avatar setUserInteractionEnabled:NO];
        //动画效果
        [avatar release];
        avatarSum ++ ;
        totalLength = totalLength + avatarSquareSide + widthInterval;
       
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((ISIPAD?20:10), (_rankView.frame.size.height-avatarSquareSide)/2.0f-LABEL_HEIGHT/2.0f-(ISIPAD?15:0), _rankView.frame.size.width, LABEL_HEIGHT)];
    
    NSString *stageName = [[_pbUserTutorial.tutorial.stagesList objectAtIndex:stageIndex] name];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:[NSString stringWithFormat:NSLS(@"kRankViewDesc"),stageName,usersTotalCount]];
    [label setTextColor:COLOR_BROWN];
    [label setFont:AD_FONT(LABEL_HEIGHT, LABEL_HEIGHT)];
    
    UIButton *right = [[UIButton alloc] initWithFrame:CGRectMake(_rankView.bounds.size.width-(avatarSquareSide/3*2)-LEFT_RIGHT_MARGIN,
                                                                       superView.frame.size.height - avatarSquareSide,
                                                                       avatarSquareSide/3*2,
                                                                       avatarSquareSide/3*2)];
    
    [right setCenter:CGPointMake(right.center.x, superView.frame.size.height - avatarSquareSide+(avatarSquareSide/2.0f)-BOTTOM_MARGIN)];
    [right setBackgroundImage:[UIImage imageNamed:@"rankEnterBtn"] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:right];
    
    
    
    [self.rankView addSubview:label];
    
    //判断是否到最大或者最小值 来隐藏箭头
    if(stageIndex >= _pbUserTutorial.currentStageIndex){
        right.hidden = YES;
    }
    if(stageIndex <= 0){
        left.hidden = YES;
    }
    
    [left release];
    [right release];
    [label release];
}

- (void)reload
{
    self.pbUserTutorial = [[UserTutorialManager defaultManager] findUserTutorialByLocalId:self.pbUserTutorial.localId];
    [self.collectionView reloadData];
    [self setRankView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reload];
    [super viewDidAppear:animated];
}

//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int count = [[[self.pbUserTutorial tutorial] stagesList] count];
    return count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    StageCell *cell = (StageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"StageCell" forIndexPath:indexPath];
    //更新cell
    [cell updateStageCellInfo:self.pbUserTutorial withRow:indexPath.row];
    
    return cell;
}
#pragma mark -- UICollectionViewDataSource

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#define UI_EDGE_INSERTS_MAKE (ISIPAD ? 20 : 8)
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE);
}


#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    NSInteger row = indexPath.row;
    

    if ([self.pbUserTutorial isStageLock:row] == NO){
//        [self askPracticeOrPass:row];
        
        [StageAlertViewController show:self
                          userTutorial:self.pbUserTutorial
                            stageIndex:row];
        
    }
    else{
#ifdef DEBUG
        
        POSTMSG(NSLS(@"Stage is LOCK but THIS IS DEBUG VERSION"));
        
        [StageAlertViewController show:self
                          userTutorial:self.pbUserTutorial
                            stageIndex:row];

#endif
    
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


- (void)dealloc {
    PPRelease(_pbUserTutorial);
    PPRelease(_image);
    PPRelease(_infoController);
    PPRelease(_feedList);
    PPRelease(_rankView);
    PPRelease(_rankViewsList);
    PPRelease(_list);
    PPRelease(_introductionView);
    [_collectionView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}
//跳转
+(TutorialStageController *)enter:(PPViewController *)superViewController pbTutorial:(PBUserTutorial *)pbUserTutorial{
    TutorialStageController *tc = [[TutorialStageController alloc] init];
    
    // update tutorial in pb user tutorial here
    PBUserTutorial* newUT = [[UserTutorialManager defaultManager] updateLatestTutorial:pbUserTutorial];
    tc.pbUserTutorial = newUT;
    [superViewController.navigationController pushViewController:tc animated:YES];
    [tc release];
    return tc;
}


-(void)clickEnterInfo:(id)sender{
    
    PBTutorial *pbTutorial = [[TutorialCoreManager defaultManager]findTutorialByUserTutorialId:self.pbUserTutorial];
    
    self.infoController = [TutorialInfoController createController:pbTutorial infoOnly:YES];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:pbTutorial.cnName
                                                    customView:_infoController.view
                                                         style:CommonDialogStyleCross];
    
    [dialog showInView:self.view];

}

#pragma mark FeedService delegate
-(void)didGetFeedList:(NSArray *)feedList feedListType:(FeedListType)type resultCode:(NSInteger)resultCode totalCount:(int)totalCount{
    
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    if (resultCode == 0) {
        self.feedList = feedList;
        usersTotalCount =totalCount;
        // update rank view
        [self setRankViewAvatarAndStyle:self.rankView WithRankList:self.feedList];
        [self curlUp];
       
    }else{
        self.feedList = nil;
    }
    
}
-(void)enterRankPage{
    NSArray *stageList = [[_pbUserTutorial tutorial] stagesList];
    PBStage *stageWithRow = [stageList objectAtIndex:stageIndex];
    NSString *stageId = stageWithRow.stageId;
    
    NSString *tutorialId = [[_pbUserTutorial tutorial] tutorialId];
    [self enterTutorialTopOpus:tutorialId stageId:stageId title:NSLS(@"kRankingList")];
    
}
#pragma mark - Listen
-(void)setListenInView:(UIView*)view selector:(SEL)selector{
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [view addGestureRecognizer:singleTap];
    [singleTap release];
}


-(void)setGestureRecognizer:(UIView *)view selector:(SEL)selector type:(int)type{
    
    switch (type) {
        case SINGLE_GESTURE_RECONGNIEZER:
            [self setListenInView:view selector:selector];
            break;
            
        case RIGHT_GESTURE_RECONGNIEZER:
        {
            UISwipeGestureRecognizer *rightswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:selector];
            [view addGestureRecognizer:rightswipe];
            [rightswipe release];
            break;
        }
        case LEFT_GESTURE_RECONGNIEZER:
        {
            UISwipeGestureRecognizer *rightswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:selector];
             rightswipe.direction=UISwipeGestureRecognizerDirectionLeft;
            [view addGestureRecognizer:rightswipe];
            [rightswipe release];
            break;
        }
        default:
            break;
    }
    
    
    
}
-(void)nextPage{
    if(stageIndex < _pbUserTutorial.currentStageIndex){
        stageIndex ++ ;
    }
    [self setRankView];
    NSLog(@"page == %d",stageIndex);
}
-(void)prePage{
    if(stageIndex > 0 ){
        stageIndex -- ;
    }
    [self setRankView];
        NSLog(@"page == %d",stageIndex);
}

#pragma mark - setup Listening
-(void)setupListeningRankView:(UIView *)view{
    [self setGestureRecognizer:view selector:@selector(enterRankPage) type:SINGLE_GESTURE_RECONGNIEZER];
    [self setGestureRecognizer:view selector:@selector(prePage) type:RIGHT_GESTURE_RECONGNIEZER];
    [self setGestureRecognizer:view selector:@selector(nextPage) type:LEFT_GESTURE_RECONGNIEZER];
}

//动画
- (void)curlUp{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.0f;       //动画执行时间
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromRight;
    // 这里添加你对UIView所做改变的代码
    [[_rankView layer] addAnimation:animation forKey:@"animation"];
        

   
}


@end
