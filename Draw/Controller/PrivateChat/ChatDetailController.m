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

@interface ChatDetailController ()

@property (retain, nonatomic) NSString *friendUserId;
@property (retain, nonatomic) NSString *friendNickname;
@property (retain, nonatomic) OfflineDrawViewController *offlineDrawViewController;

- (IBAction)clickBack:(id)sender;
- (void)scrollToBottom;
- (void)findAllMessages;
- (ShowDrawView *)createShowDrawView:(NSArray *)drawActionList scale:(CGFloat)scale;
- (UIView *)createBubbleView:(ChatMessage *)message;
- (void)downInputView;

@end


@implementation ChatDetailController
@synthesize titleLabel;
@synthesize graffitiButton;
@synthesize inputBackgroundView;
@synthesize inputTextView;
@synthesize sendButton;
@synthesize friendUserId = _friendUserId;
@synthesize friendNickname = _friendNickname;
@synthesize offlineDrawViewController = _offlineDrawViewController;

- (void)dealloc {
    PPRelease(_offlineDrawViewController);
    PPRelease(_friendNickname);
    PPRelease(_friendUserId);
    PPRelease(titleLabel);
    PPRelease(graffitiButton);
    PPRelease(sendButton);
    PPRelease(inputBackgroundView);
    [inputTextView release];
    [super dealloc];
}

