//
//  ChatDetailController.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatDetailController.h"
#import "DeviceDetection.h"
#import "PPMessage.h"
#import "PPMessageManager.h"
#import "UserManager.h"
#import "DrawConstants.h"
#import "DrawDataService.h"
#import "DrawAction.h"
#import "GameBasic.pb.h"
#import "ShowDrawView.h"
#import "ShareImageManager.h"
#import "ReplayGraffitiController.h"
#import "DrawAppDelegate.h"
#import "ChatDetailCell.h"
#import "CommonMessageCenter.h"
#import "DrawUserInfoView.h"
#import "DiceUserInfoView.h"
#import "GameNetworkConstants.h"
#import "ChatListController.h"
#import "MessageStat.h"
#import "CommonUserInfoView.h"

@interface ChatDetailController ()
{
    MessageStat *_messageStat;
    NSMutableArray *_messageList;
    CGFloat _panelHeight;
    
    NSInteger _asIndexDelete;
    NSInteger _asIndexReplay;
    NSInteger _asIndexCopy;
    NSInteger _asIndexResend;
//    BOOL _noData;
    BOOL _showingActionSheet;
}

@property (retain, nonatomic) PPMessage *selectedMessage;
@property (retain, nonatomic) MessageStat *messageStat;
@property (retain, nonatomic) NSMutableArray *messageList;
- (IBAction)clickBack:(id)sender;
- (NSInteger)loadNewDataCount;
- (NSInteger)loadMoreDataCount;
- (void)tableViewScrollToTop;
- (void)tableViewScrollToBottom;
- (BOOL)messageShowTime:(PPMessage *)message;
- (void)appendMessageList:(NSArray *)list;
@end


#define TABLEVIEW_HEIGHT (ISIPAD ? 819 : 368)


@implementation ChatDetailController
@synthesize titleLabel;
@synthesize inputBackgroundView;
@synthesize inputTextView;
@synthesize inputTextBackgroundImage;
@synthesize refreshButton;
@synthesize selectedMessage = _selectedMessage;
@synthesize messageStat = _messageStat;
@synthesize messageList = _messageList;
@synthesize delegate = _delegate;

- (void)reloadTableView
{
    NSArray *temp = [self.messageList sortedArrayUsingComparator:^(id obj1,id obj2){
        NSDate *date1 = [(PPMessage *)obj1 createDate];
        NSDate *date2 = [(PPMessage *)obj2 createDate];
        if ([date1 timeIntervalSince1970] > [date2 timeIntervalSince1970]) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
        
    } ];
    self.messageList = [NSMutableArray arrayWithArray:temp];
    temp = nil;
    [[self dataTableView] reloadData];
}

- (NSString *)fid
{
    return self.messageStat.friendId;
}

- (void)appendMessageList:(NSArray *)list
{
    if ([list count] == 0) {
        return;
    }
    if ([_messageList count] == 0) {
        [_messageList addObjectsFromArray:list];
        return;
    }
    NSMutableArray *repeatList = [NSMutableArray array];
    for (PPMessage *nMessage in list) {
        for (PPMessage *message in _messageList) {
            if ([message.messageId isEqualToString:nMessage.messageId]) {
                [repeatList addObject:nMessage];
                break;
            }
        }
    }
    PPDebug(@"repeatList count = %d", [repeatList count]);
    [_messageList addObjectsFromArray:list];
    [_messageList removeObjectsInArray:repeatList];
}

#define GROUP_INTERVAL 60 * 5
- (BOOL)messageShowTime:(PPMessage *)message
{
    NSInteger index = [self.messageList indexOfObject:message];
    if (index == 0) {
        return YES;
    }
    PPMessage *lastMessage = [self.messageList objectAtIndex:index - 1];
    
    NSInteger timeValue = [[message createDate] timeIntervalSince1970];
    NSInteger lastTime = [[lastMessage createDate] timeIntervalSince1970];
    if (timeValue - lastTime >= GROUP_INTERVAL) {
        return YES;
    }
    return NO;
}
- (void)dealloc {
    PPDebug(@"%@ dealloc",self);
    PPRelease(titleLabel);
    PPRelease(inputTextView);
    PPRelease(inputBackgroundView);
    PPRelease(inputTextBackgroundImage);
    PPRelease(refreshButton);
    PPRelease(_selectedMessage);
    PPRelease(_messageStat);
    PPRelease(_messageList);
    [super dealloc];
}


