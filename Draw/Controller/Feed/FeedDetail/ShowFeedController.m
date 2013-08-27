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
#import "ReplayView.h"

#import "UseItemScene.h"

#import "MyFriend.h"
#import "FeedClasses.h"
#import "ShareAction.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "AccountService.h"
#import "ConfigManager.h"
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

#import "MWPhotoBrowser.h"
#import "UIButton+WebCache.h"
#import "ContestManager.h"

@interface ShowFeedController () {
    BOOL _didLoadDrawPicture;
    UIImageView* _throwingItem;
    ShareAction *_shareAction;
//    BOOL isJudgerPopupShowing;
}



@property(nonatomic, retain) UserInfoCell *userCell;
@property(nonatomic, retain) DrawInfoCell *drawCell;
@property(nonatomic, retain) CommentHeaderView *commentHeader;
@property(nonatomic, retain) DrawFeed *feed;
@property (nonatomic, retain) UseItemScene* useItemScene;
@property(nonatomic, retain) DetailFooterView *footerView;
@property(nonatomic, retain) PPPopTableView *judgerPopupView;

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
//    [_brower release];
    
    PPRelease(_feed);
    PPRelease(_drawCell);
    PPRelease(_userCell);
    PPRelease(_tabManager);
    PPRelease(_commentHeader);
    PPRelease(_useItemScene);
    PPRelease(_feedScene);
    PPRelease(_judgerPopupView);
    [super dealloc];
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


#pragma mark-- Swip action
- (void)handleSwipe:(UISwipeGestureRecognizer *)swp
{
    if ([self.feedList count] != 0 && swp.state == UIGestureRecognizerStateRecognized) {
        NSInteger currentIndex = NSNotFound;
        //[self.feedList indexOfObject:self.feed];
        NSInteger i = 0;
        for (DrawFeed *feed in self.feedList) {
            if ([feed.feedId isEqualToString:self.feed.feedId]) {
                currentIndex = i;
                break;
            }
            i ++;
        }
        if (currentIndex == NSNotFound) {
            return;
        }
        DrawFeed *feed = nil;
        if (swp.direction == UISwipeGestureRecognizerDirectionRight) {
            currentIndex --;
            if (currentIndex >= 0) {
                feed = [self.feedList objectAtIndex:currentIndex];
            }else{
                [self popupUnhappyMessage:NSLS(@"kScrollToFirst") title:nil];
            }
        }else if(swp.direction == UISwipeGestureRecognizerDirectionLeft){
            currentIndex ++;
            if (currentIndex < [self.feedList count]) {
                feed = [self.feedList objectAtIndex:currentIndex];
            }else{
                [self popupUnhappyMessage:NSLS(@"kScrollToEnd") title:nil];
            }
        }
        
#define TIME_INTERVAL 0.35
        
        if (feed  && (time(0) - timestamp) > TIME_INTERVAL) {
            timestamp = time(0);
            self.feed = feed;
            self.useItemScene.feed = self.feed;
            self.feedScene = [[[FeedSceneFeedDetail alloc] init] autorelease];
            [_tabManager reset];
            [self reloadView];
            [self clickTab:self.currentTab.tabID];

            self.dataTableView.alpha = 0.3;
            [UIView animateWithDuration:0.8 animations:^{
                self.dataTableView.alpha = 1;
            }];
            
        }
    }
}

- (void)addSwipe
{
    [self setSwipeToBack:NO];
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:left];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    left.delegate = self;
    [left release];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:right];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    right.delegate = self;
    [right release];

}

