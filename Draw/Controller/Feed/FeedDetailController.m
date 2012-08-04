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
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "Draw.h"
#import "ShareImageManager.h"
#import "CommentCell.h"
#import "OfflineGuessDrawController.h"
#import "SelectWordController.h"
#import "TimeUtils.h"
#import "CommonUserInfoView.h"
#import "ShareService.h"
#import "DrawDataService.h"
//#import "OfflineGuessDrawController.h
@interface FeedDetailController()
- (void)textViewDidChange:(UITextView *)textView;
- (void)changeTableSize:(BOOL)animated duration:(NSTimeInterval)duration;
@end;

@implementation FeedDetailController
@synthesize commentInput;
@synthesize commentLabel = _commentLabel;
@synthesize nickNameLabel;
@synthesize titleLabel;
@synthesize actionButton;
@synthesize sendButton;
@synthesize guessStatLabel;
@synthesize noCommentTipsLabel;
@synthesize timeLabel;
@synthesize feed = _feed;
@synthesize drawView = _drawView;
@synthesize inputBackgroundView = inputBackgroundView;
@synthesize inputBackground = _inputBackground;
@synthesize paperImage = _paperImage;
@synthesize avatarView = _avatarView;


#define AVATAR_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(660, 11, 84, 78) : CGRectMake(278, 6, 29, 28))
#define SHOW_DRAW_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(271,158,228,217) :CGRectMake(113, 73, 95, 100))


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
    NSString *timeString = nil;
    if ([LocaleUtils isChinese]) {
        timeString = chineseBeforeTime(feed.createDate);
    } else {
        timeString = englishBeforeTime(feed.createDate);
    }
    
    if (timeString) {
        [self.timeLabel setText:timeString];
    }else {
        NSString *formate = @"yy-MM-dd HH:mm";
        timeString = dateToStringByFormat(feed.createDate, formate);
        [self.timeLabel setText:timeString];
    }
}


- (void)updateUser:(Feed *)feed
{
    //avatar
//    [self.avatarView removeFromSuperview];
    self.avatarView = [[[AvatarView alloc] initWithUrlString:_avatar frame:AVATAR_VIEW_FRAME gender:feed.gender level:0] autorelease];
    [self.avatarView setUserId:_author];
    [self.view addSubview:self.avatarView];
    self.avatarView.delegate = self;
    
    //name
    [self.nickNameLabel setText:[FeedManager opusCreatorForFeed:feed]];
}

- (void)updateGuessDesc:(Feed *)feed
{
    if (feed.guessTimes == 0) {
        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
    }else{
        NSInteger guessTimes = feed.guessTimes;
        NSInteger correctTimes = feed.correctTimes;
        NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessStat"),guessTimes, correctTimes];
        [self.guessStatLabel setText:desc];        
    }
}

#define ACTION_TAG_GUESS 2012070201
#define ACTION_TAG_CHALLENGE 2012070202

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
        self.actionButton.tag = ACTION_TAG_GUESS;
        self.actionButton.hidden = NO;
    }else if(type == ActionTypeChallenge)
    {
        [self.actionButton setTitle:NSLS(@"kChallenge") forState:UIControlStateNormal];        
        self.actionButton.tag = ACTION_TAG_CHALLENGE;
        self.actionButton.hidden = NO;
    }else{
        self.actionButton.hidden = YES;
    }

}


#define SHOW_VIEW_TAG_SMALL 2012062601
#define SHOW_VIEW_TAG_NORMAL 2012062602

