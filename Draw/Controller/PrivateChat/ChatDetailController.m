//
//  ChatDetailController.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatDetailController.h"
#import "DeviceDetection.h"
#import "ChatMessage.h"
#import "ChatMessageManager.h"
#import "UserManager.h"
#import "DrawConstants.h"
#import "DrawDataService.h"
#import "DrawAction.h"
#import "GameBasic.pb.h"
#import "ShowDrawView.h"
#import "MessageTotalManager.h"
#import "ChatMessageUtil.h"
#import "ShareImageManager.h"
#import "ReplayGraffitiController.h"
#import "DrawAppDelegate.h"
#import "ChatDetailCell.h"
#import "CommonMessageCenter.h"

@interface ChatDetailController ()
@property (retain, nonatomic) NSString *friendUserId;
@property (retain, nonatomic) NSString *friendNickname;
@property (retain, nonatomic) NSString *friendAvatar;
@property (retain, nonatomic) OfflineDrawViewController *offlineDrawViewController;

- (IBAction)clickBack:(id)sender;

- (void)scrollToBottom:(BOOL)animated;
- (void)showGraffitiView;
- (void)hideGraffitiView;
- (void)removeHideKeyboardButton;
- (void)addHideKeyboardButton;
- (void)clickHideKeyboardButton:(id)sender;
- (void)replayGraffiti:(id)sender;
- (ShowDrawView *)createShowDrawView:(NSArray *)drawActionList scale:(CGFloat)scale;
- (UIView *)createBubbleView:(ChatMessage *)message indexPath:(NSIndexPath *)indexPath;
- (void)changeTableSize:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)keepSendButtonSite;
- (void)updateInputViewAndTableFrame;

@end


@implementation ChatDetailController
@synthesize titleLabel;
@synthesize graffitiButton;
@synthesize inputBackgroundView;
@synthesize inputTextView;
@synthesize sendButton;
@synthesize inputTextBackgroundImage;
@synthesize paperImageView;
@synthesize friendUserId = _friendUserId;
@synthesize friendNickname = _friendNickname;
@synthesize friendAvatar = _friendAvatar;
@synthesize offlineDrawViewController = _offlineDrawViewController;


- (void)dealloc {
    PPRelease(_offlineDrawViewController);
    PPRelease(_friendNickname);
    PPRelease(_friendUserId);
    PPRelease(_friendAvatar);
    PPRelease(titleLabel);
    PPRelease(graffitiButton);
    PPRelease(sendButton);
    PPRelease(inputTextView);
    PPRelease(inputBackgroundView);
    [inputTextBackgroundImage release];
    [paperImageView release];
    [super dealloc];
}


- (id)initWithFriendUserId:(NSString *)frindUserId friendNickname:(NSString *)friendNickname friendAvatar:(NSString *)friendAvatar
{
    self = [super init];
    if (self) {
        self.friendUserId = frindUserId;
        self.friendNickname = friendNickname;
        self.friendAvatar = friendAvatar;
    }
    return self;
}


