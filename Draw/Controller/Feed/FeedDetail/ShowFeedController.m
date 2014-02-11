//
//  ShowFeedController.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShowFeedController.h"
#import "DrawInfoCell.h"
#import "UserInfoCell.h"
#import "CommentCell.h"
#import "CommentFeed.h"
#import "TableTabManager.h"
#import "ViewUserDetail.h"
#import "UserDetailViewController.h"
#import "OfflineGuessDrawController.h"
#import "CommentController.h"
#import "ShareService.h"
#import "Draw.h"
#import "StableView.h"
#import "ShareImageManager.h"
#import "CommonMessageCenter.h"

#import "UseItemScene.h"

#import "MyFriend.h"
#import "FeedClasses.h"
#import "ShareAction.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "AccountService.h"
#import "PPConfigManager.h"
#import "ChargeController.h"

#import "LmWallService.h"
#import "UserGameItemService.h"
#import "GameItemService.h"
#import "FlowerItem.h"
#import "UserGameItemManager.h"
#import "BalanceNotEnoughAlertView.h"
#import "FeedSceneGuessResult.h"
#import "FeedSceneDetailGuessResult.h"
#import "FeedSceneFeedDetail.h"
#import "HomeController.h"
#import "MKBlockActionSheet.h"

#import "UIButton+WebCache.h"
#import "ContestManager.h"
#import "JudgerScoreView.h"
#import "DrawPlayer.h"
#import "OpusImageBrower.h"
#import "DrawUtils.h"
#import "ImagePlayer.h"
#import "AudioPlayer.h"
#import "GameSNSService.h"
#import "ShareAction.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SoundPlayer.h"
#import "AudioManager.h"

@interface ShowFeedController ()<OpusImageBrowerDelegate> {
    BOOL _didLoadDrawPicture;
    UIImageView* _throwingItem;
    ShareAction *_shareAction;
    BOOL _isDrawInfoFullScreen;
    AudioPlayer *_audioPlayer;
}

@property(nonatomic, retain) UserInfoCell *userCell;
@property(nonatomic, retain) DrawInfoCell *drawCell;
@property(nonatomic, retain) DrawInfoCell *drawCellFullScreen;
@property(nonatomic, retain) CommentHeaderView *commentHeader;
@property(nonatomic, retain) DrawFeed *feed;
@property (nonatomic, retain) UseItemScene* useItemScene;
@property(nonatomic, retain) DetailFooterView *footerView;
@property(nonatomic, retain) Contest *contest;
@property(nonatomic, assign) BOOL isDownloadingData;
@property (copy, nonatomic) NSString *feedId;

//@property(nonatomic, assign) BOOL swipeEnable;

//- (IBAction)clickActionButton:(id)sender;


@end

@implementation ShowFeedController

typedef enum{
    
    SectionUserInfo = 0,
    SectionDrawInfo,
    SectionCommentInfo,
    SectionNumber
    
}Section;

- (void)dealloc
{
    _drawCell.delegate = nil;
    _userCell.delegate = nil;

    _feed.drawData = nil;
    _feed.pbDrawData = nil;
    [_audioPlayer release];
    PPRelease(_contest);
    PPRelease(_feed);
    PPRelease(_drawCell);
    PPRelease(_userCell);
    PPRelease(_tabManager);
    PPRelease(_commentHeader);
    PPRelease(_useItemScene);
    PPRelease(_feedScene);
    PPRelease(_feedId);
    PPRelease(_drawCellFullScreen);
    PPRelease(_shareAction);
    
    [super dealloc];
}

+ (void) enterWithFeedId:(NSString *)feedId
          fromController:(UIViewController *)controller
{
    BOOL isPPViewController = [controller isKindOfClass:[PPViewController class]];
    if (isPPViewController) {
        [(PPViewController *)controller showActivityWithText:NSLS(@"kLoading")];
    }
    [[FeedService defaultService] getFeedByFeedId:feedId completed:^(int resultCode, DrawFeed *feed, BOOL fromCache) {
        if (isPPViewController) {
            [(PPViewController *)controller hideActivity];
        }
        if (resultCode == 0 && feed) {
            ShowFeedController *sf = [[ShowFeedController alloc] initWithFeed:feed];
            [controller.navigationController pushViewController:sf animated:YES];
            [sf release];
        }else{
            POSTMSG(NSLS(@"kLoadFail"));
        }
    }];    
}


- (id)initWithFeed:(DrawFeed *)feed
{
    self = [super init];
    if(self)
    {
        self.feed = feed;        
    }
    return self;
}

- (id)initWithFeed:(DrawFeed *)feed
             scene:(UseItemScene *)scene
{
    return [self initWithFeed:feed scene:scene feedScene:[[[FeedSceneFeedDetail alloc] init] autorelease]];
}

- (id)initWithFeed:(DrawFeed *)feed
             scene:(UseItemScene *)scene
         feedScene:(NSObject<ShowFeedSceneProtocol>*)feedScene
{
    self = [super init];
    if(self)
    {
        self.feed = feed;
        self.useItemScene = scene;
        self.feedScene = feedScene;
    }
    return self;
}

- (void)updateFlowerButton
{
    BOOL enable = [_useItemScene canThrowFlower];
    if (self.contest && [[ContestManager defaultManager] canThrowFlower:self.contest defaultValue:enable] == NO){
        enable = NO;
    }
    
    [self.footerView setButton:FooterTypeFlower enabled:enable];
}