- (void)setShowDrawView:(CGRect)frame animated:(BOOL)animated
{
//    CGRect currentFrame = self.drawView.frame;
    [self.drawView cleanAllActions];
    CGRect normalFrame = DRAW_VIEW_FRAME; 
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [self.drawView setFrame:frame];
        if (self.drawView.tag == SHOW_VIEW_TAG_NORMAL) {
            self.drawView.center = self.view.center;
        }
        [UIView commitAnimations];
    }else{
        [self.drawView setFrame:frame];
    }
    
    CGFloat xScale = frame.size.width / normalFrame.size.width;
    CGFloat yScale = frame.size.height / normalFrame.size.height;
    if (xScale == 1 && yScale == 1) {
        self.drawView.drawActionList = [NSMutableArray arrayWithArray:self.feed.drawData.drawActionList];
    }else{
        self.drawView.drawActionList = [DrawAction scaleActionList:_feed.drawData.drawActionList xScale:xScale yScale:yScale];
    }
    if (self.drawView.tag == SHOW_VIEW_TAG_SMALL) {
        [self.drawView show];        
    }else{
        double speed = [DrawAction calculateSpeed:self.drawView.drawActionList defaultSpeed:1.0/30.0 maxSecond:30];
        self.drawView.playSpeed = speed;
        [self.drawView play];
    }
    
}

- (void)updateDrawView:(Feed *)feed
{
    self.drawView = [[[ShowDrawView alloc] initWithFrame:SHOW_DRAW_VIEW_FRAME] autorelease];
    self.drawView.playSpeed = 1.0/36.0;
    [self.drawView setShowPenHidden:YES];
    self.drawView.delegate = self;
    [self.drawView setBackgroundColor:[UIColor whiteColor]];
    [self.drawView cleanAllActions];
    [self.view addSubview:self.drawView];
    self.drawView.tag = SHOW_VIEW_TAG_SMALL;
    [self setShowDrawView:SHOW_DRAW_VIEW_FRAME animated:NO];
}

