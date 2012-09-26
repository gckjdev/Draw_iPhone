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
#import "CommonUserInfoView.h"
#import "OfflineGuessDrawController.h"
#import "CommentController.h"
#import "ShareService.h"
#import "Draw.h"
#import "StableView.h"
#import "ItemManager.h"
#import "ItemService.h"
#import "ShareImageManager.h"
#import "CommonMessageCenter.h"

@implementation ShowFeedController
@synthesize titleLabel = _titleLabel;
@synthesize guessButton = _guessButton;
@synthesize saveButton = _saveButton;
@synthesize commentButton = _commentButton;
@synthesize flowerButton = _flowerButton;
@synthesize tomatoButton = _tomatoButton;
@synthesize feed = _feed;
@synthesize userCell = _userCell;
@synthesize drawCell = _drawCell;
@synthesize commentHeader = _commentHeader;

typedef enum{
    
    SectionUserInfo = 0,
    SectionDrawInfo,
    SectionCommentInfo,
    SectionNumber
    
}Section;

- (void)dealloc
{
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

enum{
  ActionTagGuess = 100,
  ActionTagComment, 
  ActionTagSave,
  ActionTagFlower,
  ActionTagTomato,
  ActionTagEnd,
};

#define SCREEN_WIDTH ([DeviceDetection isIPAD] ? 768 : 320)
#define ACTION_BUTTON_Y ([DeviceDetection isIPAD] ? 921 : 422)
- (void)updateActionButtons
{
    //data is nil
    NSInteger start = ActionTagGuess;
    NSInteger count = ActionTagEnd - start;
    
    if ([self.feed showAnswer]) {
    //mine or correct
        start = ActionTagComment;
        self.guessButton.hidden = YES;
        count --;
    }else{
        self.guessButton.hidden = NO;
    }
    
    CGFloat width = self.guessButton.frame.size.width;
    CGFloat space = (SCREEN_WIDTH - (count * width)) / (count + 1);
    CGFloat x = space;
    CGFloat y = ACTION_BUTTON_Y;
    
    for (NSInteger tag = start; tag < ActionTagEnd; ++ tag) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];
        button.frame = CGRectMake(x, y, width, width);
        button.enabled = YES;
        x += width + space;
    }
    self.saveButton.enabled = !_didSave;
    
    if (self.feed.drawData == nil) {
        for (NSInteger tag = ActionTagGuess; tag < ActionTagEnd; ++ tag) {
            UIButton *button = (UIButton *)[self.view viewWithTag:tag];            
            button.enabled = NO;
        }
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
        [self.userCell setCellInfo:self.feed];
        self.userCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self.userCell;
}
- (UITableViewCell *)cellForDrawInfoSection
{
    if (self.drawCell == nil) {
        self.drawCell = [DrawInfoCell createCell:self];
        [self.drawCell setCellInfo:self.feed];
    }
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
        case SectionDrawInfo:
            return [DrawInfoCell getCellHeight];
        case SectionCommentInfo:
        {
            if (indexPath.row == 0) {
                PPDebug(@"row = %d", indexPath.row);
            }
            if (indexPath.row >= [self.dataList count]) {
                return SPACE_CELL_FONT_HEIGHT;
            }
            CommentFeed *feed = [self.dataList objectAtIndex:indexPath.row];
            CGFloat height = [CommentCell getCellHeight:feed];
            PPDebug(@"row = %d, height = %f", indexPath.row ,height);
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
            [CommonUserInfoView showUser:self.feed.author.userId 
                                nickName:nil 
                                  avatar:nil 
                                  gender:nil 
                                location:nil 
                                   level:1
                                 hasSina:NO 
                                   hasQQ:NO 
                             hasFacebook:NO 
                              infoInView:self];

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
    if (indexPath.row < [self.dataList count]) {
        DrawFeed *feed = [self.dataList objectAtIndex:indexPath.row];
        return [feed isMyFeed]|| [self.feed isMyOpus];        
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
    if ([self.feed showAnswer]) {
        title = [NSString stringWithFormat:NSLS(@"[%@]"),
                 self.feed.wordText];        
    }else{
        title = [NSString stringWithFormat:NSLS(@"kFeedDetail")];
    }
    [self.titleLabel setText:title];
}


#pragma mark - cell delegate
- (void)didUpdateShowView
{
    //update the times
    [self.commentHeader setViewInfo:self.feed];
    
    //update the action buttons
    [self updateActionButtons];
    [self updateTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self didUpdateShowView];
    [self clickRefresh:nil];
    [self updateTitle];    
    [self updateActionButtons];
}



#pragma mark - feed service delegate

- (void)didGetFeedCommentList:(NSArray *)feedList 
                       opusId:(NSString *)opusId 
                         type:(int)type
                   resultCode:(NSInteger)resultCode
{
//    [self hideActivity];
    [self dataSourceDidFinishLoadingMoreData];
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
            if (tab.offset == 0) {
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

- (void)throwItem:(Item *)item
{
    
    if ([self.feed isMyOpus]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCanotSendToSelf") delayTime:1.5 isHappy:YES];
        return;
    }
    
    if (item.amount <= 0) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNoItemTitle") message:NSLS(@"kNoItemMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = ITEM_TAG_OFFSET + item.type;
        [dialog showInView:self.view];

    }else{
        //throw animation
        [[ItemService defaultService] sendItemAward:item.type
                                       targetUserId:_feed.author.userId
                                          isOffline:YES
                                         feedOpusId:_feed.feedId
                                         feedAuthor:_feed.author.userId];
        
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        if (item.type == ItemTypeFlower) {
            UIImageView* itemView = [[[UIImageView alloc] initWithFrame:self.flowerButton.frame] autorelease];
            [itemView setImage:[imageManager flower]];
            [self.view addSubview:itemView];
            [DrawGameAnimationManager showThrowFlower:itemView animInController:self rolling:YES];
            [_commentHeader setSeletType:CommentTypeFlower];
        }else{
            UIImageView* itemView = [[[UIImageView alloc] initWithFrame:self.tomatoButton.frame] autorelease];
            [itemView setImage:[imageManager tomato]];
            [self.view addSubview:itemView];
            [DrawGameAnimationManager showThrowTomato:itemView animInController:self rolling:YES];         
            [_commentHeader setSeletType:CommentTypeTomato];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [DrawGameAnimationManager animation:anim didStopWithFlag:flag];
    [self clickRefresh:nil];
}


- (void)clickOk:(CommonDialog *)dialog
{
    switch (dialog.tag) {
        case (ItemTypeTomato + ITEM_TAG_OFFSET): {
            [CommonItemInfoView showItem:[Item tomato] infoInView:self];
        } break;
        case (ItemTypeFlower + ITEM_TAG_OFFSET): {
            [CommonItemInfoView showItem:[Item flower] infoInView:self];
        } break;
        default:
            break;
    }    
}

#pragma mark - Click Actions
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickActionButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == self.guessButton) {
        //enter guess controller
        [OfflineGuessDrawController startOfflineGuess:self.feed fromController:self];        
            [_commentHeader setSeletType:CommentTypeGuess];
    }else if(button == self.commentButton){
        //enter comment controller
        CommentController *cc = [[CommentController alloc] initWithFeed:self.feed];
        [self presentModalViewController:cc animated:YES];
        [cc release];
        [_commentHeader setSeletType:CommentTypeComment];       
    }else if(button == self.saveButton){
        //save
        UIImage *image = self.feed.largeImage;
        if(image == nil){
           image =  [self.drawCell.showView createImage];   
        }
        
        [self showActivityWithText:NSLS(@"kSaving")];
        
        [[ShareService defaultService] shareWithImage:image 
                                           drawUserId:_feed.feedUser.userId
                                           isDrawByMe:[_feed isMyOpus] 
                                             drawWord:_feed.wordText];    
        
        [[DrawDataService defaultService] saveActionList:_feed.drawData.drawActionList 
                                                  userId:_feed.feedUser.userId
                                                nickName:_feed.feedUser.nickName
                                               isMyPaint:[_feed isMyOpus] 
                                                    word:_feed.wordText
                                                   image:image
                                                delegate:self];
        button.userInteractionEnabled = NO;
        
    }else if(button == self.flowerButton){
        Item *item = [Item flower];
        [self throwItem:item];
        //send a flower
    }else if(button == self.tomatoButton){
        //send a tomato
        Item *item = [Item tomato];
        [self throwItem:item];
    }else{
        //no action
    }
    
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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



@end
