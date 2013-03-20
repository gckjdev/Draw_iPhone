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
#import "DrawUserInfoView.h"
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
#import "CoinShopController.h"

#import "LmWallService.h"
#import "UserGameItemService.h"
#import "GameItemService.h"
#import "FlowerItem.h"
#import "UserGameItemManager.h"

@interface ShowFeedController () {
    ShareAction* _shareAction;
}

@end

@implementation ShowFeedController
@synthesize titleLabel = _titleLabel;
@synthesize guessButton = _guessButton;
@synthesize saveButton = _saveButton;
@synthesize commentButton = _commentButton;
@synthesize flowerButton = _flowerButton;
@synthesize tomatoButton = _tomatoButton;
@synthesize replayButton = _replayButton;
@synthesize feed = _feed;
@synthesize userCell = _userCell;
@synthesize drawCell = _drawCell;
@synthesize commentHeader = _commentHeader;
@synthesize useItemScene = _useItemScene;

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
    _feed.pbDraw = nil;
    PPRelease(_feed);
    PPRelease(_drawCell);
    PPRelease(_userCell);
    PPRelease(_tabManager);
    PPRelease(_commentHeader);
    PPRelease(_titleLabel);
    PPRelease(_guessButton);
    PPRelease(_saveButton);
    PPRelease(_commentButton);
    PPRelease(_flowerButton);
    PPRelease(_tomatoButton);
    PPRelease(_replayButton);
    PPRelease(_useItemScene);
    PPRelease(_shareAction);
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
    //data is nil
//    NSInteger start = ActionTagGuess;
//    NSInteger count = ActionTagEnd - start;
//    
    self.guessButton.hidden = [self.feed showAnswer] || [self.feed isContestFeed];
    self.replayButton.hidden = !self.guessButton.hidden;
    
//    if ([self.feed showAnswer]) {
//
//        start = ActionTagComment;
//        self.guessButton.hidden = YES;
//        self.replayButton.hidden = NO;
//        count --;
//    }else{
//        self.replayButton.hidden = YES;
//        self.guessButton.hidden = NO;
//    }
    
//    CGFloat width = self.guessButton.frame.size.width;
//    CGFloat space = (SCREEN_WIDTH - (count * width)) / (count + 1);
//    CGFloat x = space;
//    CGFloat y = ACTION_BUTTON_Y;
//    
//    for (NSInteger tag = start; tag < ActionTagEnd; ++ tag) {
//        UIButton *button = (UIButton *)[self.view viewWithTag:tag];
//        button.frame = CGRectMake(x, y, width, width);
//        button.enabled = YES;
//        x += width + space;
//    }
    for (NSInteger tag = ActionTagGuess; tag < ActionTagEnd; ++ tag) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];            
        button.enabled = ([self.feed hasDrawActions] && _didLoadDrawPicture);
    }
//    self.saveButton.enabled = !_didSave && [self.feed hasDrawActions] && _didLoadDrawPicture;
//    if (![self.feed canSave]) {
//        self.saveButton.enabled = NO;
//    }
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
            MyFriend *friend = [MyFriend friendWithFid:feedUser.userId
                                              nickName:feedUser.nickName
                                                avatar:feedUser.avatar
                                                gender:feedUser.genderString
                                                 level:1];
            [DrawUserInfoView showFriend:friend infoInView:self needUpdate:YES];

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
    //update the times
//    [self.commentHeader setViewInfo:self.feed];
    //update the action buttons
    [self updateActionButtons];
    [self updateTitle];
    
    [self.dataTableView reloadData];
    
//    [self updateUserInfo];
    
//    NSIndexSet *set = [NSIndexSet indexSetWithIndex:SectionDrawInfo];
//    [self.dataTableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didClickDrawToUser:(NSString *)userId nickName:(NSString *)nickName
{
    MyFriend *friend = [MyFriend friendWithFid:userId
                                      nickName:nickName
                                        avatar:nil
                                        gender:@"m"
                                         level:1];
    [DrawUserInfoView showFriend:friend infoInView:self needUpdate:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self didUpdateShowView];
    [self clickRefresh:nil];
    [self updateTitle];    
    [self updateActionButtons];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    PPDebug(@"<ShowFeedController> retain count = %d",[self retainCount]);
}