- (void)viewDidLoad
{
    self.supportRefreshHeader = YES;
    
    [super viewDidLoad];
    self.titleLabel.text = self.friendNickname;
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [inputTextBackgroundImage setImage:[imageManager inputImage]];
    [sendButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [sendButton setTitle:NSLS(@"kSendMessage") forState:UIControlStateNormal];
    [graffitiButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [graffitiButton setTitle:NSLS(@"kGraffiti") forState:UIControlStateNormal];
    inputBackgroundView.backgroundColor = [UIColor clearColor];
    [self changeTableSize:NO duration:0];
    
    [[MessageTotalManager defaultManager] readNewMessageWithFriendUserId:_friendUserId 
                                                                  userId:[[UserManager defaultManager] userId]];
    self.dataList = [[ChatMessageManager defaultManager] findMessagesByFriendUserId:_friendUserId];
    [self findAllMessages];
    
    DrawAppDelegate *drawAppDelegate = (DrawAppDelegate *)[[UIApplication sharedApplication] delegate];
    drawAppDelegate.chatDetailController = self;
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setGraffitiButton:nil];
    [self setSendButton:nil];
    [self setInputBackgroundView:nil];
    [self setInputTextView:nil];
    [self setInputTextBackgroundImage:nil];
    [self setPaperImageView:nil];
    [super viewDidUnload];
}


- (void)viewDidAppear:(BOOL)animated
{
    //not reload data
    //PPDebug(@"ChatDetailController viewDidAppear");
}


- (void)viewDidDisappear:(BOOL)animated
{
    DrawAppDelegate *drawAppDelegate = (DrawAppDelegate *)[[UIApplication sharedApplication] delegate];
    drawAppDelegate.chatDetailController = nil;
    [super viewDidDisappear:animated];
}


#pragma mark - ChatServiceDelegate methods
- (void)didFindAllMessages:(NSArray *)list resultCode:(int)resultCode newMessagesCount:(NSUInteger)newMessagesCount
{
    [self dataSourceDidFinishLoadingNewData];
    
    if (resultCode == 0) {
        if (newMessagesCount > 0) {
            [[ChatService defaultService] sendHasReadMessage:nil friendUserId:_friendUserId];
        }
    }
    self.dataList = list;
    [dataTableView reloadData];
}


- (void)didSendMessage:(int)resultCode
{
    [self hideActivity];
    
    if (resultCode == 0) {
        [inputTextView setText:@""];
        [self updateInputViewAndTableFrame];
        
        self.dataList = [[ChatMessageManager defaultManager] findMessagesByFriendUserId:_friendUserId];
        [dataTableView reloadData];
        
        [self hideGraffitiView];
    } else {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSendMessageFailed") delayTime:2 isHappy:NO];
    }
    
    [inputTextView resignFirstResponder];
}


#pragma mark - custom methods
- (void)scrollToBottom:(BOOL)animated
{
    if ([dataList count]>0) {
        NSIndexPath *indPath = [NSIndexPath indexPathForRow:[dataList count]-1 inSection:0];
        [dataTableView scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


- (void)findAllMessages
{
    [[ChatService defaultService] findAllMessages:self friendUserId:_friendUserId starOffset:0 maxCount:100];
}


- (void)showGraffitiView
{
    OfflineDrawViewController *odc = [[OfflineDrawViewController alloc] initWithTargetType:TypeGraffiti delegate:self];
    self.offlineDrawViewController = odc;
    [odc release];
    //PPDebug(@"offlineDrawViewController:%d",[_offlineDrawViewController retainCount]);
    [self.view addSubview:_offlineDrawViewController.view];
    CGRect frame = _offlineDrawViewController.view.frame;
    _offlineDrawViewController.view.frame = CGRectMake(0, self.view.frame.size.height, frame.size.width, frame.size.height);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    _offlineDrawViewController.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [UIImageView commitAnimations];
}


- (void)hideGraffitiView
{
    if (_offlineDrawViewController) {
        CGRect frame = _offlineDrawViewController.view.frame;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        _offlineDrawViewController.view.frame = CGRectMake(0, self.view.frame.size.height, frame.size.width, frame.size.height);
        [UIImageView commitAnimations];
    }
}


#define HIDE_KEYBOARDBUTTON_TAG 77
#define NAVIGATION_BAR_HEIGHT (([DeviceDetection isIPAD])?(100.0):(50.0))
- (void)removeHideKeyboardButton
{
    UIButton *button = (UIButton*)[self.view viewWithTag:HIDE_KEYBOARDBUTTON_TAG];
    [button removeFromSuperview];
}


- (void)addHideKeyboardButton
{
    [self removeHideKeyboardButton];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-NAVIGATION_BAR_HEIGHT)];
    button.tag = HIDE_KEYBOARDBUTTON_TAG;
    [button addTarget:self action:@selector(clickHideKeyboardButton:) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:button];
    [button release];
}

- (void)clickHideKeyboardButton:(id)sender
{
    [inputTextView resignFirstResponder];
    [self removeHideKeyboardButton];
}


- (void)replayGraffiti:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag =  button.tag;
    ChatMessage *message = [dataList objectAtIndex:tag];
    if ([message.text length] <= 0 && message.drawData) {
        NSArray* drawActionList = [ChatMessageUtil unarchiveDataToDrawActionList:message.drawData];
        ReplayGraffitiController *controller = [[ReplayGraffitiController alloc] initWithDrawActionList:drawActionList];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}


- (ShowDrawView *)createShowDrawView:(NSArray *)drawActionList scale:(CGFloat)scale
{
    ShowDrawView *showDrawView = [[[ShowDrawView alloc] init] autorelease];
    showDrawView.frame = CGRectMake(0, 0, scale * DRAW_VEIW_FRAME.size.width, scale * DRAW_VEIW_FRAME.size.height);
    NSMutableArray *scaleActionList = nil;
    if ([DeviceDetection isIPAD]) {
        scaleActionList = [DrawAction scaleActionList:drawActionList 
                                               xScale:IPAD_WIDTH_SCALE*scale 
                                               yScale:IPAD_HEIGHT_SCALE*scale];
    } else {
        scaleActionList = [DrawAction scaleActionList:drawActionList 
                                               xScale:scale 
                                               yScale:scale];
    }
    [showDrawView setDrawActionList:scaleActionList]; 
    [showDrawView setShowPenHidden:YES];
    [showDrawView show];
    return showDrawView;
}


#define TEXT_WIDTH_MAX    (([DeviceDetection isIPAD])?(400.0):(200.0))
#define TEXT_HEIGHT_MAX   (([DeviceDetection isIPAD])?(2000.0):(1000.0))
#define TEXT_FONT_SIZE  (([DeviceDetection isIPAD])?(30):(15))
#define SPACE_Y         (([DeviceDetection isIPAD])?(20):(10))
#define SCREEN_WIDTH    (([DeviceDetection isIPAD])?(768):(320))
#define TEXTVIEW_BORDER_X (([DeviceDetection isIPAD])?(10):(8))
#define TEXTVIEW_BORDER_Y (([DeviceDetection isIPAD])?(10):(8))
#define BUBBLE_TIP_WIDTH   (([DeviceDetection isIPAD])?(16):(10))
#define BUBBLE_NOT_TIP_WIDTH    (([DeviceDetection isIPAD])?(10):(5))
#define IMAGE_WIDTH_MAX (([DeviceDetection isIPAD])?(200.0):(100.0))
#define IMAGE_BORDER_X (([DeviceDetection isIPAD])?(10):(5))
#define IMAGE_BORDER_Y (([DeviceDetection isIPAD])?(16):(8))
/*
 TEXT_WIDTH_MAX 是消息的最大长度
 TEXT_HEIGHT_MAX  是消息的最大高度
 TEXT_FONT_SIZE  是字体
 SPACE_Y  是上一个气泡图与下一个的距离
 SCREEN_WIDTH    是屏幕宽度
 TEXTVIEW_BORDER_X  是TextView的文字与左或右边界的空隙
 TEXTVIEW_BORDER_Y  是TextView的文字与上或下边界的空隙
 BUBBLE_TIP_WIDTH   是气泡图尖角的宽度
 BUBBLE_NOT_TIP_WIDTH 是气泡图非尖角的宽度
 IMAGE_WIDTH_MAX    是图片的最大宽度
 IMAGE_BORDER_X 是图片与气泡图边界X方向的空隙
 IMAGE_BORDER_Y 是图片与气泡图边界Y方向的空隙
 */
- (UIView *)createBubbleView:(ChatMessage *)message indexPath:(NSIndexPath *)indexPath
{
    UIView *returnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	returnView.backgroundColor = [UIColor clearColor];
    
    BOOL fromSelf = [message.from isEqualToString:[[UserManager defaultManager] userId]];
	UIImage *bubble = [UIImage imageNamed:fromSelf ? @"sent_message.png" : @"receive_message.png"];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:14 topCapHeight:14]];
    bubbleImageView.backgroundColor =[UIColor clearColor];
    
    if ([message.text length] > 0) {
        //string的大小
        UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        CGSize textSize = [message.text sizeWithFont:font constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
        
        //设置文本
        CGRect contentTextViewFrame;
        if (fromSelf){
            contentTextViewFrame = CGRectMake(BUBBLE_NOT_TIP_WIDTH, 0, textSize.width+2*TEXTVIEW_BORDER_X, textSize.height+2*TEXTVIEW_BORDER_Y);
        }else {
            contentTextViewFrame = CGRectMake(BUBBLE_TIP_WIDTH, 0, textSize.width+2*TEXTVIEW_BORDER_X, textSize.height+2*TEXTVIEW_BORDER_Y);
        }
        UITextView *contentTextView = [[UITextView alloc] initWithFrame:contentTextViewFrame];
        //contentTextView.backgroundColor = [UIColor clearColor];
        contentTextView.font = font;
        contentTextView.text = message.text;
        
        //设置气泡的frame
        bubbleImageView.frame = CGRectMake(0.0f, 0.5*SPACE_Y, contentTextView.frame.size.width+BUBBLE_TIP_WIDTH+BUBBLE_NOT_TIP_WIDTH, contentTextView.frame.size.height);
        [bubbleImageView addSubview:contentTextView];
        [contentTextView release];
        
    }else {
        //设置涂鸦
        NSArray* drawActionList = [ChatMessageUtil unarchiveDataToDrawActionList:message.drawData];
        CGFloat scale = IMAGE_WIDTH_MAX / DRAW_VEIW_FRAME.size.width;
        ShowDrawView *thumbImageView = [self createShowDrawView:drawActionList scale:scale];
        CGFloat multiple = thumbImageView.frame.size.height / thumbImageView.frame.size.width;
        if (fromSelf){
            thumbImageView.frame = CGRectMake(BUBBLE_NOT_TIP_WIDTH+IMAGE_BORDER_X, IMAGE_BORDER_Y, IMAGE_WIDTH_MAX, multiple * IMAGE_WIDTH_MAX );
        }else {
            thumbImageView.frame = CGRectMake(BUBBLE_TIP_WIDTH+IMAGE_BORDER_X, IMAGE_BORDER_Y, IMAGE_WIDTH_MAX, multiple *IMAGE_WIDTH_MAX);
        }
        
        //设置气泡的frame
        bubbleImageView.frame = CGRectMake(0.0f, 0.5*SPACE_Y, thumbImageView.frame.size.width+BUBBLE_TIP_WIDTH+BUBBLE_NOT_TIP_WIDTH+2*IMAGE_BORDER_X, thumbImageView.frame.size.height+2*IMAGE_BORDER_Y);
        [bubbleImageView addSubview:thumbImageView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:thumbImageView.frame];
        button.tag = indexPath.row;
        [button addTarget:self action:@selector(replayGraffiti:) forControlEvents:UIControlEventAllEvents];
        [bubbleImageView addSubview:button];
        [button release];
    }
    
    
    
    //设置returnView的frame
    if (fromSelf) {
        returnView.frame = CGRectMake(SCREEN_WIDTH-bubbleImageView.frame.size.width, 0, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height+SPACE_Y);
    }else{
        returnView.frame = CGRectMake(0, 0, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height + SPACE_Y);
    }
    
    [returnView addSubview:bubbleImageView];
    [bubbleImageView release];
    return returnView;
}


#define TABLE_AND_INPUT_SPACE (([DeviceDetection isIPAD])?(24.0):(12.0))
- (void)changeTableSize:(BOOL)animated duration:(NSTimeInterval)duration
{
    CGFloat newPaperHeight = inputBackgroundView.frame.origin.y - paperImageView.frame.origin.y;
    CGRect newPaperFrame = CGRectMake(paperImageView.frame.origin.x, paperImageView.frame.origin.y, paperImageView.frame.size.width, newPaperHeight);
    CGFloat newTableHeight = inputBackgroundView.frame.origin.y - dataTableView.frame.origin.y - TABLE_AND_INPUT_SPACE;
    CGRect newTableFrame = CGRectMake(dataTableView.frame.origin.x, dataTableView.frame.origin.y, dataTableView.frame.size.width, newTableHeight);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        paperImageView.frame = newPaperFrame;
        dataTableView.frame = newTableFrame;
        [UIView commitAnimations];
    }else {
        paperImageView.frame = newPaperFrame;
        dataTableView.frame = newTableFrame;
    }
}


