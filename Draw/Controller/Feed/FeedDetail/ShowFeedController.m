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
//#import "DrawUserInfoView.h"
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

@interface ShowFeedController () {
    BOOL _didLoadDrawPicture;
    UIImageView* _throwingItem;
    ShareAction *_shareAction;
}
@property (retain, nonatomic) IBOutlet UIButton *guessButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *commentButton;
@property (retain, nonatomic) IBOutlet UIButton *flowerButton;
@property (retain, nonatomic) IBOutlet UIButton *replayButton;


@property(nonatomic, retain) UserInfoCell *userCell;
@property(nonatomic, retain) DrawInfoCell *drawCell;
@property(nonatomic, retain) CommentHeaderView *commentHeader;
@property(nonatomic, retain) DrawFeed *feed;
@property (nonatomic, retain) UseItemScene* useItemScene;

- (IBAction)clickActionButton:(id)sender;


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
    
    
    PPRelease(_feed);
    PPRelease(_drawCell);
    PPRelease(_userCell);
    PPRelease(_tabManager);
    PPRelease(_commentHeader);
    PPRelease(_guessButton);
    PPRelease(_saveButton);
    PPRelease(_commentButton);
    PPRelease(_flowerButton);
    PPRelease(_replayButton);
    PPRelease(_useItemScene);
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
    self = [super init];
    if(self)
    {
        self.feed = feed;
        self.useItemScene = scene;
    }
    return self;
}

enum{
  ActionTagGuess = 100,
  ActionTagComment, 
  ActionTagSave,
  ActionTagFlower,
  ActionTagTomato,
  ActionTagRplay,
  ActionTagEnd,
};

#define SCREEN_WIDTH ([DeviceDetection isIPAD] ? 768 : 320)
#define ACTION_BUTTON_Y ([DeviceDetection isIPAD] ? 921 : 422)


- (void)updateActionButtons
{
    self.guessButton.hidden = [self.feed showAnswer] || [self.feed isContestFeed];
    self.replayButton.hidden = !self.guessButton.hidden;

    for (NSInteger tag = ActionTagGuess; tag < ActionTagEnd; ++ tag) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];            
        button.enabled = YES;
    }
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
    [self.drawCell setCellInfo:self.feed];
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
            self.noMoreData = ![[_tabManager currentTab] hasMoreData];
            if ([self.dataList count] < SPACE_CELL_COUNT) {
                return SPACE_CELL_COUNT;
            }
            return [self.dataList count];
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
            UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:feedUser.userId avatar:feedUser.avatar nickName:feedUser.nickName]] autorelease];
            [self.navigationController pushViewController:uc animated:YES];
            
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
        DrawFeed *feed = [self.dataList objectAtIndex:indexPath.row];
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
    }else if ([self.feed showAnswer] && [self.feed.wordText length] != 0) {
        title = [NSString stringWithFormat:NSLS(@"[%@]"),
                 self.feed.wordText];        
    }else{
        title = [NSString stringWithFormat:NSLS(@"kFeedDetail")];
    }
    [self.titleLabel setText:title];
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
    UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nickName]] autorelease];
    [self.navigationController pushViewController:uc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self clickRefreshButton:nil];
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
    if ([self.feed isMyOpus]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCanotSendToSelf") delayTime:1.5 isHappy:YES];
        return;
    }
    if ((itemId == ItemTypeTomato && ![_useItemScene canThrowTomato]) || (itemId == ItemTypeFlower && ![_useItemScene canThrowFlower])) {
        UseItemScene * sence = self.useItemScene;
        
        [[CommonMessageCenter defaultCenter] postMessageWithText:[sence unavailableItemMessage] delayTime:1.5 isHappy:YES];
        return;
    }

//    BOOL isFree = [_useItemScene isItemFree:itemId];
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
                UIImageView* throwItem = [[[UIImageView alloc] initWithFrame:bself.flowerButton.frame] autorelease];
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
                [bself.commentHeader setSeletType:CommentTypeFlower];
                [bself.feed incTimesForType:FeedTimesTypeFlower];
                PPDebug(@"<test2> complete 2");
            }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
                [BalanceNotEnoughAlertView showInController:bself];
            }else if (resultCode == ERROR_NETWORK){
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:NO];
            }
        }];
    }
}