#define INPUT_BG_TAG 2012061501
- (void)updateInputView:(Feed *)feed
{
    commentInput.layer.cornerRadius = 6;
    commentInput.layer.masksToBounds = YES;
    _maskView = [[UIButton alloc] initWithFrame:self.view.frame];
    _maskView.hidden = YES;
    _maskView.backgroundColor = [UIColor clearColor];
    [_maskView addTarget:self action:@selector(clickMaskView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view bringSubviewToFront:inputBackgroundView];
    [self.view insertSubview:_maskView belowSubview:inputBackgroundView];
    [self.inputBackground setImage:[ShareImageManager defaultManager].inputImage];
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
    if (feed.drawData == nil) {
        if (feed.drawData == nil && feed.pbDraw) {
            PPDebug(@"<FeedDetailController>init the draw data from the pbDraw,feedId = %@",feed.feedId);
            feed.drawData = [[Draw alloc] initWithPBDraw:feed.pbDraw];
            feed.pbDraw = nil;
        }
    }
    if ([feed isDrawType]) {
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


#define COMMENT_COUNT 12
- (void)updateCommentList
{
//    [self showActivityWithText:NSLS(@"kLoading")];
    [_feedService getOpusCommentList:_opusId offset:_startIndex limit:COMMENT_COUNT delegate:self];
}

- (void)updateNoCommentLabel
{
    self.noCommentTipsLabel.hidden = NO;
    [self.noCommentTipsLabel setText:NSLS(@"kLoadingComments")];
}

- (void)updateTitle
{
    NSString *title = nil;
    if ([self.feed isMyOpus]) {
        title = [NSString stringWithFormat:NSLS(@"kMyDrawing"),
                 self.feed.wordText];        
    }else{
        title = [NSString stringWithFormat:NSLS(@"kFeedDetail"),[FeedManager opusCreatorForFeed:self.feed]];
    }
    [self.titleLabel setText:title];
    [self.commentLabel setText:NSLS(@"kFeeds")];
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
    [self updateCommentTableView:_feed];
    [self updateSendButton:_feed];
    [self updateNoCommentLabel];
    [self updateTitle];
    [self updateInputView:_feed];
    [self updateCommentList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateActionButton:_feed];
    [self updateGuessDesc:_feed];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    [self setInputBackgroundView:nil];
    [self setCommentLabel:nil];
    [self setDrawView:nil];
    [self setInputBackground:nil];
    [self setPaperImage:nil];
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

    NSInteger tag = [(UIButton *)sender tag];
    if (tag == ACTION_TAG_GUESS) {
        OfflineGuessDrawController *controller = [OfflineGuessDrawController startOfflineGuess:self.feed fromController:self];        
        controller.delegate = self;
        
    }else if(tag == ACTION_TAG_CHALLENGE){
        [self didClickOnAvatar:_author];
    
    }
}


- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc {
    
    [_drawView cleanAllActions];
    _drawView.delegate = nil;
    
    PPRelease(_feed);
    PPRelease(_avatarView);
    PPRelease(_drawView);
    
    
    PPRelease(titleLabel);
    PPRelease(noCommentTipsLabel);
    PPRelease(timeLabel);
    PPRelease(guessStatLabel);
    PPRelease(actionButton);
    PPRelease(nickNameLabel);
    PPRelease(commentInput);
    PPRelease(sendButton);
    PPRelease(inputBackgroundView);
    PPRelease(_maskView);
    PPRelease(_commentLabel);
    PPRelease(_drawView);
    PPRelease(_inputBackground);
    PPRelease(_paperImage);
    
    [super dealloc];
}
- (IBAction)clickSendButton:(id)sender {
    NSString *msg = commentInput.text;
    if ([msg length] != 0) {
        [self showActivityWithText:NSLS(@"kSending")];
        [_feedService commentOpus:_opusId author:_author comment:msg delegate:self];        
    }
}

#define WIDTH_SHARE_BUTTON      ([DeviceDetection isIPAD] ? 180.0 : 90.0)
#define HEIGHT_SHARE_BUTTON     ([DeviceDetection isIPAD] ? 60.0 : 30.0)
#define FONT_SIZE_SHARE_BUTTON  ([DeviceDetection isIPAD] ? 28.0 : 14.0)
#define SPACE_DRAW_AND_BUTTON   ([DeviceDetection isIPAD] ? 20.0 : 10.0)
#define TAG_SHARE_BUTTON        2012072301
- (void)removeShareButton
{
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_SHARE_BUTTON];
    [button removeFromSuperview];
}

- (void)addShareButton
{
    [self removeShareButton];
    UIButton *button = [[UIButton alloc] init];
    button.tag = TAG_SHARE_BUTTON;
    [button setFrame:CGRectMake((self.view.frame.size.width-WIDTH_SHARE_BUTTON)/2, _drawView.frame.origin.y+ _drawView.frame.size.height + SPACE_DRAW_AND_BUTTON, WIDTH_SHARE_BUTTON, HEIGHT_SHARE_BUTTON)];
    [button addTarget:self action:@selector(clickSaveAndShare:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];
    [button setTitle:NSLS(@"kSaveAndShare") forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_SHARE_BUTTON]];
    [button.titleLabel setShadowColor:[UIColor blackColor]];
    [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    
    [self.view addSubview:button];
    [button release];
}

- (void)clickSaveAndShare:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self.drawView show]; 
    [[ShareService defaultService] shareWithImage:[_drawView createImage] 
                                       drawUserId:_feed.userId 
                                       isDrawByMe:[_feed isMyOpus] 
                                         drawWord:_feed.wordText];    
    
    [[DrawDataService defaultService] saveActionList:_feed.drawData.drawActionList 
                                              userId:_feed.userId 
                                            nickName:_feed.nickName 
                                           isMyPaint:[_feed isMyOpus] 
                                                word:_feed.wordText
                                               image:[_drawView createImage] viewController:self];
    
    button.enabled = NO;
    button.selected = YES;
}


- (void)didClickShowDrawView:(ShowDrawView *)showDrawView
{
    if (showDrawView.tag == SHOW_VIEW_TAG_SMALL) {
        showDrawView.tag = SHOW_VIEW_TAG_NORMAL;
        [self setShowDrawView:DRAW_VIEW_FRAME animated:YES];
        _maskView.hidden = NO;
        _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self.view bringSubviewToFront:_maskView];
        [self.view bringSubviewToFront:self.drawView];
        [self addShareButton];
    }else{
        _maskView.hidden = YES;
        _maskView.backgroundColor = [UIColor clearColor];
        showDrawView.tag = SHOW_VIEW_TAG_SMALL;        
        [self setShowDrawView:SHOW_DRAW_VIEW_FRAME animated:YES];
        [self removeShareButton];
    }
}