- (void)updateActionButtons
{
    NSMutableArray *types = [NSMutableArray array];
    if ([self.feed showAnswer]
        || [self.feed isContestFeed]
        || ([GameApp disableEnglishGuess]
        && [[UserManager defaultManager] getLanguageType] != ChineseType)
        || [[UserService defaultService] isRegistered] == NO) {
        if ([self.feed isDrawCategory]) {
            [types addObject:@(FooterTypeReplay)];
        }
    }else{
        [types addObject:@(FooterTypeGuess)];
    }
    [types addObjectsFromArray:@[@(FooterTypeComment), @(FooterTypeShare)]];

    if ([self.feed isContestFeed]) {
        Contest *contest = [[ContestManager defaultManager] ongoingContestById:self.feed.contestId];
        if (contest != nil && [contest isRunning]) {
            ContestManager *cm = [ContestManager defaultManager];
            NSString *uid = [[UserManager defaultManager] userId];
            ContestFeed *cf = (ContestFeed *)self.feed;
            if([cm isUser:uid judgeAtContest:cf.contestId]) {
                [types addObject:@(FooterTypeReport)];
                [types addObject:@(FooterTypeRate)];
            }else if([cm isUser:uid reporterAtContest:cf.contestId]){
                [types addObject:@(FooterTypeFlower)];
                [types addObject:@(FooterTypeReport)];
            }else if (![self.feed isMyOpus]) {
                [types addObject:@(FooterTypeFlower)];
            }
        }
    }else if(![self.feed isMyOpus]){
        [types addObject:@(FooterTypeFlower)];
    }
    
    [self.footerView setButtonsWithTypes:types];
    [self updateFlowerButton];
}

- (void)reloadCommentSection
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:SectionCommentInfo];
    [self.dataTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - table view delegate.

- (UITableViewCell *)cellForUserInfoSection
{
    if (self.userCell == nil) {
        self.userCell = [UserInfoCell createCell:self];
        self.userCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self.userCell setCellInfo:self.feed];
    return self.userCell;
}
- (UITableViewCell *)cellForDrawInfoSection
{
    if (_isDrawInfoFullScreen) {
        if (self.drawCellFullScreen == nil) {
            self.drawCellFullScreen = [DrawInfoCell createCellWithFullScreen:self];
            self.drawCellFullScreen.delegate = self;
            [self.drawCellFullScreen setCellInfo:self.feed feedScene:self.feedScene];
            [self.drawCellFullScreen configurePlayerButton];
            [self.drawCellFullScreen.audioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        }

        return self.drawCellFullScreen;
    }else{
        if (self.drawCell == nil) {
            self.drawCell = [DrawInfoCell createCell:self feed:self.feed];
            self.drawCell.delegate = self;
        }
        [self.drawCell setCellInfo:self.feed feedScene:self.feedScene];
        return self.drawCell;
    }
}

#define SPACE_CELL_FONT_SIZE ([DeviceDetection isIPAD] ? 26 : 13)
#define SPACE_CELL_FONT_HEIGHT ([DeviceDetection isIPAD] ? 110 : 44)
#define SPACE_CELL_COUNT 7

- (UITableViewCell *)cellForCommentInfoAtRow:(NSInteger)row
{
    if (row >= [self.dataList count]) {
        NSString * identifier = @"emptyCell";
        UITableViewCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
            cell.textLabel.textColor = COLOR_BROWN;
            
            UIView *v = [[[UIView alloc] initWithFrame:CGRectMake(ISIPAD?28:11, 0, ISIPAD?713:299, SPACE_CELL_FONT_HEIGHT)] autorelease];
            v.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:v];
            [cell.contentView sendSubviewToBack:v];
            cell.backgroundColor = [UIColor clearColor];
        }
        if (row == 0) {
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
            [cell.textLabel setFont:[UIFont systemFontOfSize:SPACE_CELL_FONT_SIZE]];
            TableTab *tab = [_tabManager currentTab];
            if (tab.status == TableTabStatusLoading) {
                [cell.textLabel setText:NSLS(@"kLoading")];
            }else if(tab.status == TableTabStatusLoaded){
                [cell.textLabel setText:tab.noDataDesc];
            }
        }else{
            [cell.textLabel setText:nil];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    NSString * identifier = [CommentCell getCellIdentifier];
    CommentCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CommentCell createCell:self];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    CommentFeed *feed = [self.dataList objectAtIndex:row];
    [cell setCellInfo:feed];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionUserInfo:
        {
           return [self cellForUserInfoSection];
        }
        case SectionDrawInfo:
        {
            return [self cellForDrawInfoSection];
        }
        case SectionCommentInfo:
        {
            return [self cellForCommentInfoAtRow:indexPath.row];
        }
        default:
            return nil;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
    
{
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
//    if (indexPath.section == SectionCommentInfo) {
//        cell.backgroundColor = COLOR_WHITE;
//    }
}

- (NSArray *)dataList
{
    return [[_tabManager currentTab] dataList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SectionUserInfo:
        case SectionDrawInfo:
            return 1;
        case SectionCommentInfo:
        {
            NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
            if (count < SPACE_CELL_COUNT) {
                return SPACE_CELL_COUNT;
            }
            return count;
        }
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionNumber;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionUserInfo:
            return [UserInfoCell getCellHeight];
        case SectionDrawInfo:{
            
            if (_isDrawInfoFullScreen) {
                return [DrawInfoCell cellHeightWithFullScreen];
            }else{
                return [DrawInfoCell cellHeightWithFeed:self.feed];
            }
        }
        case SectionCommentInfo:
        {
            if (indexPath.row == 0) {

            }
            if (indexPath.row >= [self.dataList count]) {
                return SPACE_CELL_FONT_HEIGHT;
            }
            CommentFeed *feed = [self.dataList objectAtIndex:indexPath.row];
            CGFloat height = [CommentCell getCellHeight:feed];
            return height;
        }
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == SectionCommentInfo) ? [CommentHeaderView getHeight] : 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == SectionCommentInfo)
    {
        [self.commentHeader updateTimes:self.feed];
        return self.commentHeader;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionUserInfo:

        {
            FeedUser *feedUser = self.feed.author;
            
            
            if ([[ContestManager defaultManager] displayContestAnonymousForFeed:self.feed] == NO){
                [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:feedUser.userId
                                                                                              avatar:feedUser.avatar
                                                                                            nickName:feedUser.nickName]
                                           inViewController:self];
            }
            
        }
            break;
            
        default:
            break;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentFeed *feed = [self.dataList objectAtIndex:indexPath.row];
    [self showActivityWithText:NSLS(@"kDeleting")];
    [[FeedService defaultService] deleteFeed:feed delegate:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != SectionCommentInfo) {
        return false;
    }
    if (indexPath.row < [self.dataList count]) {
        CommentFeed *feed = [self.dataList objectAtIndex:indexPath.row];
        //can only delete comment feed, but flower and tomato.
        return [feed isMyFeed] ||
        ([self.feed isMyOpus] && feed.feedType == FeedTypeComment)||
        [[UserManager defaultManager] isSuperUser];
    }
    return NO;
}

- (void)didDeleteFeed:(Feed *)feed
           resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDeleteFail") delayTime:1.5 isHappy:NO];
        return;
    }
    
    if (feed.feedType == FeedTypeComment) {
        [self.feed decTimesForType:FeedTimesTypeComment];
    }else if(feed.feedType == FeedTypeGuess)
    {
        [self.feed decTimesForType:FeedTimesTypeGuess];
    }else if(feed.feedType == FeedTypeFlower)
    {
        [self.feed decTimesForType:FeedTimesTypeFlower];
    }else if(feed.feedType == FeedTypeTomato)
    {
        [self.feed decTimesForType:FeedTimesTypeTomato];
    }
    
    NSMutableArray *list = [[_tabManager currentTab] dataList];
    [list removeObject:feed];
    [self reloadCommentSection];
    [self finishDeleteData:feed ForTabID:feed.feedType];

}


