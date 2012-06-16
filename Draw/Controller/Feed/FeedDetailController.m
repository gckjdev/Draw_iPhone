//
//  FeedDetailController.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedDetailController.h"
#import "PPDebug.h"
#import "LocaleUtils.h"
#import "FeedManager.h"
#import "TimeUtils.h"
#import "StableView.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "Draw.h"
#import "ShareImageManager.h"
#import "CommentCell.h"
#import "OfflineGuessDrawController.h"
//#import "OfflineGuessDrawController.h


@implementation FeedDetailController
@synthesize commentInput;
@synthesize inputViewBg;
@synthesize nickNameLabel;
@synthesize titleLabel;
@synthesize actionButton;
@synthesize sendButton;
@synthesize guessStatLabel;
@synthesize noCommentTipsLabel;
@synthesize timeLabel;
@synthesize feed = _feed;
@synthesize drawView = _drawView;
@synthesize avatarView = _avatarView;


#define AVATAR_VIEW_FRAME CGRectMake(18, 65, 62, 65)
#define SHOW_DRAW_VIEW_FRAME CGRectMake(200, 65, 95, 100)


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithFeed:(Feed *)feed
{
    self = [super init];
    if (self) {
        self.feed = feed;
        _feedService = [FeedService defaultService];
        _startIndex = 0;
    }
    return self;
}


- (void)updateTime:(Feed *)feed
{
    NSString *timeString = dateToString(feed.createDate);
    [self.timeLabel setText:timeString];
}


- (void)updateUser:(Feed *)feed
{
    //avatar
//    [self.avatarView removeFromSuperview];
    self.avatarView = [[[AvatarView alloc] initWithUrlString:_avatar frame:AVATAR_VIEW_FRAME gender:feed.gender level:0] autorelease];
    [self.view addSubview:self.avatarView];
    
    //name
    [self.nickNameLabel setText:[FeedManager opusCreatorForFeed:feed]];
}

- (void)updateGuessDesc:(Feed *)feed
{
    if (feed.matchTimes == 0) {
        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
    }else{
        NSInteger guessTimes = feed.matchTimes;
        NSInteger correctTimes = feed.correctTimes;
        NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessStat"),guessTimes, correctTimes];
        [self.guessStatLabel setText:desc];        
    }
}




- (void)updateActionButton:(Feed *)feed
{
    ShareImageManager* imageManager = [ShareImageManager defaultManager];
    self.actionButton.hidden = NO;
    [self.actionButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    self.actionButton.userInteractionEnabled = YES;
    self.actionButton.selected = NO;
    
    
    ActionType type = [FeedManager actionTypeForFeed:feed];
    if (type == ActionTypeGuess) {
        [self.actionButton setTitle:NSLS(@"kIGuessAction") forState:UIControlStateNormal];
    }else if(type == ActionTypeOneMore)
    {
        [self.actionButton setTitle:NSLS(@"kOneMoreAction") forState:UIControlStateNormal];        
    }else if(type == ActionTypeCorrect){
        [self.actionButton setTitle:NSLS(@"kIGuessCorrect") forState:UIControlStateSelected];
        [self.actionButton setBackgroundImage:[imageManager normalButtonImage] forState:UIControlStateNormal];
        self.actionButton.userInteractionEnabled = NO;
        self.actionButton.selected = YES;
    }else{
        self.actionButton.hidden = YES;
    }

}


- (void)updateDrawView:(Feed *)feed
{
    self.drawView = [[[ShowDrawView alloc] initWithFrame:SHOW_DRAW_VIEW_FRAME] autorelease];
    [self.drawView setShowPenHidden:YES];
    [self.drawView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_drawView];
    [self.drawView cleanAllActions];
    CGRect normalFrame = DRAW_VEIW_FRAME;
    CGRect currentFrame = SHOW_DRAW_VIEW_FRAME;
    CGFloat xScale = currentFrame.size.width / normalFrame.size.width;
    CGFloat yScale = currentFrame.size.height / normalFrame.size.height;
    
    self.drawView.drawActionList = [DrawAction scaleActionList:feed.drawData.drawActionList xScale:xScale yScale:yScale];
    [self.drawView play];
}

#define INPUT_BG_TAG 2012061501
- (void)updateInputView:(Feed *)feed
{
    self.inputViewBg.image = [[ShareImageManager defaultManager] inputImage];
}

- (void)updateCommentTableView:(Feed *)feed
{
    //load data.
}

- (void)updateSendButton:(Feed *)feed
{
    //load data.
    [self.sendButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage]forState:UIControlStateNormal];
    [self.sendButton setTitle:NSLS(@"kComment") forState:UIControlStateNormal];

}



- (void)updateInfo:(Feed *)feed
{
    if (feed.feedType == FeedTypeDraw) {
        _opusId = feed.feedId;
        _userNickName = feed.nickName;
        _avatar = feed.avatar;
        _author = feed.userId;
    }else if(feed.feedType == FeedTypeGuess)
    {
        _opusId = feed.opusId;
        _userNickName = feed.drawData.nickName;
        _avatar = feed.drawData.avatar;
        _author = feed.drawData.userId;
    }else{
        PPDebug(@"<FeedDetailController>:warning feed type is error");
    }
}