- (void)updateFlowerButton
{
    BOOL enable = [_useItemScene canThrowFlower];
    [self.footerView setButton:FooterTypeFlower enabled:enable];
}
- (void)updateActionButtons
{
    NSMutableArray *types = [NSMutableArray array];
    if ([self.feed showAnswer] || [self.feed isContestFeed] || ([GameApp disableEnglishGuess] && [[UserManager defaultManager] getLanguageType] != ChineseType)) {
        [types addObject:@(FooterTypeReplay)];
    }else{
        [types addObject:@(FooterTypeGuess)];
    }
    [types addObjectsFromArray:@[@(FooterTypeComment), @(FooterTypeShare)]];
    
    if ([self.feed isContestFeed]) {
        ContestManager *cm = [ContestManager defaultManager];
        NSString *uid = [[UserManager defaultManager] userId];
        ContestFeed *cf = (ContestFeed *)self.feed;
        BOOL canThrowFlower = YES;
        if([cm isUser:uid reporterAtContest:cf.contestId]){
            [types addObject:@(FooterTypeReport)];
            canThrowFlower = NO;
        }
        
#if DEBUG
        if (YES || [cm isUser:uid judgeAtContest:cf.contestId]) {
#else
        if([cm isUser:uid judgeAtContest:cf.contestId]) {
#endif
            [types addObject:@(FooterTypeJudge)];
            canThrowFlower = NO;
        }
        if (canThrowFlower && ![self.feed isMyOpus]) {
            [types addObject:@(FooterTypeFlower)];
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
    if (self.drawCell == nil) {
        self.drawCell = [DrawInfoCell createCell:self];
        self.drawCell.delegate = self;
    }
    [self.drawCell setCellInfo:self.feed feedScene:self.feedScene];
    return self.drawCell;

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
    if (indexPath.section == SectionCommentInfo) {
        cell.backgroundColor = COLOR_WHITE;
    }
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
            return [DrawInfoCell cellHeightWithDesc:self.feed.opusDesc];
        }
//            return [DrawInfoCell getCellHeight];
        case SectionCommentInfo:
        {
            if (indexPath.row == 0) {
//                PPDebug(@"row = %d", indexPath.row);
            }
            if (indexPath.row >= [self.dataList count]) {
                return SPACE_CELL_FONT_HEIGHT;
            }
            CommentFeed *feed = [self.dataList objectAtIndex:indexPath.row];
            CGFloat height = [CommentCell getCellHeight:feed];
//            PPDebug(@"row = %d, height = %f", indexPath.row ,height);
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
//            MyFriend *friend = [MyFriend friendWithFid:feedUser.userId
//                                              nickName:feedUser.nickName
//                                                avatar:feedUser.avatar
//                                                gender:feedUser.genderString
//                                                 level:1];
//            [DrawUserInfoView showFriend:friend infoInView:self needUpdate:YES];
//            UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:feedUser.userId avatar:feedUser.avatar nickName:feedUser.nickName]] autorelease];
//            [self.navigationController pushViewController:uc animated:YES];
            
            [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:feedUser.userId avatar:feedUser.avatar nickName:feedUser.nickName] inViewController:self];
            
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
        return [feed isMyFeed]|| ([self.feed isMyOpus] && feed.feedType == FeedTypeComment);        
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
//    MyFriend *friend = [MyFriend friendWithFid:userId
//                                      nickName:nickName
//                                        avatar:nil
//                                        gender:@"m"
//                                         level:1];
//    [DrawUserInfoView showFriend:friend infoInView:self needUpdate:YES];
//    UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nickName]] autorelease];
//    [self.navigationController pushViewController:uc animated:YES];
    
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
                                    feedOpusId:_feed.feedId
                                    feedAuthor:_feed.author.userId
                                       forFree:isFree
                                 resultHandler:^(int resultCode, int itemId, BOOL isBuy)
        {
            if (resultCode == ERROR_SUCCESS){
                ShareImageManager *imageManager = [ShareImageManager defaultManager];
                CGRect frame = [bself.footerView buttonWithType:FooterTypeFlower].frame;
                frame = [self.view convertRect:frame fromView:self.footerView];
                UIImageView* throwItem = [[[UIImageView alloc] initWithFrame:frame] autorelease];
                [throwItem setImage:[imageManager flower]];
                PPDebug(@"<test2> complete 1");                
                [DrawGameAnimationManager showThrowFlower:throwItem
                                         animInController:bself
                                                  rolling:YES
                                               itemEnough:!isBuy
                                           shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:bself.useItemScene.sceneType]
                                               completion:^(BOOL finished) {
                [bself clickRefreshButton:nil];
                   PPDebug(@"<test2> complete 10");
                }];
                [bself.commentHeader setSelectedType:CommentTypeFlower];
                [bself.feed incTimesForType:FeedTimesTypeFlower];
                PPDebug(@"<test2> complete 2");
            }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
                [BalanceNotEnoughAlertView showInController:bself];
                [bself.feed decreaseLocalFlowerTimes];
            }else if (resultCode == ERROR_NETWORK){
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:NO];
                [bself.feed decreaseLocalFlowerTimes];
            }
        }];
    }
}


- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView
{
    if ([ConfigManager wallEnabled]) {
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
        progressText = NSLS(@"kParsingData");
    }
    else{
        progressText = [NSString stringWithFormat:NSLS(@"kLoadingProgress"), progress*100];
    }
    [self.progressView setLabelText:progressText];
    
    [self.progressView setProgress:progress];
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
            
            [cp popupUnhappyMessage:NSLS(@"kFailLoad") title:nil];
        }

        [cp hideProgressView];
    }
     downloadDelegate:self];
}

#pragma mark - Click Actions

- (void)performGuess
{
    __block ShowFeedController * cp = self;
    //enter guess controller
    [self loadDrawDataWithHanlder:^{
        [OfflineGuessDrawController startOfflineGuess:cp.feed fromController:cp];
        [cp.commentHeader setSelectedType:CommentTypeGuess];
        [cp hideActivity];        
    }];
}

- (void)performReplay
{
    __block ShowFeedController * cp = self;

    [self loadDrawDataWithHanlder:^{
        ReplayView *replay = [ReplayView createReplayView];
        if (cp.feed.drawData == nil) {
            [cp.feed parseDrawData];
        }
        
        ReplayObject *obj = [ReplayObject obj];
        obj.actionList = cp.feed.drawData.drawActionList;
        obj.isNewVersion = [cp.feed.drawData isNewVersion];
        obj.canvasSize = cp.feed.drawData.canvasSize;
        obj.layers = cp.feed.drawData.layers;
        
        [replay showInController:cp object:obj];

    }];
    
}
- (void)detailFooterView:(DetailFooterView *)footer
        didClickAtButton:(UIButton *)button
                    type:(FooterType)type
{
    PPDebug(@"<NO MORE> = %d", self.noMoreData);
    switch (type) {
        case FooterTypeGuess:
            [self performSelector:@selector(performGuess) withObject:nil afterDelay:0.1f];
            break;
        case FooterTypeReplay:
            [self performSelector:@selector(performReplay) withObject:nil afterDelay:0.1f];
            break;
        case FooterTypeComment:
        {
            CommentController *cc = [[CommentController alloc] initWithFeed:self.feed forContestReport:NO];
            [self presentModalViewController:cc animated:YES];
            [_commentHeader setSelectedType:CommentTypeComment];
            break;

        }
        case FooterTypeShare:
        {
            UIImage* image = [[SDImageCache sharedImageCache] imageFromKey:self.feed.drawImageUrl];
            if (image == nil){
                image = self.feed.largeImage;
            }
            if (_shareAction == nil) {
                _shareAction = [[ShareAction alloc] initWithFeed:_feed
                                                           image:image];
            }
            [_shareAction displayWithViewController:self onView:button];
            break;
        }
        case FooterTypeFlower:
        {
            [self throwItem:ItemTypeFlower];
            [self updateFlowerButton];
            break;
        }
        case FooterTypeReport:
        {
            //TODO report
            break;
        }
         
        case FooterTypeJudge:
        {
            if (self.judgerPopupView == nil) {
                self.judgerPopupView = [PPPopTableView popTableViewWithDelegate:self];
            }
            if(![self.judgerPopupView isShowing]){
                [self.judgerPopupView showInView:self.view atView:button animated:YES];
            }else{
                [self.judgerPopupView dismiss:YES];
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
    [self.feedScene didClickBackBtn:self];
}


#pragma mark - comment cell delegate
- (void)didStartToReplyToFeed:(CommentFeed *)feed
{
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

- (void)viewDidLoad
{
    
    [self setPullRefreshType:PullRefreshTypeFooter];
    [super viewDidLoad];
    
    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setRightButtonAsRefresh];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    
    [self initFooterView];    
    [self initTabButtons];
    [self addSwipe];
    [self reloadView];
}


- (void)viewDidUnload
{
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

- (void)didClickDrawImageMaskView
{
    int indexOfGuess = 0;
    int indexOfPlay = 1;
    int indexOfPhoto = 2;
    int indexOfFeature = -1;
    int indexOfUnfeature = -1;
    
    MKBlockActionSheet *sheet = nil;
    BOOL canFeature = [[UserManager defaultManager] canFeatureDrawOpus];
    
    if (![self.feed showAnswer]) {
        if (canFeature){
            sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                     delegate:nil
                                            cancelButtonTitle:NSLS(@"kCancel")
                                       destructiveButtonTitle:NSLS(@"kGuess")
                                            otherButtonTitles:NSLS(@"kPlay"), NSLS(@"kLargeImage"), NSLS(@"kRecommend"), NSLS(@"kUnfeature"), nil];
            indexOfFeature = indexOfPhoto + 1;
            indexOfUnfeature = indexOfFeature + 1;
        }
        else{
            sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                     delegate:nil
                                            cancelButtonTitle:NSLS(@"kCancel")
                                       destructiveButtonTitle:NSLS(@"kGuess")
                                            otherButtonTitles:NSLS(@"kPlay"), NSLS(@"kLargeImage"), nil];
        }
    }else{
        indexOfGuess = -1;
        indexOfPlay = 0;
        indexOfPhoto = 1;

        if (canFeature){
            sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                     delegate:nil
                                            cancelButtonTitle:NSLS(@"kCancel")
                                       destructiveButtonTitle:NSLS(@"kPlay") otherButtonTitles:NSLS(@"kLargeImage"), NSLS(@"kRecommend"), NSLS(@"kUnfeature"), nil];
        
            indexOfFeature = indexOfPhoto + 1;
            indexOfUnfeature = indexOfFeature + 1;
        }
        else{
            sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOption")
                                                     delegate:nil
                                            cancelButtonTitle:NSLS(@"kCancel")
                                       destructiveButtonTitle:NSLS(@"kPlay") otherButtonTitles:NSLS(@"kLargeImage"), nil];
        }
    }
    
    [sheet setActionBlock:^(NSInteger buttonIndex){
        if (buttonIndex == indexOfGuess) {
            [self performSelector:@selector(performGuess) withObject:nil afterDelay:0.1f];
        }else if (buttonIndex == indexOfPhoto){
            [self showPhotoBrower];
        }else if (buttonIndex == indexOfPlay){
            [self performSelector:@selector(performReplay) withObject:nil afterDelay:0.1f];
        }else if (buttonIndex == indexOfFeature){
            [[FeedService defaultService] recommendOpus:self.feed.feedId resultBlock:^(int resultCode) {
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
        else{
            
        }
        
        [sheet setActionBlock:NULL];
    }];
    [sheet showInView:self.view];

}

- (void)showPhotoBrower{
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.canSave = YES;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [browser release];
    [nc release];
}


- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [MWPhoto photoWithURL:self.feed.largeImageURL];
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
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    PPDebug(@"<ShowFeedController> load data with tab ID = %d", tabID);
    
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FeedService defaultService] getOpusCommentList:_feed.feedId
                                                type:tab.tabID
                                              offset:tab.offset
                                               limit:tab.limit
                                            delegate:self];
}