- (id)initWithMessageStat:(MessageStat *)messageStat
{
    self = [super init];
    if (self) {
        self.messageStat = messageStat;
        _messageList = [[NSMutableArray alloc] init];
    }
    PPDebug(@"%@<initWithMessageStat>", self);
    return self;
}

- (void)initViews
{
    self.titleLabel.text = self.messageStat.friendNickName;
    inputTextView.returnKeyType = UIReturnKeySend;
    [self.inputTextBackgroundImage setImage:
     [[ShareImageManager defaultManager] inputImage]];
}



#pragma mark read && write data into files

- (void)initListWithLocalData
{
    NSArray* list = [PPMessageManager messageListForFriendId:self.fid];
    PPDebug(@"<initListWithLocalData> list count = %d", [list count]);
    if ([list count] != 0) {
        [self appendMessageList:list];
        [self reloadTableView];
        [self tableViewScrollToBottom];
        
        //reSend the sendding messages...
        for (PPMessage *message in list) {
            if (message.status == MessageStatusSending) {
                [[ChatService defaultService] sendMessage:message delegate:self];
            }
        }
    }
}

- (void)bgRunBlock:(dispatch_block_t)block
{
    block();
    
//    dispatch_queue_t queue = dispatch_get_main_queue(); //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    if (queue) {
//        dispatch_async(queue, block);
//    }
}
- (void)bgSaveMessageList
{
    [self bgRunBlock:^{
        [PPMessageManager saveFriend:self.fid messageList:self.messageList];
    }];
}


- (void)viewDidLoad
{
    [self setSupportRefreshHeader:YES];
    [super viewDidLoad];
    [self initViews];
    [self initListWithLocalData];
    [self loadNewMessage];
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setInputBackgroundView:nil];
    [self setInputTextView:nil];
    [self setInputTextBackgroundImage:nil];
    [self setRefreshButton:nil];
    [self setMessageList:nil];
    [super viewDidUnload];
}


- (void)viewDidAppear:(BOOL)animated
{
    
    DrawAppDelegate *drawAppDelegate = (DrawAppDelegate *)[[UIApplication sharedApplication] delegate];
    drawAppDelegate.chatDetailController = self;
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self bgSaveMessageList];
    
    DrawAppDelegate *drawAppDelegate = (DrawAppDelegate *)[[UIApplication sharedApplication] delegate];
    drawAppDelegate.chatDetailController = nil;
    [super viewDidDisappear:animated];
}


#pragma mark - ChatServiceDelegate methods
- (void)didGetMessages:(NSArray *)list 
               forward:(BOOL)forward
            resultCode:(int)resultCode
{
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];
    if (resultCode == 0) {
        if (!forward && [list count] < [self loadMoreDataCount]) {
            [self.refreshHeaderView setHidden:YES];
            self.dataTableView.tableHeaderView.hidden = YES;
        }
        if ([list count] == 0) {
            return;
        }
        [self appendMessageList:list];
        [self reloadTableView];
        if (forward) {
            [self tableViewScrollToBottom];
        }else{
            [self tableViewScrollToTop];
        }
        
        if (forward) {
            [[ChatService defaultService] sendHasReadMessage:self friendUserId:self.fid];
            self.messageStat.numberOfNewMessage = 0;
        }
        
    }else{
        PPDebug(@"<didGetMessages>, fail! resultCode = %d",resultCode);
    }
}


- (void)didSendMessage:(PPMessage *)message resultCode:(int)resultCode
{
    [self.dataTableView reloadData];
    if (resultCode == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(didMessageStat:createNewMessage:)]) {
            [_delegate didMessageStat:self.messageStat createNewMessage:message];
        }
        self.inputTextView.text = nil;
        [self textViewDidChange:self.inputTextView];
    } else {
        
    }
}