#define SENDBUTTON_AND_BOTTOM_SPACE (([DeviceDetection isIPAD])?(8.0):(4.0))
- (void)keepSendButtonSite
{
    CGFloat newY = inputBackgroundView.frame.size.height-sendButton.frame.size.height-SENDBUTTON_AND_BOTTOM_SPACE;
    sendButton.frame = CGRectMake(sendButton.frame.origin.x, newY, sendButton.frame.size.width, sendButton.frame.size.height);
    graffitiButton.frame = CGRectMake(graffitiButton.frame.origin.x, newY, graffitiButton.frame.size.width, graffitiButton.frame.size.height);
}



#pragma mark - UITableViewDelegate or UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataList count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *message = (ChatMessage *)[dataList objectAtIndex:indexPath.row];
    return [ChatDetailCell getCellHeight:message];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [ChatDetailCell getCellIdentifier];
    ChatDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ChatDetailCell createCell:self];
    }
    cell.chatDetailCellDelegate = self;
    ChatMessage *message = (ChatMessage *)[dataList objectAtIndex:indexPath.row];
    [cell setCellByChatMessage:message friendNickname:_friendNickname friendAvatar:_friendAvatar indexPath:indexPath];
    
    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - button action
- (IBAction)clickBack:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)clickGraffitiButton:(id)sender 
{
    [self showGraffitiView];
    [inputTextView resignFirstResponder];
}