- (void)clickOk:(CommonDialog *)dialog
{
    if ([ConfigManager wallEnabled]) {
        [LmWallService showWallOnController:self];
    }else {
        ChargeController* controller = [[[ChargeController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    
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

    if(handler == NULL)return;

//    [self showActivityWithText:NSLS(@"kLoading")];
    
    [self showProgressViewWithMessage:NSLS(@"kLoading")];
    
    if (self.feed.pbDrawData){
        
        [self hideProgressView];
//        [self hideActivity];
        handler();
        return;
    }
    
    __block ShowFeedController * cp = self;
    [[FeedService defaultService] getPBDrawByFeed:self.feed
                                          handler:
     ^(int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache)
    {
//        [cp hideActivity];
        if(resultCode == 0 && pbDrawData != nil){
            cp.feed.pbDrawData = pbDrawData;
            handler();
        }else{
            [cp popupUnhappyMessage:NSLS(@"kFailLoad") title:nil];
        }

        [self hideProgressView];
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
        [_commentHeader setSeletType:CommentTypeGuess];
        [cp hideActivity];        
    }];
}

- (void)performReplay
{
    __block ShowFeedController * cp = self;

    [self loadDrawDataWithHanlder:^{
        ReplayView *replay = [ReplayView createReplayView];
        [self.feed parseDrawData];
        [replay showInController:cp
                  withActionList:cp.feed.drawData.drawActionList
                    isNewVersion:[cp.feed.drawData isNewVersion]
                            size:cp.feed.drawData.canvasSize];
        self.feed.drawData = nil;
    }];
    
}

- (IBAction)clickActionButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == self.guessButton) {
        [self performSelector:@selector(performGuess) withObject:nil afterDelay:0.1f];
    }else if(button == self.commentButton){
        //enter comment controller
        CommentController *cc = [[CommentController alloc] initWithFeed:self.feed];
        [self presentModalViewController:cc animated:YES];
        [cc release];
        [_commentHeader setSeletType:CommentTypeComment];       
    }else if(button == self.saveButton){

        UIImage* image = [[SDImageCache sharedImageCache] imageFromKey:self.feed.drawImageUrl];
        if (image == nil){
            image = self.feed.largeImage;
        }
        if (_shareAction == nil) {
            _shareAction = [[ShareAction alloc] initWithFeed:_feed
                                                       image:image];
        }
        [_shareAction displayWithViewController:self onView:self.saveButton];
        
    }else if(button == self.flowerButton){
        [self throwItem:ItemTypeFlower];
    }else if(button == self.replayButton){
        [self performSelector:@selector(performReplay) withObject:nil afterDelay:0.1f];
    }else{
        //NO action
    }
    
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
    UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:myFriend.friendUserId avatar:myFriend.avatar nickName:myFriend.nickName]] autorelease];
    [self.navigationController pushViewController:uc animated:YES];
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
    [self.commentHeader setSeletType:CommentTypeComment];
}

- (void)viewDidLoad
{
    
    [self setPullRefreshType:PullRefreshTypeFooter];
    [super viewDidLoad];
    [self initTabButtons];
    [self updateActionButtons];
    [self updateTitle];
    [[FeedService defaultService] getFeedByFeedId:_feed.feedId
                                         delegate:self];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setGuessButton:nil];
    [self setSaveButton:nil];
    [self setCommentButton:nil];
    [self setFlowerButton:nil];
    [self setReplayButton:nil];

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
    if (resultCode == 0) {
        feed.largeImage = self.feed.largeImage;
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
    if ([self.feed showAnswer]) {
        [self clickActionButton:self.replayButton];
    }else{
        [self clickActionButton:self.guessButton];
    }
}


#pragma mark-- Common Tab Controller Delegate

- (NSInteger)tabCount
{
    if ([_feed isContestFeed]) {
        return 2;
    }
    return 3;
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
{
    if ([_feed isContestFeed]) {
        NSInteger *tabIDs [] = {CommentTypeComment, CommentTypeFlower};
        return tabIDs[index];
    }else{
        NSInteger *tabIDs [] = {CommentTypeComment, CommentTypeGuess, CommentTypeFlower};
        return tabIDs[index];
    }
    
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return nil;
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FeedService defaultService] getOpusCommentList:_feed.feedId
                                                type:tab.tabID
                                              offset:tab.offset
                                               limit:tab.limit
                                            delegate:self];
}


@end