#pragma mark - feed service delegate

- (void)didGetFeedCommentList:(NSArray *)feedList 
                       opusId:(NSString *)opusId
                         type:(int)type
                   resultCode:(NSInteger)resultCode
                       offset:(int)offset
{
//    [self hideActivity];
//    [self dataSourceDidFinishLoadingMoreData];
    [self dataSourceDidFinishLoadingMoreData];
    
    TableTab *tab = [_tabManager tabForID:type];
    if (resultCode == 0) {
        
        PPDebug(@"<didGetFeedCommentList>get feed(%@)  succ!", opusId);
        [tab setStatus:TableTabStatusLoaded];
        NSInteger count = [feedList count];
        if (count == 0) {
            tab.hasMoreData = NO;
            self.noMoreData = YES;
        }else{
            self.noMoreData = NO;
            tab.hasMoreData = YES;
            if (offset == 0) {
                [_tabManager setDataList:feedList ForTabID:type];
            }else{
                [_tabManager addDataList:feedList toTab:type];
            }
            tab.offset += count;
        }
        [self reloadCommentSection];
    }else{
        if (tab.offset == 0) {
            [tab setStatus:TableTabStatusUnload];
            [tab setHasMoreData:NO];
        }
        PPDebug(@"<didGetFeedCommentList>get feed(%@)  fail!", opusId);
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
        [[CommonMessageCenter defaultCenter] postMessageWithText:[self.useItemScene unavailableItemMessage] delayTime:1.5 isHappy:YES];
        return;
    }

    BOOL isFree = [_useItemScene isItemFree:itemId];
    BOOL itemEnough = YES;
    
    
    [self showItemAnimation:itemId isFree:isFree itemEnough:itemEnough];
}


- (void)showItemAnimation:(int)itemId
                   isFree:(BOOL)isFree
               itemEnough:(BOOL)itemEnough
{
    if (itemId == ItemTypeFlower) {
        
        __block typeof (self) bself = self;

        [[FlowerItem sharedFlowerItem] useItem:_feed.author.userId
                               isOffline:YES
                              feedOpusId:_feed.feedId
                              feedAuthor:_feed.author.userId
                                 forFree:isFree
                           resultHandler:^(int resultCode, int itemId, BOOL isBuy)
        {
            if (resultCode == 0){
                ShareImageManager *imageManager = [ShareImageManager defaultManager];
                UIImageView* throwItem = [[[UIImageView alloc] initWithFrame:bself.flowerButton.frame] autorelease];
                [throwItem setImage:[imageManager flower]];
                PPDebug(@"<test2> complete 1");                
                [DrawGameAnimationManager showThrowFlower:throwItem
                                         animInController:bself
                                                  rolling:YES
                                               itemEnough:itemEnough
                                           shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:bself.useItemScene.sceneType] completion:^(BOOL finished) {
                    [bself clickRefresh:nil];
                   PPDebug(@"<test2> complete 10");
                }];
                [bself.commentHeader setSeletType:CommentTypeFlower];
                [bself.feed increaseLocalFlowerTimes];
                PPDebug(@"<test2> complete 2");
            }
        }];
        
    }else{
        
        
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        UIImageView* throwItem = [[[UIImageView alloc] initWithFrame:self.tomatoButton.frame] autorelease];
        [throwItem setImage:[imageManager tomato]];
        [DrawGameAnimationManager showThrowTomato:throwItem animInController:self rolling:YES itemEnough:itemEnough shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:self.useItemScene.sceneType] completion:^(BOOL finished) {
            [self clickRefresh:nil];
        }];
        [_commentHeader setSeletType:CommentTypeTomato];
        [self.feed increaseLocalTomatoTimes];
    }
}


- (void)clickOk:(CommonDialog *)dialog
{
    if ([ConfigManager wallEnabled]) {
        [LmWallService showWallOnController:self];
    }else {
        CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}

#pragma mark - Click Actions
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)performGuess
{
    //enter guess controller
    [OfflineGuessDrawController startOfflineGuess:self.feed fromController:self];
    [_commentHeader setSeletType:CommentTypeGuess];
    [self hideActivity];
}