- (id)initWithFriendUserId:(NSString *)frindUserId friendNickname:(NSString *)friendNickname
{
    self = [super init];
    if (self) {
        self.friendUserId = frindUserId;
        self.friendNickname = friendNickname;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add a single tap Recognizer
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1; // For single tap
    [self.dataTableView addGestureRecognizer:singleTapRecognizer];
    [singleTapRecognizer release];
    
    self.titleLabel.text = self.friendNickname;
    inputTextView.layer.cornerRadius = 6;
    inputTextView.layer.masksToBounds = YES;
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [sendButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [sendButton setTitle:NSLS(@"kSendMessage") forState:UIControlStateNormal];
    [graffitiButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [graffitiButton setTitle:NSLS(@"kGraffiti") forState:UIControlStateNormal];
    
    
    [[MessageTotalManager defaultManager] readNewMessageWithFriendUserId:_friendUserId 
                                                                  userId:[[UserManager defaultManager] userId]];
    
    self.dataList = [[ChatMessageManager defaultManager] findMessagesByFriendUserId:_friendUserId];
    [self findAllMessages];
    [self scrollToBottom];
}

- (void)scrollToBottom
{
    if ([dataList count]>0) {
        NSIndexPath *indPath = [NSIndexPath indexPathForRow:[dataList count]-1 inSection:0];
        [dataTableView scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setGraffitiButton:nil];
    [self setSendButton:nil];
    [self setInputBackgroundView:nil];
    [self setInputTextView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    PPDebug(@"ChatDetailController viewDidAppear");
}

- (void)findAllMessages
{
    [[ChatService defaultService] findAllMessages:self friendUserId:_friendUserId starOffset:0 maxCount:100];
}

- (void)didFindAllMessages:(NSArray *)list resultCode:(int)resultCode
{
    if (resultCode == 0) {
        [[ChatService defaultService] sendHasReadMessage:nil friendUserId:_friendUserId];
    }
    self.dataList = list;
    [dataTableView reloadData];
}

- (void)didSendMessage:(int)resultCode
{
    [inputTextView resignFirstResponder];
    
    if (resultCode == 0) {
        [inputTextView setText:@""];
        self.dataList = [[ChatMessageManager defaultManager] findMessagesByFriendUserId:_friendUserId];
        [dataTableView reloadData];
    } else {
        [self popupMessage:NSLS(@"kSendMessageFailed") title:nil];
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
#define TEXT_FONT_SIZE  (([DeviceDetection isIPAD])?(24):(15))
#define SPACE_Y         (([DeviceDetection isIPAD])?(20):(10))
#define SCREEN_WIDTH    (([DeviceDetection isIPAD])?(768):(320))
#define TEXTVIEW_BORDER_X (([DeviceDetection isIPAD])?(16):(8))
#define TEXTVIEW_BORDER_Y (([DeviceDetection isIPAD])?(16):(8))
#define BUBBLE_TIP_WIDTH   (([DeviceDetection isIPAD])?(20):(10))
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
- (UIView *)createBubbleView:(ChatMessage *)message
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
            contentTextViewFrame = CGRectMake(BUBBLE_NOT_TIP_WIDTH, 0, textSize.width+2*TEXTVIEW_BORDER_X, textSize.height+ 2*TEXTVIEW_BORDER_Y);
        }else {
            contentTextViewFrame = CGRectMake(BUBBLE_TIP_WIDTH, 0, textSize.width+2*TEXTVIEW_BORDER_X, textSize.height+ 2*TEXTVIEW_BORDER_Y);
        }
        UITextView *contentTextView = [[UITextView alloc] initWithFrame:contentTextViewFrame];
        //contentTextView.delegate = self;
        contentTextView.backgroundColor = [UIColor clearColor];
        contentTextView.font = font;
        contentTextView.text = message.text;
        
        //设置气泡的frame
        bubbleImageView.frame = CGRectMake(0.0f, SPACE_Y, contentTextView.frame.size.width+BUBBLE_TIP_WIDTH + BUBBLE_NOT_TIP_WIDTH, contentTextView.frame.size.height);
        [bubbleImageView addSubview:contentTextView];
        [contentTextView release];
        
    }else {
        //设置涂鸦
        NSArray* drawActionList = [ChatMessageUtil unarchiveDataToDrawActionList:message.drawData];
        CGFloat scale = IMAGE_WIDTH_MAX / DRAW_VEIW_FRAME.size.width;
        ShowDrawView *thumbImageView = [self createShowDrawView:drawActionList scale:scale];
        CGFloat multiple = thumbImageView.frame.size.height/thumbImageView.frame.size.width;
        if (fromSelf){
            thumbImageView.frame = CGRectMake(BUBBLE_NOT_TIP_WIDTH + IMAGE_BORDER_X, IMAGE_BORDER_Y, IMAGE_WIDTH_MAX, multiple * IMAGE_WIDTH_MAX );
        }else {
            thumbImageView.frame = CGRectMake(BUBBLE_TIP_WIDTH + IMAGE_BORDER_X, IMAGE_BORDER_Y, IMAGE_WIDTH_MAX, multiple *IMAGE_WIDTH_MAX);
        }
        
        //设置气泡的frame
        bubbleImageView.frame = CGRectMake(0.0f, SPACE_Y, thumbImageView.frame.size.width+BUBBLE_TIP_WIDTH + BUBBLE_NOT_TIP_WIDTH + 2*IMAGE_BORDER_X, thumbImageView.frame.size.height + 2*IMAGE_BORDER_Y);
        [bubbleImageView addSubview:thumbImageView];
    }
    
    
    //设置returnView的frame
    if (fromSelf) {
        returnView.frame = CGRectMake(SCREEN_WIDTH-bubbleImageView.frame.size.width, 0, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height + SPACE_Y);
    }else{
        returnView.frame = CGRectMake(0, 0, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height + SPACE_Y);
    }
    
    [returnView addSubview:bubbleImageView];
    [bubbleImageView release];
    return returnView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *message = (ChatMessage *)[dataList objectAtIndex:indexPath.row];
    UIView *view = [self createBubbleView:message];
    return view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"chatDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ChatMessage *message = (ChatMessage *)[dataList objectAtIndex:indexPath.row];
    UIView *view = [self createBubbleView:message];
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:view];
    
    return cell;
}


- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickGraffitiButton:(id)sender {

    OfflineDrawViewController *odc = [[OfflineDrawViewController alloc] initWithTargetType:TypeGraffiti delegate:self];
    self.offlineDrawViewController = odc;
    [odc release];
    
    PPDebug(@"offlineDrawViewController:%d",[_offlineDrawViewController retainCount]);
    
    [self.view addSubview:_offlineDrawViewController.view];
    CGRect frame = _offlineDrawViewController.view.frame;
    _offlineDrawViewController.view.frame = CGRectMake(0, self.view.frame.size.height, frame.size.width, frame.size.height);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    _offlineDrawViewController.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [UIImageView commitAnimations]; 
    
    [inputTextView resignFirstResponder];
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

- (IBAction)clickSendButton:(id)sender {
    [[ChatService defaultService] sendMessage:self 
                                 friendUserId:_friendUserId 
                                         text:inputTextView.text 
                               drawActionList:nil];
}


- (void)handleSingleTapFrom:(UITapGestureRecognizer*)recognizer {
    [inputTextView resignFirstResponder];
}


#pragma mark  - super Keyboard Methods
- (void)keyboardDidShowWithRect:(CGRect)keyboardRect
{
    CGRect frame = CGRectMake(0, 460 - keyboardRect.size.height - inputBackgroundView.frame.size.height, inputBackgroundView.frame.size.width, inputBackgroundView.frame.size.height);
    
    //[UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:0.1];
    inputBackgroundView.frame = frame;
    //[UIImageView commitAnimations]; 
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self downInputView];
}


#pragma mark - OfflineDrawDelegate
- (void)didClickBack
{
    [self hideGraffitiView];
}

- (void)didClickSubmit:(NSArray *)drawActionList
{
    [self hideGraffitiView];
  
    [[ChatService defaultService] sendMessage:self 
                                 friendUserId:_friendUserId 
                                         text:nil 
                               drawActionList:drawActionList];
}

#pragma mark - custom methods
- (void)downInputView
{
    CGRect frame = CGRectMake(0, 460 - inputBackgroundView.frame.size.height, inputBackgroundView.frame.size.width, inputBackgroundView.frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    inputBackgroundView.frame = frame;
    [UIImageView commitAnimations];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self downInputView];
}

#define INPUT_TEXT_WIDTH_MAX    170
#define INPUT_TEXT_HEIGHT_MAX   90
#define TEXTTVIEW_HEIGHT_MIN    31
#define INPUTBACKGROUNDVIEW_HEIGHT_MIN  37
- (void)textViewDidChange:(UITextView *)textView
{
    UIFont *font = textView.font;
    CGSize size = [textView.text sizeWithFont:font constrainedToSize:CGSizeMake(INPUT_TEXT_WIDTH_MAX, INPUT_TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    PPDebug(@"%f %f %f", textView.frame.size.height, size.height, size.width);
    
    CGRect oldFrame = textView.frame;
    CGFloat newHeight = size.height + 16;
    CGRect oldBackgroundFrame = inputBackgroundView.frame;
    
    if (newHeight >= TEXTTVIEW_HEIGHT_MIN) {
        
        CGFloat addHeight = newHeight - oldFrame.size.height;
        [textView setFrame: CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, newHeight)];
        [inputBackgroundView setFrame:CGRectMake(oldBackgroundFrame.origin.x, oldBackgroundFrame.origin.y-addHeight, oldBackgroundFrame.size.width, oldBackgroundFrame.size.height+addHeight)];
    }else {
        [textView setFrame: CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, TEXTTVIEW_HEIGHT_MIN)];
        CGFloat delHeight = oldBackgroundFrame.size.height - INPUTBACKGROUNDVIEW_HEIGHT_MIN;
        [inputBackgroundView setFrame:CGRectMake(oldBackgroundFrame.origin.x, oldBackgroundFrame.origin.y+delHeight, oldBackgroundFrame.size.width, INPUTBACKGROUNDVIEW_HEIGHT_MIN)];
    }
}

@end