- (IBAction)clickSendButton:(id)sender 
{
    if ([inputTextView.text length] <= 0) {
        return;
    }
    
    [self showActivityWithText:NSLS(@"kSendingChatMessage")];
    [[ChatService defaultService] sendMessage:self 
                                 friendUserId:_friendUserId 
                                         text:inputTextView.text 
                               drawActionList:nil];
}


#pragma mark - super methods: keyboard show and hide
#define SUPER_VIEW_HEIGHT (([DeviceDetection isIPAD])?(1004.0):(460.0))
- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
{
    [self addHideKeyboardButton];
    [self.view bringSubviewToFront:inputBackgroundView];
    
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


#pragma mark - OfflineDrawDelegate methods
- (void)didClickBack
{
    [self hideGraffitiView];
}


- (void)didClickSubmit:(NSArray *)drawActionList
{
    [self showActivityWithText:NSLS(@"kSendingChatMessage")];
    [[ChatService defaultService] sendMessage:self 
                                 friendUserId:_friendUserId 
                                         text:nil 
                               drawActionList:drawActionList];
}


#pragma mark - UITextViewDelegate methods
#define INPUT_TEXT_WIDTH_MAX    (([DeviceDetection isIPAD])?(370.0):(180.0))
#define INPUT_TEXT_HEIGHT_MAX   (([DeviceDetection isIPAD])?(180.0):(90.0))
#define TEXTTVIEW_HEIGHT_MIN    (([DeviceDetection isIPAD])?(58.0):(32.0))
#define INPUTBACKGROUNDVIEW_HEIGHT_MIN  (([DeviceDetection isIPAD])?(92.0):(46.0))
#define IMAGE_AND_TEXT_DIFF  (([DeviceDetection isIPAD])?(14.0):(4.0))
/*
 TEXTTVIEW_HEIGHT_MIN、INPUTBACKGROUNDVIEW_HEIGHT_MIN、IMAGE_AND_TEXT_DIFF 要参照XIB的值
 */
- (void)textViewDidChange:(UITextView *)textView
{
    [self updateInputViewAndTableFrame];
}


- (void)updateInputViewAndTableFrame
{
    UIFont *font = inputTextView.font;
    CGSize size = [inputTextView.text sizeWithFont:font constrainedToSize:CGSizeMake(INPUT_TEXT_WIDTH_MAX, INPUT_TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    PPDebug(@"%f %f %f", inputTextView.frame.size.height, size.height, size.width);
    CGRect oldFrame = inputTextView.frame;
    CGFloat newHeight = size.height + 12;
    CGRect oldBackgroundFrame = inputBackgroundView.frame;
    
    if (newHeight > TEXTTVIEW_HEIGHT_MIN) {
        CGFloat addHeight = newHeight - oldFrame.size.height;
        [inputTextView setFrame: CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, newHeight)];
        [inputBackgroundView setFrame:CGRectMake(oldBackgroundFrame.origin.x, oldBackgroundFrame.origin.y-addHeight, oldBackgroundFrame.size.width, oldBackgroundFrame.size.height+addHeight)];
    }else {
        [inputTextView setFrame: CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, TEXTTVIEW_HEIGHT_MIN)];
        CGFloat delHeight = oldBackgroundFrame.size.height - INPUTBACKGROUNDVIEW_HEIGHT_MIN;
        [inputBackgroundView setFrame:CGRectMake(oldBackgroundFrame.origin.x, oldBackgroundFrame.origin.y+delHeight, oldBackgroundFrame.size.width, INPUTBACKGROUNDVIEW_HEIGHT_MIN)];
    }
    
    inputTextBackgroundImage.frame = CGRectMake(inputTextBackgroundImage.frame.origin.x, inputTextBackgroundImage.frame.origin.y, inputTextBackgroundImage.frame.size.width, inputTextView.frame.size.height + IMAGE_AND_TEXT_DIFF);//这个IMAGE_AND_TEXT_DIFF参照xib
    inputTextBackgroundImage.center = inputTextView.center;
    
    [self changeTableSize:NO duration:0];
}


#pragma mark - ChatDetailCellDelegate methods
- (void)didClickEnlargeButton:(NSIndexPath *)aIndexPath
{
    ChatMessage *message = [dataList objectAtIndex:aIndexPath.row];
    if ([message.text length] <= 0 && message.drawData) {
        NSArray* drawActionList = [ChatMessageUtil unarchiveDataToDrawActionList:message.drawData];
        ReplayGraffitiController *controller = [[ReplayGraffitiController alloc] initWithDrawActionList:drawActionList];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}


#pragma mark - pull down to refresh
// When "pull down to refresh" in triggered, this function will be called  
- (void)reloadTableViewDataSource
{
    [self findAllMessages];
}


@end