#pragma mark update views
- (void)updateTitle
{
    NSString *title = nil;
    if ([self.feed isContestFeed]) {
        title = [NSString stringWithFormat:NSLS(@"kContestFeedDetail")];        
    }else if ([self.feedScene showFeedTitle] != nil) {
        title = [self.feedScene showFeedTitle];
    }else if ([self.feed showAnswer] && [self.feed.wordText length] != 0) {
        title = [NSString stringWithFormat:NSLS(@"[%@]"),
                 self.feed.wordText];        
    }else {
        title = [NSString stringWithFormat:NSLS(@"kFeedDetail")];
    }
    
    [self.titleLabel setText:title];
    
    [[CommonTitleView titleView:self.view] setTitle:title];
}

- (void)updateUserInfo
{
    [self.userCell setCellInfo:self.feed];
}
#pragma mark - cell delegate
- (void)didUpdateShowView
{
    //update the action buttons
    [self updateActionButtons];
    [self updateTitle];
    [self.dataTableView reloadData];
}

- (void)didClickDrawToUser:(NSString *)userId nickName:(NSString *)nickName
{
    
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nickName] inViewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    if (![self isCurrentTabLoading] || [self.feedScene isKindOfClass:[FeedSceneDetailGuessResult class]]) {
        [self reloadTableViewDataSource];
    }
    
    [self updateTitle];
    [self updateActionButtons];
    [self.feed setDrawData:nil];
    [self.feed setPbDrawData:nil];
    
    if ([self.feed isSingCategory]) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
        [self configNowPlayingInfoCenter];
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    if ([self.feed isSingCategory]) {
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [self resignFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self unregisterAllNotifications];
}

#pragma mark - feed service delegate

- (void)didGetFeedCommentList:(NSArray *)feedList 
                       opusId:(NSString *)opusId
                         type:(int)type
                   resultCode:(NSInteger)resultCode
                       offset:(int)offset
{
    if (resultCode == 0) {
        [self finishLoadDataForTabID:type resultList:feedList];
    }else{
        [self failLoadDataForTabID:type];
    }
}

#define ITEM_TAG_OFFSET 20120728

- (void)showCoinsNotEnoughView
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotEnoughCoin")
                                                       message:NSLS(@"kCoinsNotEnough")
                                                         style:CommonDialogStyleDoubleButton
                                                      delegate:self
                            ];
    [dialog showInView:self.view];
}

- (void)throwItem:(int)itemId
{
    BOOL isFree = [_feed isContestFeed];
    BOOL itemEnough = YES;        
    [self showItemAnimation:itemId isFree:isFree itemEnough:itemEnough];
}