- (void)performReplay
{
    [self hideActivity];
    ReplayView *replay = [ReplayView createReplayView];
    [self.feed parseDrawData];
    [replay showInController:self withActionList:self.feed.drawData.drawActionList
                isNewVersion:[self.feed.drawData isNewVersion]
                      drawBg:self.feed.pbDraw.drawBg
                        size:CGSizeFromPBSize(self.feed.pbDraw.canvasSize)];
}

- (IBAction)clickActionButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == self.guessButton) {
        [self showActivityWithText:NSLS(@"kLoading")];
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
    }else if(button == self.tomatoButton){
        [self throwItem:ItemTypeTomato];
    }else if(button == self.replayButton){
        [self showActivityWithText:NSLS(@"kLoading")];
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
    [DrawUserInfoView showFriend:myFriend infoInView:self needUpdate:YES];
}

#pragma mark draw data service delegate
- (void)didSaveOpus:(BOOL)succ
{
    [self hideActivity];
    self.saveButton.userInteractionEnabled = YES;
    if (succ) {
        self.saveButton.enabled = NO;
        _didSave = YES;
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveOpusOK") delayTime:1.5 isHappy:YES];
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveImageFail") delayTime:1.5 isHappy:NO];
    }
}

#pragma mark comment header delegate

- (void)updateCommentListForTab:(TableTab *)tab
{
    [[FeedService defaultService] getOpusCommentList:_feed.feedId 
                                                type:tab.tabID 
                                              offset:tab.offset 
                                               limit:tab.limit 
                                            delegate:self];     
    tab.status = TableTabStatusLoading;
}

- (void)didSelectCommentType:(int)type
{
    TableTab *tab = [_tabManager tabForID:type];
    if (tab.isCurrentTab) {
        return;
    }
    [_tabManager setCurrentTab:tab];
    if (tab.status == TableTabStatusUnload) {
        [self updateCommentListForTab:tab];
    }
    [self reloadCommentSection];
}

- (void)loadMoreTableViewDataSource
{
    TableTab *tab = [_tabManager currentTab];
    [self updateCommentListForTab:tab];
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

- (void)initTabs
{
    NSArray *tabIDs = [NSArray arrayWithObjects:
                       [NSNumber numberWithInteger:CommentTypeComment],
                       [NSNumber numberWithInteger:CommentTypeGuess],
                       [NSNumber numberWithInteger:CommentTypeFlower],
                       [NSNumber numberWithInteger:CommentTypeTomato], nil];
    
    NSArray *tabNoDataDescList = [NSArray arrayWithObjects:NSLS(@"kNoComments"),
                                  NSLS(@"kNoGuesses"),
                                  NSLS(@"kNoFlowers"),
                                  NSLS(@"kNoTomatos"), nil];
    if (_tabManager != nil) {
        PPRelease(_tabManager);
    }
    _tabManager = [[TableTabManager alloc] initWithTabIDList:tabIDs
                                                   titleList:nil
                                              noDataDescList:tabNoDataDescList 
                                                       limit:12 
                                             currentTabIndex:-1];
    
    self.commentHeader = [CommentHeaderView createCommentHeaderView:self];
    [self.commentHeader setViewInfo:self.feed];

    [_commentHeader setSeletType:CommentTypeComment];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [self setSupportRefreshFooter:YES];
    [super viewDidLoad];
    [self updateActionButtons];
    [self updateTitle];
    [self initTabs];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setGuessButton:nil];
    [self setSaveButton:nil];
    [self setCommentButton:nil];
    [self setFlowerButton:nil];
    [self setTomatoButton:nil];
    [self setReplayButton:nil];

    [self.feed setDrawData:nil];
    [self setDrawCell:nil];
    [self setUserCell:nil];
    [self setCommentHeader:nil];
    PPRelease(_tabManager);
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction)clickRefresh:(id)sender {
    if (self.feed.drawData == nil) {
        [_drawCell setCellInfo:_feed];
    }
    
    //update times
    [[FeedService defaultService] updateFeedTimes:self.feed delegate:self];
    
    TableTab *tab = [_tabManager currentTab];
    tab.offset = 0;
    [self updateCommentListForTab:tab];
}
- (void)didUpdateFeedTimes:(DrawFeed *)feed 
                resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
//        [_commentHeader updateTimes:feed];
        [_commentHeader setViewInfo:feed];
    }
}

#pragma mark - UIActionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
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

@end