#pragma mark - custom methods
- (void)scrollToBottom:(BOOL)animated
{
    if ([_messageList count]>0) {
        NSIndexPath *indPath = [NSIndexPath indexPathForRow:[_messageList count]-1 inSection:0];
        [dataTableView scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}



- (void)showGraffitiView
{
    OfflineDrawViewController *odc = [[OfflineDrawViewController alloc] initWithTargetType:TypeGraffiti delegate:self];
    [self presentModalViewController:odc animated:YES];
    [odc release];
}



#pragma mark - UITableViewDelegate or UITableViewDataSource methods

- (PPMessage *)messageOfIndex:(NSInteger)index
{
    if (index >= 0 && index < [_messageList count]) {
        return [_messageList objectAtIndex:index];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messageList count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPMessage *message = [self messageOfIndex:indexPath.row];
    BOOL flag = [self messageShowTime:message];
    return [ChatDetailCell getCellHeight:message showTime:flag];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPMessage *message = [self messageOfIndex:indexPath.row];
    BOOL isReceive = (message.sourceType != SourceTypeSend);
    NSString *indentifier = [ChatDetailCell getCellIdentifierIsReceive:isReceive];
    ChatDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ChatDetailCell createCell:self isReceive:isReceive];
    }
    BOOL flag = [self messageShowTime:message];
    [cell setCellWithMessageStat:self.messageStat 
                         message:message
                       indexPath:indexPath 
                        showTime:flag];
    return cell;
}



#pragma mark - button action
- (IBAction)clickBack:(id)sender 
{
    NSArray *viewControllers = self.navigationController.viewControllers;
//    PPDebug(@"<clickBack>viewControllers = %@",viewControllers);
    for (UIViewController* controller in viewControllers){
        if ([controller isKindOfClass:[ChatListController class]]){
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickGraffitiButton:(id)sender 
{
    [self showGraffitiView];
//    [inputTextView resignFirstResponder];
}

//设定view底部，整个view往上移位
- (void)updateInputPanel:(UIView *)view withBottomLine:(CGFloat)yLine 
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGPoint origin = CGPointMake(0, 0);
    CGSize size = view.frame.size;
    origin.y = yLine - size.height;
    view.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
    [UIView commitAnimations];
}


//设定view底部，整个view保持起始点不变，整个view往上缩
- (void)updateTableView:(UITableView *)tableView withBottomLine:(CGFloat)yLine
{
    CGRect frame = tableView.frame;
    frame.size.height = yLine - CGRectGetMinY(frame);
    tableView.frame = frame;
    [tableView reloadData];
    [self tableViewScrollToBottom];
//    [self performSelector:@selector(tableViewScrollToBottom) withObject:nil afterDelay:0.2];
}

//设定view底部，整个view保持起始点不变，整个view膨胀
- (void)spanView:(UIView *)view 
  withBottomLine:(CGFloat)yLine 
          viewHeight:(CGFloat)viewHeight
{
    CGPoint origin = view.frame.origin;
    CGSize size = view.frame.size;
    size.height = viewHeight;
    origin.y = yLine - size.height;
    
    view.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
}

#define STATUS_BAR_HEIGHT 20.0f

- (void)clickMaskView:(UIButton *)view
{
    [view removeFromSuperview];
    [self.inputTextView resignFirstResponder];
}
- (void)addMaskView
{
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.frame = self.dataTableView.frame;
    [self.view addSubview:view];
    [view addTarget:self action:@selector(clickMaskView:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - super methods: keyboard show and hide


- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
{
    PPDebug(@"<keyboardWillShowWithRect> keyboardRect = %@, receiver = %@",NSStringFromCGRect(keyboardRect), self);
    
    CGFloat yLine = CGRectGetMaxY(self.view.frame) - CGRectGetHeight(keyboardRect);
    [self updateInputPanel:self.inputBackgroundView withBottomLine:yLine];
    yLine -= CGRectGetHeight(self.inputBackgroundView.frame);
    [self updateTableView:self.dataTableView withBottomLine:yLine];
    [self addMaskView];
}

- (void)keyboardWillHideWithRect:(CGRect)keyboardRect
{
    PPDebug(@"<keyboardWillHideWithRect> keyboardRect = %@",NSStringFromCGRect(keyboardRect));
    CGFloat yLine = [[UIScreen mainScreen] bounds].size.height;
    [self updateInputPanel:self.inputBackgroundView withBottomLine:yLine - STATUS_BAR_HEIGHT];
    
    yLine = self.inputBackgroundView.frame.origin.y;
    [self updateTableView:self.dataTableView withBottomLine:yLine];

}


#pragma mark sendMessage

- (void)constructMessage:(PPMessage *)message
{
    [message setFriendId:_messageStat.friendId];
    [message setStatus:MessageStatusSending];
    [message setSourceType:SourceTypeSend];
    [message setCreateDate:[NSDate date]];    
}

- (void)sendTextMessage:(NSString *)text
{
    TextMessage *message = [[TextMessage alloc] init];
    [self constructMessage:message];
    [message setText:text];
    [message setMessageType:MessageTypeText];
    [[ChatService defaultService] sendMessage:message delegate:self];
    [self.messageList addObject:message];
    [message release];
    [self.dataTableView reloadData];
    [self tableViewScrollToBottom];
}
- (void)sendDrawMessage:(NSMutableArray *)drawActionList
{
    DrawMessage *message = [[[DrawMessage alloc] init] autorelease];
    [self constructMessage:message];
    [message setMessageType:MessageTypeDraw];
    [message setDrawActionList:drawActionList];
    [[ChatService defaultService] sendMessage:message delegate:self];    
    [self.messageList addObject:message];
    [self.dataTableView reloadData];
    [self tableViewScrollToBottom];
}


#pragma mark - OfflineDrawDelegate methods
- (void)didControllerClickBack:(OfflineDrawViewController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
}
- (void)didController:(OfflineDrawViewController *)controller
     submitActionList:(NSMutableArray *)drawActionList
            drawImage:(UIImage *)drawImage
{
    [controller dismissModalViewControllerAnimated:YES];
    [self sendDrawMessage:drawActionList];
    [self tableViewScrollToBottom];
}


- (void)showFriendProfile:(MyFriend *)aFriend
{
    [CommonUserInfoView showFriend:aFriend inController:self needUpdate:YES canChat:YES];
}

#pragma mark textview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text  
{  
    if ([text isEqualToString:@"\n"]) {  
        if ([textView.text length] != 0) {
            [self sendTextMessage:textView.text];
            [self tableViewScrollToBottom];
            textView.text = nil;            
        }
        return NO;  
    }  
    return YES;  
}


#define TEXT_VIEW_MAX_HEIGHT (([DeviceDetection isIPAD])?(300.0):(120.0))
#define TEXT_VIEW_MIN_HEIGHT (([DeviceDetection isIPAD])?(50.0):(32.0))
#define SPACE_BG_TEXT (([DeviceDetection isIPAD])?(9.0):(3.0))
#define SPACE_PANEL_BG (([DeviceDetection isIPAD])?(11.0):(5.0))
- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    CGSize size = [text sizeWithFont:textView.font 
                   constrainedToSize:CGSizeMake(textView.frame.size.width, TEXT_VIEW_MAX_HEIGHT) 
                       lineBreakMode:UILineBreakModeWordWrap];
    CGFloat textHeight = (size.height < TEXT_VIEW_MIN_HEIGHT) ? TEXT_VIEW_MIN_HEIGHT : (size.height);
    
    CGFloat panelHeight = textHeight + 2 * (SPACE_PANEL_BG + SPACE_BG_TEXT);
    if (_panelHeight != panelHeight) {
        _panelHeight = panelHeight;
        CGFloat yLine = CGRectGetMaxY(self.inputBackgroundView.frame);
        [self spanView:self.inputBackgroundView withBottomLine:yLine viewHeight:panelHeight];
    }
}


#pragma mark delete chat message

#define ACTION_SHEET_TAG_TEXT 201211021
#define ACTION_SHEET_TAG_DRAW 201211022
#define ACTION_SHEET_TAG_IMAGE 201211023

- (void)resetASIndexesOfMessage:(PPMessage *)message
{
    _asIndexDelete = -1;
    _asIndexCopy = -1;
    _asIndexReplay = -1;
    _asIndexResend = -1;
    NSInteger start = 0;
    _asIndexDelete = start++;
    if (message.messageType == MessageTypeDraw) {
        _asIndexReplay = start++;
    }else if(message.messageType == MessageTypeText){
        _asIndexCopy = start++;
    }
    if (message.status == MessageStatusFail) {
        _asIndexResend = start++;
    }
}

- (void)didDeleteMessages:(NSArray *)messages
               resultCode:(int)resultCode
{
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kDeleteFail") title:nil];
    }else{
        
    }
}

#pragma mark enter replay controller
- (void)enterReplayController:(DrawMessage *)message
{
    ReplayGraffitiController *rg = [[ReplayGraffitiController alloc] initWithDrawActionList:[message drawActionList]];
    [self.navigationController pushViewController:rg animated:YES];
    [rg release];

}
- (void)clickMessage:(PPMessage *)message 
  withDrawActionList:(NSArray *)drawActionList
{
    [self enterReplayController:(DrawMessage *)message];
}

#pragma mark options action.
- (void)didLongClickMessage:(PPMessage *)message
{
    if (_showingActionSheet) {
        return;
    }else{
        _showingActionSheet = YES;
    }
    NSString *otherOperation = nil;
    NSInteger tag = 0;
    switch (message.messageType) {
        case MessageTypeDraw:
            tag = ACTION_SHEET_TAG_DRAW;
            otherOperation = NSLS(@"kReplay");            
            break;
        case MessageTypeText:
            tag = ACTION_SHEET_TAG_TEXT;
            otherOperation = NSLS(@"kCopy");            
            break;
        default:
            return;
    }
    [self resetASIndexesOfMessage:message];
    UIActionSheet *actionSheet = nil;
    if (message.status == MessageStatusFail) {
        actionSheet=  [[UIActionSheet alloc]
                       initWithTitle:NSLS(@"kOpusOperation")
                       delegate:self 
                       cancelButtonTitle:NSLS(@"kCancel") 
                       destructiveButtonTitle:NSLS(@"kDelete") 
                       otherButtonTitles:otherOperation, NSLS(@"kResend"), nil];
        [actionSheet setDestructiveButtonIndex:_asIndexResend];

    }else
    {
       actionSheet=  [[UIActionSheet alloc]
                      initWithTitle:NSLS(@"kOpusOperation")
                      delegate:self 
                      cancelButtonTitle:NSLS(@"kCancel") 
                      destructiveButtonTitle:NSLS(@"kDelete") 
                      otherButtonTitles:otherOperation, nil];
    }
    [actionSheet showInView:self.view];
    actionSheet.tag = tag;
    [actionSheet release];
    _selectedMessage = message;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    _showingActionSheet = NO;
    if (_asIndexDelete == buttonIndex) {
        [[ChatService defaultService] deleteMessage:self
                                      messageList:[NSArray arrayWithObject:_selectedMessage]];
                
        NSInteger row = [self.messageList indexOfObject:_selectedMessage];
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObject:path];
        [self.messageList removeObject:_selectedMessage];
        [self.dataTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
    }else if(_asIndexCopy == buttonIndex && _selectedMessage.messageType == MessageTypeText)
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _selectedMessage.text;         
    }else if(_asIndexReplay == buttonIndex && _selectedMessage.messageType == MessageTypeDraw){
        [self enterReplayController:(DrawMessage *)_selectedMessage];
    }else if(_asIndexResend == buttonIndex){
        [[ChatService defaultService] sendMessage:_selectedMessage delegate:self];
        [_selectedMessage setCreateDate:[NSDate date]];
        [_selectedMessage setStatus:MessageStatusSending];
        [self reloadTableView];
        [self tableViewScrollToBottom];
    }
    _selectedMessage = nil;
}



#pragma mark load more chat list.

- (NSInteger)loadNewDataCount
{
    return 50;
}
- (NSInteger)loadMoreDataCount
{
    return 10;
}


- (NSString *)lastMessageId
{
    NSInteger count = [_messageList count] - 1;
    for (int i = count; i >= 0; --i) {
        PPMessage *message = [_messageList objectAtIndex:i];
        if (message.isMessageSentOrReceived) {
            return message.messageId;
        }
    }
    return nil;
}
- (NSString *)firstMessageId
{
    for (PPMessage *message in _messageList) {
        if (message.isMessageSentOrReceived) {
            return message.messageId;
        }
    }
    return nil;    
}
- (void)loadNewMessage
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[ChatService defaultService] getMessageList:self 
                                    friendUserId:self.fid
                                 offsetMessageId:self.lastMessageId 
                                         forward:YES 
                                           limit:[self loadNewDataCount]];
}
- (void)loadMoreMessage
{
    [[ChatService defaultService] getMessageList:self 
                                    friendUserId:self.fid
                                 offsetMessageId:self.firstMessageId 
                                         forward:NO 
                                           limit:[self loadMoreDataCount]];
}

- (void)tableViewScrollToTop
{
    if ([self.messageList count] > 0) {
        NSInteger row = 0;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.dataTableView scrollToRowAtIndexPath:indexPath 
                                  atScrollPosition:UITableViewScrollPositionBottom 
                                          animated:YES];        
    }    
}
- (void)tableViewScrollToBottom
{
    if ([self.messageList count] > 0) {
        NSInteger row = [self.messageList count] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.dataTableView scrollToRowAtIndexPath:indexPath 
                                  atScrollPosition:UITableViewScrollPositionBottom 
                                          animated:YES];        
    }
}


- (void)reloadTableViewDataSource
{
    if (self.refreshHeaderView.hidden) {
        return;
    }
    [self loadMoreMessage];
}

@end