- (void)showItemAnimation:(int)itemId
                   isFree:(BOOL)isFree
               itemEnough:(BOOL)itemEnough
{
    if (itemId == ItemTypeFlower) {
        
        [self.feed increaseLocalFlowerTimes];
        
        __block typeof (self) bself = self;
        [[FlowerItem sharedFlowerItem] useItem:_feed.author.userId
                                     isOffline:YES
                                      drawFeed:_feed
                                       forFree:isFree
                                 resultHandler:^(int resultCode, int itemId, BOOL isBuy)
        {
            
            
            if (resultCode == ERROR_SUCCESS){
                
                ShareImageManager *imageManager = [ShareImageManager defaultManager];
                CGRect frame = [bself.footerView buttonWithType:FooterTypeFlower].frame;
                frame = [self.view convertRect:frame fromView:self.footerView];
                UIImageView* throwItem = [[[UIImageView alloc] initWithFrame:frame] autorelease];
                [throwItem setImage:[imageManager flower]];
                
                BOOL showTips = [UseItemScene shouldItemMakeEffectInScene:bself.useItemScene.sceneType];
                [DrawGameAnimationManager showThrowFlower:throwItem
                                         animInController:bself
                                                  rolling:YES
                                               itemEnough:!isBuy
                                           shouldShowTips:showTips
                                               completion:^(BOOL finished) {

                                                   [bself clickRefreshButton:nil];
                                                   
                                                   if (showTips == NO && self.contest != nil){
                                                       int userCurrentFlowers = 0;
                                                       int maxFlowerPerContest = 0;
                                                       
                                                       userCurrentFlowers = [[UserManager defaultManager] flowersUsed:self.contest.contestId];
                                                       maxFlowerPerContest = [self.contest maxFlowerPerContest ];
                                                       PPDebug(@"<throwFlow> userCurrentFlowers=%d maxFlowerPerContest=%d", userCurrentFlowers, maxFlowerPerContest);
                                                       
                                                       NSString* msg = [NSString stringWithFormat:NSLS(@"kContestThrowFlowerMsg"), userCurrentFlowers, maxFlowerPerContest - userCurrentFlowers];
                                                       POSTMSG(msg);
                                                   }
                }];
                [bself.commentHeader setSelectedType:CommentTypeFlower];
                [bself.feed incTimesForType:FeedTimesTypeFlower];
            }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
                [BalanceNotEnoughAlertView showInController:bself];
                [bself.feed decreaseLocalFlowerTimes];
            }else if (resultCode == ERROR_CONTEST_REACH_MAX_FLOWER){
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kReachMaxFlowerPerContest") delayTime:2 isHappy:NO];
                [bself.feed decreaseLocalFlowerTimes];
            }else if (resultCode == ERROR_CONTEST_EXCEED_THROW_FLOWER_DATE){
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kReachContestVoteEndDate") delayTime:2 isHappy:NO];
                [bself.feed decreaseLocalFlowerTimes];
            }else{
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:NO];
                [bself.feed decreaseLocalFlowerTimes];
            }
            
            
        }];
    }
}


- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView
{
    if ([PPConfigManager wallEnabled]) {
        [LmWallService showWallOnController:self];
    }else {
        ChargeController* controller = [[[ChargeController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)setProgress:(CGFloat)progress
{
    BOOL isDownloadDone = NO;
    if (progress == 1.0f){
        // make this because after uploading data, it takes server sometime to process
        progress = 0.99;
        isDownloadDone = YES;
    }
    
    NSString* progressText = nil;    
    if (isDownloadDone){
        progressText = [NSString stringWithFormat:NSLS(@"kParsingData")];
    }
    else{
        progressText = [NSString stringWithFormat:NSLS(@"kLoadingProgress"), progress*100];
    }
    
    [self showProgressViewWithMessage:progressText progress:progress];
}

- (void)loadDrawDataWithHanlder:(dispatch_block_t)handler
{

    if (handler == NULL)
        return;

    [self showProgressViewWithMessage:NSLS(@"kLoading")];
    if (self.feed.pbDrawData){
        [self hideProgressView];
        handler();
        return;
    }
    
    __block ShowFeedController * cp = self;
    [[FeedService defaultService] getPBDrawByFeed:self.feed
                                          handler:
     ^(int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache)
    {
        if(resultCode == 0 && pbDrawData != nil){
            cp.feed.pbDrawData = pbDrawData;
            handler();
        }else{
            POSTMSG(NSLS(@"kFailLoad"));
        }

        [cp hideProgressView];
    }
     downloadDelegate:self];
}

#pragma mark - Click Actions

- (void)performGuess
{
    if ([self.feed isDrawCategory]) {
        [self perFormDrawGuess];
    }else if ([self.feed isSingCategory]){
        [self performSingGuess];
    }
}

- (void)perFormDrawGuess{
    
    __block ShowFeedController * cp = self;
    //enter guess controller
    [self loadDrawDataWithHanlder:^{
        
        [self registerNotificationWithName:NOTIFICATION_DATA_PARSING usingBlock:^(NSNotification *note) {
            float progress = [[[note userInfo] objectForKey:KEY_DATA_PARSING_PROGRESS] floatValue];
            NSString* progressText = @"";
            if (progress == 1.0f){
                progress = 0.99f;
                progressText = [NSString stringWithFormat:NSLS(@"kDisplayProgress"), progress*100];
            }
            else{
                progressText = [NSString stringWithFormat:NSLS(@"kParsingProgress"), progress*100];
            }
            [self showProgressViewWithMessage:progressText progress:progress];
        }];
        
        [self showProgressViewWithMessage:NSLS(@"kParsingProgress") progress:0.01f];
        dispatch_async(workingQueue, ^{
            if (cp.feed.drawData == nil) {
                [cp.feed parseDrawData];
                cp.feed.pbDrawData = nil;   // add by Benson to clear the data for memory usage
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cp unregisterNotificationWithName:NOTIFICATION_DATA_PARSING];
                [[self.footerView buttonWithType:FooterTypeGuess] setUserInteractionEnabled:YES];
                [OfflineGuessDrawController startOfflineGuess:cp.feed fromController:cp];
                [cp.commentHeader setSelectedType:CommentTypeGuess];
                [cp hideActivity];
            });
        });
    }];
}

- (void)performSingGuess{

//    [self showActivityWithText:NSLS(@"kLoading")];
    [_audioPlayer pause];
    [OfflineGuessDrawController startOfflineGuess:self.feed fromController:self];
//    [self hideActivity];
}

- (void)reportPlayTimes
{
    [[FeedService defaultService] playOpus:self.feed.feedId contestId:self.feed.contestId resultBlock:^(int resultCode) {
        [self.feed incPlayTimes];
        [self.commentHeader updateTimes:self.feed];
    }];
}

- (void)performReplay
{
    if ([self.feed isDrawCategory]) {
        [self reportPlayTimes];
        [self performReplayDraw];
    }else if ([self.feed isSingCategory]){
        [self performReplaySing];
    }
}

- (void)performReplaySing{
    
    [self didClickFullScreenButton];
}

- (void)performReplayDraw
{
    __block ShowFeedController * cp = self;

    _isDownloadingData = YES;
    [self loadDrawDataWithHanlder:^{
        
        _isDownloadingData = NO;
        
        [self registerNotificationWithName:NOTIFICATION_DATA_PARSING usingBlock:^(NSNotification *note) {
            float progress = [[[note userInfo] objectForKey:KEY_DATA_PARSING_PROGRESS] floatValue];
            NSString* progressText = @"";
            if (progress == 1.0f){
                progress = 0.99f;
                progressText = [NSString stringWithFormat:NSLS(@"kDisplayProgress"), progress*100];
            }
            else{
                progressText = [NSString stringWithFormat:NSLS(@"kParsingProgress"), progress*100];
            }
            [self showProgressViewWithMessage:progressText progress:progress];
        }];
        
        [[self.footerView buttonWithType:FooterTypeReplay] setUserInteractionEnabled:YES];
        
        [self showProgressViewWithMessage:NSLS(@"kParsingProgress") progress:0.01f];
        dispatch_async(workingQueue, ^{
            if (cp.feed.drawData == nil) {
                [cp.feed parseDrawData];
                cp.feed.pbDrawData = nil;   // add by Benson to clear the data for memory usage
            }
                
            dispatch_async(dispatch_get_main_queue(), ^{
                                
                [self unregisterNotificationWithName:NOTIFICATION_DATA_PARSING];

                NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
                
                ReplayObject *obj = [ReplayObject obj];
                obj.actionList = cp.feed.drawData.drawActionList;
                obj.isNewVersion = [cp.feed.drawData isNewVersion];
                obj.canvasSize = cp.feed.drawData.canvasSize;
                obj.layers = cp.feed.drawData.layers;
                
                DrawPlayer *player = [DrawPlayer playerWithReplayObj:obj];
                [player showInController:cp];
                
                [pool drain];
                
                [self hideActivity];
            });
        });
    }];
    
}

- (void)gotoContestComment
{
    [_commentHeader setSelectedType:CommentTypeContestComment];
    CommentController *cc = [[CommentController alloc] initWithFeed:self.feed forContestReport:YES];
    [self presentModalViewController:cc animated:YES];
    [cc release];
}

- (UIImage*)getFeedImage
{
    UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:self.feed.drawImageUrl];
    if (image == nil) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.feed.drawImageUrl];
    }
    
    if (image == nil){
        image = self.feed.largeImage;
    }

    return image;
}

- (void)detailFooterView:(DetailFooterView *)footer
        didClickAtButton:(UIButton *)button
                    type:(NSInteger)type
{
    switch (type) {
        case FooterTypeGuess:            
        {
            CHECK_AND_LOGIN(self.view);            
            [self performSelector:@selector(performGuess) withObject:nil afterDelay:0.1f];
            button.userInteractionEnabled = NO;
            break;
        }
        case FooterTypeReplay:
        {
            [self performSelector:@selector(performReplay) withObject:nil afterDelay:0.1f];
            button.userInteractionEnabled = NO;
            break;
        }
        case FooterTypeComment:
        {
            CHECK_AND_LOGIN(self.view);
            
            CommentController *cc = [[CommentController alloc] initWithFeed:self.feed forContestReport:NO];
            [self presentModalViewController:cc animated:YES];
            [_commentHeader setSelectedType:CommentTypeComment];
            [cc release];
            break;

        }
        case FooterTypeShare:
        {
            CHECK_AND_LOGIN(self.view);

            UIImage* image = [self getFeedImage];
            if (_shareAction == nil) {
                _shareAction = [[ShareAction alloc] initWithFeed:_feed
                                                           image:image];
            }
            [_shareAction displayWithViewController:self onView:button];
            break;
        }
        case FooterTypeFlower:
        {
            CHECK_AND_LOGIN(self.view);
            
            [self throwItem:ItemTypeFlower];
            [self updateFlowerButton];
            break;
        }
        case FooterTypeReport:
        {
            CHECK_AND_LOGIN(self.view);
            
            [self gotoContestComment];
            break;
        }
         
        case FooterTypeRate:
        {
            CHECK_AND_LOGIN(self.view);
            
            Contest *contest = [[ContestManager defaultManager] ongoingContestById:self.feed.contestId];
            if (contest) {
                JudgerScoreView *scoreView = [JudgerScoreView judgerScoreViewWithContest:contest opus:(id)self.feed];
                [scoreView showInView:self.view];
            }
            break;
        }            
        default:
            break;
    }
}