#pragma mark - draw data service delegate
- (void)didMatchDraw:(DrawFeed *)feed result:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0 && feed) {
        [HomeController startOfflineGuessDraw:feed from:self];
    }else{
        CommonMessageCenter *center = [CommonMessageCenter defaultCenter];
        [center postMessageWithText:NSLS(@"kMathOpusFail") delayTime:1.5 isHappy:NO];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    for (ReplayView *rv in [self.view subviews]) {
        if ([rv isKindOfClass:[ReplayView class]]) {
            return NO;
        }
    }
    return YES;
}


- (NSInteger)numberOfRowsInPopTableView:(PPPopTableView *)tableView
{
    return 2;
}
- (UIImage *)popTableView:(PPPopTableView *)tableView iconForRow:(NSInteger)row
{
    if (row == 0) {
        return [UIImage imageNamed:@"detail_comment@2x.png"];
    }
    return [UIImage imageNamed:@"detail_replay@2x.png"];    
}
- (NSString *)popTableView:(PPPopTableView *)tableView titleForRow:(NSInteger)row
{
    return @[@"kJudgerComment",NSLS(@"kJudgerScore")][row];
}

- (void)popTableView:(PPPopTableView *)tableView didSelectedAtRow:(NSInteger)row
{
    PPDebug(@"<popTableView:didSelectedAtRow:> %d", row);

    if (row == 0) {
    //TODO for judger comment
        
    }else if(row == 1){
    //TODO for judger score
    }
    [tableView dismiss:YES];
}

@end