#define COMMENT_COUNT 20
- (void)updateCommentList
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [_feedService getOpusCommentList:_opusId offset:_startIndex limit:COMMENT_COUNT delegate:self];
}

- (void)updateNoCommentLabel
{
    self.noCommentTipsLabel.hidden = YES;
    [self.noCommentTipsLabel setText:NSLS(@"kNoCommentTips")];
}

- (void)updateTitle
{
    [self.titleLabel setText:NSLS(@"kFeedDetail")];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self setSupportRefreshFooter:YES];
    [self setSupportRefreshHeader:YES];
    
    [super viewDidLoad];
    [self updateInfo:_feed];
    [self updateTime:_feed];
    [self updateUser:_feed];
    [self updateGuessDesc:_feed];
    [self updateActionButton:_feed];
    [self updateDrawView:_feed];
    [self updateInputView:_feed];
    [self updateCommentTableView:_feed];
    [self updateSendButton:_feed];
    [self updateNoCommentLabel];
    [self updateTitle];
    [self updateCommentList];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setNoCommentTipsLabel:nil];
    [self setTimeLabel:nil];
    [self setGuessStatLabel:nil];
    [self setActionButton:nil];
    [self setNickNameLabel:nil];
    [self setCommentInput:nil];
    [self setSendButton:nil];
    [self setInputViewBg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickActionButton:(id)sender {
    ActionType type = [FeedManager actionTypeForFeed:self.feed];
    if (type == ActionTypeGuess) {
        [OfflineGuessDrawController startOfflineGuess:self.feed fromController:self];        
    }
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc {
    PPRelease(_feed);
    PPRelease(_avatarView);
    PPRelease(_drawView);
    [titleLabel release];
    [noCommentTipsLabel release];
    [timeLabel release];
    [guessStatLabel release];
    [actionButton release];
    [nickNameLabel release];
    [commentInput release];
    [sendButton release];
    [inputViewBg release];
    [super dealloc];
}
- (IBAction)clickSendButton:(id)sender {
    static int index = 1;
    NSString *ifl = @"如果我很长很长呢?";
    NSString *msg = @"";
    for (int i = 0; i < index; ++ i) {
        msg = [NSString stringWithFormat:@"%@%@",msg, ifl];
    }
    ++ index;
    [self showActivityWithText:NSLS(@"kSending")];
    [_feedService commentOpus:_opusId author:_author comment:msg delegate:self];
}

#pragma mark - feed service delegate
- (void)didCommentOpus:(NSString *)opusId
               comment:(NSString *)comment
            resultCode:(NSInteger)resultCode;
{
    [self hideActivity];
    if (resultCode == 0) {
        PPDebug(@"comment succ: opusId = %@, comment = %@", opusId, comment);
        Feed *feed = [[Feed alloc] init];
        UserManager *manager = [UserManager defaultManager];
        feed.userId = [manager userId];
        feed.nickName = [manager nickName];
        feed.avatar = [manager avatarURL];
        feed.gender = [manager isUserMale];
        feed.opusId = opusId;
        feed.comment = comment;
        NSMutableArray *array = [NSMutableArray arrayWithObject:feed];
        [feed release];
        
        if (self.dataList != nil) {
            [array addObjectsFromArray:self.dataList];
        }
        self.dataList = array;
        [self.dataTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    }else{
        PPDebug(@"comment fail: opusId = %@, comment = %@", opusId, comment);        
    }
}

- (void)didGetFeedCommentList:(NSArray *)feedList 
                       opusId:(NSString *)opusId 
                   resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];   
    [self dataSourceDidFinishLoadingMoreData];
    if (resultCode == 0) {
        PPDebug(@"<didGetFeedCommentList>get feed(%@)  succ!", opusId);
        if (_startIndex == 0) {
            self.dataList = feedList;
            [self.dataTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        }else{
            NSMutableArray *array = [NSMutableArray array];
            if ([self.dataList count] != 0) {
                [array  addObjectsFromArray:self.dataList];
            }
            if ([feedList count] != 0) {
                [array addObjectsFromArray:feedList];
            }
            NSInteger start = [self.dataList count];
            NSInteger end = [array count];
            self.dataList = array;
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i = start; i < end; ++ i) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:path];
            }
            if ([indexPaths count] != 0) {
                [self.dataTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }
        NSInteger count = [feedList count];
        _startIndex += count;
        self.noMoreData = (count < COMMENT_COUNT);        
    }else{
        PPDebug(@"<didGetFeedCommentList>get feed(%@)  fail!", opusId);
    }
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
	return [CommentCell getCellHeight:feed];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [dataList count];
    self.noCommentTipsLabel.hidden = (count != 0);
    
    if (count != 0) {
        self.dataTableView.separatorColor = [UIColor lightGrayColor];
    }else{
        self.dataTableView.separatorColor = [UIColor clearColor];
    }
    return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [CommentCell getCellIdentifier];
    CommentCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [CommentCell createCell:self];
    }
    cell.indexPath = indexPath;
    cell.accessoryType = UITableViewCellAccessoryNone;
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
    [cell setCellInfo:feed];
    return cell;
}

#pragma mark - refresh header & footer delegate
- (void)reloadTableViewDataSource
{
    _startIndex = 0;
    [self updateCommentList];
}

- (void)loadMoreTableViewDataSource
{
    [self updateCommentList];
}


@end