//override super clickBlackButton method
- (IBAction)clickBackButton:(id)sender
{
    [self unregisterAllNotifications];
    
    PPDebug(@"<clickBack>");
    [_audioPlayer pauseForQuit];
    PPRelease(_audioPlayer);
    PPDebug(@"<clickBack> audio stop end");
    
    if (_popToRootController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.feedScene didClickBackBtn:self];
    }
    
    // clear delegate to avoid callback
    self.drawCell.delegate = nil;
    self.drawCellFullScreen.delegate = nil;
    
    PPRelease(_shareAction);
}


#pragma mark - comment cell delegate
- (void)didStartToReplyToFeed:(CommentFeed *)feed
{
    CHECK_AND_LOGIN(self.view);
    PPDebug(@"<didStartToReplyToFeed>, feed type = %d,comment = %@", feed.feedType,feed.comment);
    CommentController *replyController = [[CommentController alloc] initWithFeed:self.feed commentFeed:feed];
    [self presentModalViewController:replyController animated:YES];
    [replyController release];
}

- (void)didClickAvatar:(MyFriend *)myFriend
{
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:myFriend.friendUserId avatar:myFriend.avatar nickName:myFriend.nickName] inViewController:self];
}

#pragma mark draw data service delegate
- (void)didSaveOpus:(BOOL)succ
{
    [self hideActivity];
    if (succ) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveOpusOK") delayTime:1.5 isHappy:YES];
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveImageFail") delayTime:1.5 isHappy:NO];
    }
}

#pragma mark comment header delegate

- (void)didSelectCommentType:(int)type
{
    [self clickTab:type];
}



#pragma mark - override methods.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.unReloadDataWhenViewDidAppear = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)initTabButtons
{
    [super initTabButtons];
    self.commentHeader = [CommentHeaderView createCommentHeaderView:self];
    [self.commentHeader setViewInfo:self.feed];
    [self.commentHeader setSelectedType:CommentTypeComment];
}


- (void)reloadView
{
    [self updateActionButtons];
    [self updateTitle];
    [[FeedService defaultService] getFeedByFeedId:_feed.feedId
                                         delegate:self];
    [self.dataTableView reloadData];
    [_commentHeader setViewInfo:self.feed];
}

- (void)initFooterView
{
    self.footerView = [DetailFooterView footerViewWithDelegate:self];
    [self.view addSubview:self.footerView];
    
}

- (void)baseInit
{
    [self setPullRefreshType:PullRefreshTypeFooter];
    [super viewDidLoad];
    
    
    [self.refreshFooterView setBackgroundColor:[UIColor clearColor]];
    
    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setRightButtonAsRefresh];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    
    [self initFooterView];
    [self initTabButtons];
    [self setShowTipsDisable:YES];
    
    self.contest = [[ContestManager defaultManager] ongoingContestById:self.feed.contestId];
    
    if (!self.useItemScene) {
        UseSceneType type = UseSceneTypeShowFeedDetail;
        if ([_feed isContestFeed]) {
            type = [_contest isRunning] ? UseSceneTypeDrawMatch : UseSceneTypeMatchRank;
        }
        self.useItemScene = [UseItemScene createSceneByType:type feed:_feed];
    }
    
    if (!self.feedScene) {
        self.feedScene = [[[FeedSceneFeedDetail alloc] init] autorelease];
    }
    
    [self reloadView];
}

- (void)viewDidLoad
{
    [self baseInit];
    if ([self.feed isSingCategory]) {
        self.canDragBack = NO;
    }
}

- (void)showOpusImageBrower{
    
    if ([self.feed isDrawCategory]) {
        OpusImageBrower *brower = [[[OpusImageBrower alloc] initWithFeedList:@[self.feed]] autorelease];
        brower.delegate = self;
        [brower showInView:self.view];
    }
}


- (void)brower:(OpusImageBrower *)brower didSelecteFeed:(DrawFeed *)feed{
    
}

- (void)viewDidUnload
{
    self.drawCellFullScreen.delegate = nil;
    self.drawCell.delegate = nil;
    
    [self.feed setDrawData:nil];
    [self setFeed:nil];
    [self setDrawCell:nil];
    [self setUserCell:nil];
    [self setCommentHeader:nil];
    
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didGetFeed:(DrawFeed *)feed
        resultCode:(NSInteger)resultCode
         fromCache:(BOOL)fromCache
{
    if (resultCode == 0 && [feed.feedId isEqualToString:self.feed.feedId]) {
        feed.largeImage = self.feed.largeImage;
        feed.wordText = self.feed.wordText;
        self.feed = feed;
        [_commentHeader setViewInfo:self.feed];
        [self.dataTableView reloadData];
    }else{
        PPDebug(@"<didGetFeed> Failed!!!");
    }
}



- (void)didUpdateFeedTimes:(DrawFeed *)feed
                resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        [_commentHeader setViewInfo:feed];
    }
}

#pragma mark - DrawInfoCell delegate

- (void)didLoadDrawPicture
{
    _didLoadDrawPicture = YES;
    [self updateActionButtons];
}