#pragma mark - feed service delegate
- (void)didCommentOpus:(NSString *)opusId
               comment:(NSString *)comment
            resultCode:(NSInteger)resultCode;
{
    [self hideActivity];
    
    if (resultCode == 0) {
        [self.commentInput setText:@""];
        [self.commentInput resignFirstResponder];
        [self textViewDidChange:self.commentInput];
        
        PPDebug(@"comment succ: opusId = %@, comment = %@", opusId, comment);
        Feed *feed = [[Feed alloc] init];
        UserManager *manager = [UserManager defaultManager];
        feed.userId = [manager userId];
        feed.nickName = [manager nickName];
        feed.avatar = [manager avatarURL];
        feed.gender = [manager isUserMale];
        feed.createDate = [NSDate date];
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
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCommentFail") delayTime:1 isHappy:NO];
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
        self.noMoreData = (count < COMMENT_COUNT * 0.8);        
    }else{
        PPDebug(@"<didGetFeedCommentList>get feed(%@)  fail!", opusId);
    }
    [noCommentTipsLabel setText:NSLS(@"kNoCommentTips")];
}


- (void)didDeleteFeed:(Feed *)feed resultCode:(NSInteger)resultCode;

{
    [self hideActivity];
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDeleteFail") delayTime:1.5 isHappy:NO];
        return;
    }
    NSInteger row = [self.dataList indexOfObject:feed];
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataList];
    [array removeObject:feed];
    self.dataList = array;
    [self.dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
	CGFloat height = [CommentCell getCellHeight:feed];
    return height;
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


#pragma mark - delete feed.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
    [self showActivityWithText:NSLS(@"kDeleting")];
    [[FeedService defaultService] deleteFeed:feed delegate:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
    return [[UserManager defaultManager] isMe:feed.userId] || [self.feed isMyOpus];
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

#pragma offline guess delegate
- (void)didGuessFeed:(Feed *)feed 
           isCorrect:(BOOL)isCorrect 
               words:(NSArray *)words
{
    UserManager *userManager = [UserManager defaultManager];
    Feed *comment = [[Feed alloc] init];
    [comment setCorrect:isCorrect];
    [comment setGuessWords:words];
    [comment setUserId:[userManager userId]];
    [comment setAvatar:[userManager avatarURL]];
    [comment setGender:[userManager isUserMale]];
    [comment setCreateDate:[NSDate date]];
    [comment setFeedType:FeedTypeGuess];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:comment];
    if ([[self dataList] count] != 0) {
        [array addObjectsFromArray:self.dataList];
    }
    self.dataList = array;
    [comment release];
}



#define MAX_LENGTH 140

#pragma mark - UITextViewDelegate methods
#define INPUT_TEXT_WIDTH_MAX    (([DeviceDetection isIPAD])?(550.0):(230.0))
#define INPUT_TEXT_HEIGHT_MAX   (([DeviceDetection isIPAD])?(120.0):(60.0))
#define TEXTTVIEW_HEIGHT_MIN    (([DeviceDetection isIPAD])?(64.0):(32.0))
#define INPUTBACKGROUNDVIEW_HEIGHT_MIN  (([DeviceDetection isIPAD])?(80.0):(38.0))
- (void)textViewDidChange:(UITextView *)textView
{
    UIFont *font = textView.font;
    CGSize size = [textView.text sizeWithFont:font constrainedToSize:CGSizeMake(INPUT_TEXT_WIDTH_MAX, INPUT_TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
//    PPDebug(@"%f %f %f", textView.frame.size.height, size.height, size.width);
    CGRect oldFrame = textView.frame;
    CGFloat newHeight = size.height + 12;
    CGRect oldBackgroundFrame = inputBackgroundView.frame;
    
    if (newHeight > TEXTTVIEW_HEIGHT_MIN) {
        CGFloat addHeight = newHeight - oldFrame.size.height;
        [textView setFrame: CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, newHeight)];
        [inputBackgroundView setFrame:CGRectMake(oldBackgroundFrame.origin.x, oldBackgroundFrame.origin.y-addHeight, oldBackgroundFrame.size.width, oldBackgroundFrame.size.height+addHeight)];
    }else {
        [textView setFrame: CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, TEXTTVIEW_HEIGHT_MIN)];
        CGFloat delHeight = oldBackgroundFrame.size.height - INPUTBACKGROUNDVIEW_HEIGHT_MIN;
        [inputBackgroundView setFrame:CGRectMake(oldBackgroundFrame.origin.x, oldBackgroundFrame.origin.y+delHeight, oldBackgroundFrame.size.width, INPUTBACKGROUNDVIEW_HEIGHT_MIN)];
    }
    
    self.inputBackground.frame = CGRectMake(self.inputBackground.frame.origin.x, self.inputBackground.frame.origin.y, self.inputBackground.frame.size.width, textView.frame.size.height );//这个IMAGE_AND_TEXT_DIFF参照xib
    self.inputBackground.center = textView.center;
    
    [self changeTableSize:NO duration:0];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [_maskView setHidden:NO];
    [self.view bringSubviewToFront:_maskView];
    [self.view bringSubviewToFront:self.inputBackgroundView];
//    [self.view bringSubviewToFront:textView];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [_maskView setHidden:YES];
    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text  
{  
    
    if ([text isEqualToString:@"\n"]) {  
        [self clickSendButton:self.sendButton];
        return NO;  
    }  
    return YES;  
} 

- (void)clickMaskView:(id)sender
{
    if (self.drawView.tag == SHOW_VIEW_TAG_NORMAL) {
        return;
    }
    [commentInput resignFirstResponder];
}


#pragma mark - super methods: keyboard show and hide
#define SUPER_VIEW_HEIGHT (([DeviceDetection isIPAD])?(1004.0):(460.0))
- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
{
    CGRect frame = CGRectMake(0, SUPER_VIEW_HEIGHT-keyboardRect.size.height-inputBackgroundView.frame.size.height, inputBackgroundView.frame.size.width, inputBackgroundView.frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    inputBackgroundView.frame = frame;
    [UIImageView commitAnimations];
    
    [self changeTableSize:YES duration:0.25];
}


- (void)keyboardWillHideWithRect:(CGRect)keyboardRect
{
    CGRect frame = CGRectMake(0, SUPER_VIEW_HEIGHT-inputBackgroundView.frame.size.height, inputBackgroundView.frame.size.width, inputBackgroundView.frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    inputBackgroundView.frame = frame;
    [UIImageView commitAnimations];
    
    [self changeTableSize:YES duration:0.25];
}

#define TABLE_AND_INPUT_SPACE (([DeviceDetection isIPAD])?(24.0):(12.0))
- (void)changeTableSize:(BOOL)animated duration:(NSTimeInterval)duration
{
    CGFloat newPaperHeight = self.inputBackgroundView.frame.origin.y - self.paperImage.frame.origin.y;
    CGRect newPaperFrame = CGRectMake(self.paperImage.frame.origin.x, self.paperImage.frame.origin.y, self.paperImage.frame.size.width, newPaperHeight);
//    CGFloat newTableHeight = inputBackgroundView.frame.origin.y - dataTableView.frame.origin.y - TABLE_AND_INPUT_SPACE;
//    CGRect newTableFrame = CGRectMake(dataTableView.frame.origin.x, dataTableView.frame.origin.y, dataTableView.frame.size.width, newTableHeight);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        self.paperImage.frame = newPaperFrame;
        //dataTableView.frame = newTableFrame;
        [UIView commitAnimations];
    }else {
        self.paperImage.frame = newPaperFrame;
        //dataTableView.frame = newTableFrame;
    }
}

#pragma mark - avatar view delegate
- (void)didClickOnAvatar:(NSString *)userId
{
    [CommonUserInfoView showUser:userId 
                        nickName:nil 
                          avatar:nil 
                          gender:nil 
                        location:nil 
                           level:1
                         hasSina:NO 
                           hasQQ:NO 
                     hasFacebook:NO 
                      infoInView:self];
}


@end