- (void)share:(PPSNSType)type
{
    NSString* text = [ShareAction shareTextByDrawFeed:self.feed snsType:type];
    NSString* imagePath = [ShareAction createFeedImagePath:self.feed];
    
    NSString* audioURL = nil;
    if ([self.feed isSingCategory]){
        audioURL = self.feed.drawDataUrl;
    }
    
    [[GameSNSService defaultService] publishWeibo:type
                                             text:text
                                    imageFilePath:imagePath
                                         audioURL:audioURL
                                            title:self.feed.pbFeed.opusDesc
                                           inView:self.view
                                       awardCoins:[PPConfigManager getShareWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")];
    
}

- (void)didClickDrawImageMaskView
{
    CHECK_AND_LOGIN(self.view);
    
    int index = 0;
    int indexOfGuess = -1;
    int indexOfPlay = -1;
    int indexOfPhoto = -1;
    int indexOfFeature = -1;
    int indexOfUnfeature = -1;
    int indexOfSetScore = -1;
    int indexOfDelete = -1;
    
    
    MKBlockActionSheet *sheet = nil;
    BOOL canFeature = [[UserManager defaultManager] canFeatureDrawOpus];
    
    if ([[UserManager defaultManager] isSuperUser]){
        sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                 delegate:nil
                                        cancelButtonTitle:NSLS(@"kCancel")
                                   destructiveButtonTitle:NSLS(@"kGuess")
                                        otherButtonTitles:NSLS(@"kPlay"), NSLS(@"kLargeImage"), NSLS(@"分数处理"), NSLS(@"kRecommend"), NSLS(@"kUnfeature"), NSLS(@"删除作品"),
                 NSLS(@"kShareSinaWeibo"), NSLS(@"kShareWeixinSession"), NSLS(@"kShareWeixinTimeline"), NSLS(@"kShareQQWeibo"), // NSLS(@"kShareQQSpace"),                 
                 nil];
        indexOfGuess = index++;
        indexOfPlay = index++;
        indexOfPhoto = index++;
        indexOfSetScore = index++;
        indexOfFeature = index++;
        indexOfUnfeature = index++;
        indexOfDelete = index++;
    }
    else if (![self.feed showAnswer]) {
        if (canFeature){
            sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                     delegate:nil
                                            cancelButtonTitle:NSLS(@"kCancel")
                                       destructiveButtonTitle:NSLS(@"kGuess")
                                            otherButtonTitles:NSLS(@"kPlay"), NSLS(@"kLargeImage"), NSLS(@"kRecommend"), NSLS(@"kUnfeature"),
                     NSLS(@"kShareSinaWeibo"), NSLS(@"kShareWeixinSession"), NSLS(@"kShareWeixinTimeline"), NSLS(@"kShareQQWeibo"), // NSLS(@"kShareQQSpace"),
                     nil];
            indexOfGuess = index++;
            indexOfPlay = index++;
            indexOfPhoto = index++;
            indexOfFeature = index++;
            indexOfUnfeature = index++;
        }
        else{
            sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                     delegate:nil
                                            cancelButtonTitle:NSLS(@"kCancel")
                                       destructiveButtonTitle:NSLS(@"kGuess")
                                            otherButtonTitles:NSLS(@"kPlay"),
                     NSLS(@"kLargeImage"),
                     NSLS(@"kShareSinaWeibo"), NSLS(@"kShareWeixinSession"), NSLS(@"kShareWeixinTimeline"), NSLS(@"kShareQQWeibo"), // NSLS(@"kShareQQSpace")
                     nil];
            indexOfGuess = index++;
            indexOfPlay = index++;
            indexOfPhoto = index++;

        }
    }else{
        indexOfPlay = index++;
        indexOfPhoto = index++;

        if (canFeature){
            sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                     delegate:nil
                                            cancelButtonTitle:NSLS(@"kCancel")
                                       destructiveButtonTitle:NSLS(@"kPlay") otherButtonTitles:NSLS(@"kLargeImage"),
                     NSLS(@"kShareSinaWeibo"), NSLS(@"kShareWeixinSession"),
                     NSLS(@"kShareWeixinTimeline"), NSLS(@"kShareQQWeibo"), // NSLS(@"kShareQQSpace"),                     
                     NSLS(@"kRecommend"), NSLS(@"kUnfeature"), nil];
        
            indexOfFeature = index++;
            indexOfUnfeature = index++;
        }
        else{
            sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                     delegate:nil
                                            cancelButtonTitle:NSLS(@"kCancel")
                                       destructiveButtonTitle:NSLS(@"kPlay") otherButtonTitles:NSLS(@"kLargeImage"),
                     NSLS(@"kShareSinaWeibo"), NSLS(@"kShareWeixinSession"),
                     NSLS(@"kShareWeixinTimeline"), NSLS(@"kShareQQWeibo"),  //NSLS(@"kShareQQSpace"),
                     nil];
        }
    }
    
    int indexOfShareSinaWeibo = index++;
    int indexOfShareWeixinSession = index++;
    int indexOfShareWeixinTimeline = index++;
    int indexOfShareQQWeibo = index++;
    int indexOfShareQQSpace = -1;
    
    [sheet setActionBlock:^(NSInteger buttonIndex){
        if (buttonIndex == indexOfGuess) {
            [self performSelector:@selector(performGuess) withObject:nil afterDelay:0.1f];
        }else if (buttonIndex == indexOfPhoto){
            [self showPhotoBrower];
        }else if (buttonIndex == indexOfPlay){
            [self performSelector:@selector(performReplay) withObject:nil afterDelay:0.1f];
        }else if (buttonIndex == indexOfFeature){
            [[FeedService defaultService] recommendOpus:self.feed.feedId
                                              contestId:self.feed.contestId
                                            resultBlock:^(int resultCode) {
                if (resultCode == 0){
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFeatureSucc") delayTime:2];
                }                
            }];
        }
        else if (buttonIndex == indexOfUnfeature){
            [[FeedService defaultService] unRecommendOpus:self.feed.feedId resultBlock:^(int resultCode) {
                if (resultCode == 0){
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUnfeatureSucc") delayTime:2];
                }
            }];
        }
        else if (buttonIndex == indexOfSetScore){
            [[FeedService defaultService] askSetHotScore:self.feed.feedId viewController:self];
        }
        else if (buttonIndex == indexOfDelete){
            
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:@"消息" message:@"是否确认删除作品？" style:CommonDialogStyleDoubleButton];
            
            [dialog setClickOkBlock:^(id dialog){
                [[FeedService defaultService] deleteFeed:self.feed delegate:self];                
            }];
            
            [dialog showInView:self.view];
        }
        else if (buttonIndex == indexOfShareSinaWeibo){
            [self share:TYPE_SINA];
        }
        else if (buttonIndex == indexOfShareWeixinSession){
            [self share:TYPE_WEIXIN_SESSION];
        }
        else if (buttonIndex == indexOfShareWeixinTimeline){
            [self share:TYPE_WEIXIN_TIMELINE];
        }
        else if (buttonIndex == indexOfShareQQSpace){
            [self share:TYPE_QQSPACE];
        }
        else if (buttonIndex == indexOfShareQQWeibo){
            [self share:TYPE_QQ];
        }

        
        [sheet setActionBlock:NULL];
    }];
    [sheet showInView:self.view];
    [sheet release];

}

- (void)showPhotoBrower{

    [[ImagePlayer defaultPlayer]  playWithUrl:self.feed.largeImageURL displayActionButton:YES onViewController:self];
}

#pragma mark-- Common Tab Controller Delegate

- (NSInteger)tabCount
{
    return [CommentHeaderView getTypeCountByFeed:self.feed];
}

- (NSInteger)currentTabIndex
{
    return _defaultTabIndex;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 12;
}

- (NSInteger)tabIDforIndex:(NSInteger)index
{    return [CommentHeaderView getTypeListByFeed:self.feed][index];   
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return nil;
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    NSDictionary *dict = @{@(CommentTypeComment) : NSLS(@"kNoComments"),
                           @(CommentTypeGuess) : NSLS(@"kNoGuesses"),
                           @(CommentTypeFlower) : NSLS(@"kNoFlowers"),
//                           @(CommentTypeContestComment) : NSLS(@"kNoData")
                           };
    CommentType type = [self tabIDforIndex:index];
    return dict[@(type)] ? dict[@(type)] : NSLS(@"kNoData");
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
//    PPDebug(@"<ShowFeedController> load data with tab ID = %d", tabID);
    
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FeedService defaultService] getOpusCommentList:_feed.feedId
                                                type:tab.tabID
                                              offset:tab.offset
                                               limit:tab.limit
                                            delegate:self];
}

- (void)didClickFullScreenButton{

    [self reportPlayTimes];
    
    if (_isDrawInfoFullScreen == NO) {
        _isDrawInfoFullScreen = YES;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        
        [self.dataTableView beginUpdates];
        [self.dataTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.dataTableView endUpdates];
        
        [self.dataTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [self play];

        
        
        
    }
}

- (void)didClickNonFullScreenButton{
    
    if (_isDrawInfoFullScreen == YES) {
        _isDrawInfoFullScreen = NO;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        
        [self.dataTableView beginUpdates];
        [self.dataTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.dataTableView endUpdates];
        
        [self.dataTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [_audioPlayer pause];
    }
}

- (void)playAudio:(AudioButton *)button
{
//    [[AudioManager defaultManager] playSoundByName:SOUND_EFFECT_BUTTON_CLICK];
    [_audioPlayer pauseOrResume];
}

- (void)play{
    
    if ([self.feed.drawDataUrl length] == 0) {
        POSTMSG2(NSLS(@"kAudioUrlIsBlank"), 2);
        return;
    }
    
    if (_audioPlayer == nil) {
        _audioPlayer = [[AudioPlayer alloc] init];
        _audioPlayer.url = [NSURL URLWithString:self.feed.drawDataUrl];
        _audioPlayer.button = _drawCellFullScreen.audioButton;
        
        [_drawCellFullScreen.slider setValue:0];
        _audioPlayer.slider = _drawCellFullScreen.slider;
        [_audioPlayer.slider addTarget:self
                                action:@selector(sliderValueChange:)
                      forControlEvents:UIControlEventValueChanged];
    }
    
//    [[AudioManager defaultManager] playSoundByName:SOUND_EFFECT_BUTTON_CLICK];

    [_audioPlayer play];
}

- (void)sliderValueChange:(CustomSlider *)slider{
    
    PPDebug(@"<sliderValueChange>");
    [_audioPlayer seekToProgress:slider.value];
}

-(void)configNowPlayingInfoCenter{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.feed.wordText forKey:MPMediaItemPropertyTitle];
    [dict setObject:self.feed.author.nickName forKey:MPMediaItemPropertyArtist];
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:self.feed.pbFeed.opusImage];
    if (image == nil) {
        image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:self.feed.pbFeed.opusThumbImage];
    }
    
    if (image != nil) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
        [artwork release];
    }
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    [dict release];
}



-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                [_audioPlayer play];
                break;
            }
            
            default:
                break;
        }
    }
    
}

@end
