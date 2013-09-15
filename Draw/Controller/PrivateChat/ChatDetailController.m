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
#import "DrawAppDelegate.h"
#import "ChatDetailCell.h"
#import "CommonMessageCenter.h"
//#import "DrawUserInfoView.h"
//#import "DiceUserInfoView.h"
#import "GameNetworkConstants.h"
#import "ChatListController.h"
#import "MessageStat.h"
#import "CommonUserInfoView.h"
#import "DrawPlayer.h"
#import "CanvasRect.h"
#import "StringUtil.h"
#import "MKBlockActionSheet.h"
#import "GameApp.h"
#import "WordFilterService.h"

@interface ChatDetailController ()
{
//    MessageStat *_messageStat;
//    NSMutableArray *_messageList;
    CGFloat _panelHeight;
    
    NSInteger _asIndexDelete;
    NSInteger _asIndexReplay;
    NSInteger _asIndexLookLarge;
    NSInteger _asIndexShowLocation;
    NSInteger _asIndexCopy;
    NSInteger _asIndexResend;
//    BOOL _noData;
    BOOL _showingActionSheet;
}

@property (retain, nonatomic) PPMessage *selectedMessage;
@property (retain, nonatomic) MessageStat *messageStat;
@property (retain, nonatomic) NSArray *messageList;
@property (retain, nonatomic) PhotoDrawSheet *photoDrawSheet;
- (IBAction)clickBack:(id)sender;
- (NSInteger)loadNewDataCount;
- (NSInteger)loadMoreDataCount;
- (void)tableViewScrollToTop;
- (void)tableViewScrollToBottom:(BOOL)animated;
- (BOOL)messageShowTime:(PPMessage *)message row:(int)row;
//- (void)appendMessageList:(NSArray *)list;
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
//@synthesize messageList = _messageList;
@synthesize delegate = _delegate;

- (void)reloadTableView
{
    PPDebug(@"realod chat detail message table view");
    self.messageList = [[PPMessageManager defaultManager] getMessageList:self.fid];
    [[self dataTableView] reloadData];
}

- (NSString *)fid
{
    return self.messageStat.friendId;
}

#define GROUP_INTERVAL 60 * 5
- (BOOL)messageShowTime:(PPMessage *)message row:(int)row
{
    if (row == 0 || (row-1) < ([_messageList count] -1) ){
        return YES;
    }
    
    PPMessage *lastMessage = [_messageList objectAtIndex:(row - 1)];
    
    NSInteger timeValue = [[message createDate] timeIntervalSince1970];
    NSInteger lastTime = [[lastMessage createDate] timeIntervalSince1970];
    if (timeValue - lastTime >= GROUP_INTERVAL) {
        return YES;
    }
    return NO;
}
- (void)dealloc {
    
    [self unregisterAllNotifications];
    
    PPDebug(@"%@ dealloc",self);
    PPRelease(_loadingActivityView);
    PPRelease(titleLabel);
    PPRelease(inputTextView);
    PPRelease(inputBackgroundView);
    PPRelease(inputTextBackgroundImage);
    PPRelease(refreshButton);
    PPRelease(_selectedMessage);
    PPRelease(_messageStat);
    PPRelease(_messageList);
    PPRelease(_photoDrawSheet);
    PPRelease(_locateButton);
    PPRelease(imageUploader);
    [super dealloc];
}


- (id)initWithMessageStat:(MessageStat *)messageStat
{
    self = [super init];
    if (self) {
        self.messageStat = messageStat;
        self.messageList = [[PPMessageManager defaultManager] getMessageList:messageStat.friendId];
//        _messageList = [[NSMutableArray alloc] init];
    }
    return self;
}

#define CHAT_PAGE_BG_KEY @"chat_bg.png"

- (ChangeAvatar*)backgroundPicker
{
    if (imageUploader == nil) {
        imageUploader = [[ChangeAvatar alloc] init];
        imageUploader.autoRoundRect = NO;
        imageUploader.isCompressImage = NO;
    }
    return imageUploader;
}


- (IBAction)clickChangeBGButton:(id)sender {
    
    [[self backgroundPicker] showSelectionView:self
                                      delegate:nil
                            selectedImageBlock:^(UIImage *image) {

                                if ([[UserManager defaultManager] setPageBg:image forKey:CHAT_PAGE_BG_KEY]) {
                                    POSTMSG(NSLS(@"kCustomChatBgSucc"));
                                }
                                [self updateBG];
                            }
     
                            didSetDefaultBlock:^{

                                if ([[UserManager defaultManager] resetPageBgforKey:CHAT_PAGE_BG_KEY]) {
                                    POSTMSG(NSLS(@"kResetCustomChatBgSucc"));
                                }
                                [self updateBG];
                            }
                                         title:NSLS(@"kCustomChatBg")
                               hasRemoveOption:YES
                                  canTakePhoto:YES
                             userOriginalImage:YES];
    
}

- (void)initViews
{
    self.titleLabel.text = self.messageStat.friendNickName;
    inputTextView.returnKeyType = UIReturnKeySend;
    [self.inputTextBackgroundImage setImage:
     [[ShareImageManager defaultManager] inputImage]];

    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:self.messageStat.friendNickName];
    [titleView setRightButtonAsRefresh];
    [titleView setTarget:self];
    [titleView setRightButtonSelector:@selector(clickRefresh:)];
    [self.view sendSubviewToBack:titleView];

}



#pragma mark read && write data into files

#define RECT_INPUT_TEXT_VIEW        ([DeviceDetection isIPAD] ? CGRectMake(167, 20, 579, 50) : CGRectMake(75, 8, 232, 30))
#define RECT_INPUT_TEXT_BACKGROUND   ([DeviceDetection isIPAD] ? CGRectMake(158, 11, 597, 68) : CGRectMake(69, 5, 245, 36))

- (void)updateLocateButton
{
    if ([GameApp showLocateButton] == NO) {
        self.locateButton.hidden = YES;
        self.inputTextView.frame = RECT_INPUT_TEXT_VIEW;
        self.inputTextBackgroundImage.frame = RECT_INPUT_TEXT_BACKGROUND;
    } else {
        
        [[UserService defaultService] getUserInfo:_messageStat.friendId resultBlock:^(int resultCode, PBGameUser *user, int relation) {
            if (resultCode == 0){
                
                if (relation == RelationTypeFriend) {
                     self.locateButton.enabled = YES;
                } else {
                     self.locateButton.enabled = NO;
                }
            }
        }];
    }
}

- (void)registerAllChatNotification
{
    [self registerNotificationWithName:NOTIFICATION_MESSAGE_SENT usingBlock:^(NSNotification *note) {
        
        NSDictionary* userInfo = [note userInfo];
        NSNumber* resultCode = [userInfo objectForKey:KEY_USER_INFO_RESULT_CODE];
        [self didSendMessage:nil resultCode:[resultCode intValue]];
    }];
    
    [self registerNotificationWithName:NOTIFICATION_MESSAGE_SENDING usingBlock:^(NSNotification *note) {
        [self reloadTableView];
    }];
    
    [self registerNotificationWithName:NOTIFICATION_MESSAGE_DELETE usingBlock:^(NSNotification *note) {
        [self reloadTableView];
    }];
    
    [self registerNotificationWithName:NOTIFICATION_MESSAGE_LOAD usingBlock:^(NSNotification *note) {
        
        NSDictionary* userInfo = [note userInfo];
        NSNumber* resultCode = [userInfo objectForKey:KEY_USER_INFO_RESULT_CODE];
        NSNumber* forward = [userInfo objectForKey:KEY_USER_INFO_FORWARD];
        NSNumber* insertMiddle = [userInfo objectForKey:KEY_USER_INFO_INSERTMIDDLE];
        
        [self didGetMessages:nil forward:[forward boolValue] insertMiddle:[insertMiddle intValue] resultCode:[resultCode intValue]];        
        [self clearTitleForLoading];
    }];
}
#define BG_IMAGE_TAG 21233

- (void)updateBG
{
    UIImage *image = [[UserManager defaultManager] pageBgForKey:@"chat_bg.png"];
    UIImageView *iv = (id)[self.view reuseViewWithTag:BG_IMAGE_TAG
                                            viewClass:[UIImageView class]
                                                frame:self.dataTableView.frame];
    
    if (image) {
        iv.contentMode = UIViewContentModeScaleAspectFill;
    }else{
        iv.contentMode = UIViewContentModeScaleToFill;
        image = [[ShareImageManager defaultManager] drawBGImage];
    }
    [iv setImage:image];
    [self.view insertSubview:iv belowSubview:[CommonTitleView titleView:self.view]];

}

- (void)viewDidLoad
{
    self.messageList = [[PPMessageManager defaultManager] getMessageList:self.fid];
    
    [self setSupportRefreshHeader:YES];
    [super viewDidLoad];

    [self initViews];
    self.unReloadDataWhenViewDidAppear = YES;
    [self updateLocateButton];
    
    [self updateBG];
    [self scrollToBottom:NO];
    
    self.inputBackgroundView.backgroundColor = COLOR_BROWN;
    self.inputTextView.textColor = COLOR_BROWN;

    // make this to avoid message list changed by receiving notification
    [self performSelector:@selector(loadNewMessageWhileLaunch) withObject:nil afterDelay:0.1f];
}

- (void)loadNewMessageWhileLaunch
{
    [self registerAllChatNotification];
    [self loadNewMessage:YES];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setInputBackgroundView:nil];
    [self setInputTextView:nil];
    [self setInputTextBackgroundImage:nil];
    [self setRefreshButton:nil];
    [self setMessageList:nil];
    [self setLocateButton:nil];
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
//    PPRelease(_delegate);
    
//    [self bgSaveMessageList];
    
    DrawAppDelegate *drawAppDelegate = (DrawAppDelegate *)[[UIApplication sharedApplication] delegate];
    drawAppDelegate.chatDetailController = nil;
    [super viewDidDisappear:animated];
}


#pragma mark - ChatServiceDelegate methods
- (void)didGetMessages:(NSArray *)list
               forward:(BOOL)forward
          insertMiddle:(BOOL)insertMiddle
            resultCode:(int)resultCode
{
    
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];
    if (resultCode == 0) {
        self.messageList = [[PPMessageManager defaultManager] getMessageList:self.fid];
        list = self.messageList;

        if (!forward && [list count] < [self loadMoreDataCount]) {
            [self.refreshHeaderView setHidden:YES];
            self.dataTableView.tableHeaderView.hidden = YES;
        }
        if ([list count] == 0) {
            return;
        }

        [self reloadTableView];
        if (forward || insertMiddle) {
            [self tableViewScrollToBottom:YES];
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
    if (resultCode == 0) {
//        if (_delegate && [_delegate respondsToSelector:@selector(didMessageStat:createNewMessage:)]) {
//            [_delegate didMessageStat:self.messageStat createNewMessage:message];
//        }
        self.inputTextView.text = nil;
        [self textViewDidChange:self.inputTextView];
    } else {
        
    }

    [self reloadTableView];
    [self scrollToBottom:YES];
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
    PPDebug(@"<numberOfRowsInSection> = %d", [_messageList count]);
    return [_messageList count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPDebug(@"<heightForRowAtIndexPath> index = %d", indexPath.row);
    PPMessage *message = [self messageOfIndex:indexPath.row];
    BOOL flag = [self messageShowTime:message row:indexPath.row];
    CGFloat height = [ChatDetailCell getCellHeight:message showTime:flag];
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPMessage *message = [self messageOfIndex:indexPath.row];
    
    
    NSString *indentifier = [ChatDetailCell getCellIdentifier];
    ChatDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ChatDetailCell createCell:self];        
    }
    BOOL flag = [self messageShowTime:message row:indexPath.row];
    [cell setCellWithMessageStat:self.messageStat
                         message:message
                       indexPath:indexPath 
                        showTime:flag];
    return cell;
}



#pragma mark - button action
- (IBAction)clickBack:(id)sender 
{
    [self unregisterAllNotifications];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
//    PPDebug(@"<clickBack>viewControllers = %@",viewControllers);
    for (UIViewController* controller in viewControllers){
        if ([controller isKindOfClass:[ChatListController class]]){
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    self.messageList = nil;    
}

- (IBAction)clickRefresh:(id)sender {
    [self loadNewMessage:YES];
}

- (IBAction)clickGraffitiButton:(id)sender 
{
    [self showGraffitiView];
//    [inputTextView resignFirstResponder];
}

- (IBAction)clickLocateButton:(id)sender {
    UserLocationController *controller = [[UserLocationController alloc] initWithType:LocationTypeFind isMe:YES latitude:0 longitude:0 messageType:MessageTypeLocationRequest reqMessageId:nil];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)clickPhotoButton:(id)sender {
    self.photoDrawSheet = [PhotoDrawSheet createSheetWithSuperController:self];
    _photoDrawSheet.delegate = self;
    [_photoDrawSheet showSheet];
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
    [self tableViewScrollToBottom:YES];
//    [self performSelector:@selector(tableViewScrollToBottom:YES) withObject:nil afterDelay:0.2];
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

#pragma mark - OfflineDrawDelegate methods
- (void)didControllerClickBack:(OfflineDrawViewController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)didController:(OfflineDrawViewController *)controller
     submitActionList:(NSMutableArray *)drawActionList
           canvasSize:(CGSize)size
            drawImage:(UIImage *)drawImage
{
    [controller dismissModalViewControllerAnimated:YES];
    [[ChatService defaultService]  sendDrawMessage:drawActionList canvasSize:size friendUserId:self.fid];
    [self tableViewScrollToBottom:YES];
}

- (void)didController:(OfflineDrawViewController *)controller submitImage:(UIImage *)image
{
    [controller dismissModalViewControllerAnimated:YES];
    [[ChatService defaultService]  sendImage:image friendUserId:self.fid];
    [self tableViewScrollToBottom:YES];
}


#pragma mark textview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text  
{  
    if ([text isEqualToString:@"\n"]) {  
        if ([textView.text length] != 0) {

            if ([[WordFilterService defaultService] checkForbiddenWord:textView.text]){
                return YES;
            }            
            
            [[ChatService defaultService] sendTextMessage:textView.text friendUserId:self.fid];
            [self tableViewScrollToBottom:YES];
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
#define ACTION_SHEET_TAG_LOCATION_REQUEST    201211024
#define ACTION_SHEET_TAG_LOCATION_RESPONSE   201211025


- (void)resetASIndexesOfMessage:(PPMessage *)message
{
    _asIndexDelete = -1;
    _asIndexCopy = -1;
    _asIndexReplay = -1;
    _asIndexLookLarge = -1;
    _asIndexShowLocation = -1;
    _asIndexResend = -1;
    NSInteger start = 0;
    _asIndexDelete = start++;
    if (message.messageType == MessageTypeDraw) {
        _asIndexReplay = start++;
    }else if(message.messageType == MessageTypeText){
        _asIndexCopy = start++;
    }else if(message.messageType == MessageTypeImage){
        _asIndexLookLarge = start ++;
    }else if(message.messageType == MessageTypeLocationRequest){
        _asIndexShowLocation = start ++;
    }else if(message.messageType == MessageTypeLocationResponse){
        if ([(LocationReplyMessage *)message replyResult] == ACCEPT_ASK_LOCATION) {
            _asIndexShowLocation = start ++;
        }
    }
    if (message.status == MessageStatusFail) {
        _asIndexResend = start++;
    }
}

- (void)didDeleteMessages:(NSArray *)messages
               resultCode:(int)resultCode
{
    if (resultCode != 0) {
        POSTMSG(NSLS(@"kDeleteFail"));
    }else{
        
    }
}

#pragma mark enter replay controller
- (void)enterReplayController:(DrawMessage *)message
{
    BOOL isNewVersion = [ConfigManager currentDrawDataVersion] < [message drawDataVersion];
    
    ReplayObject *obj = [ReplayObject obj];
    obj.actionList = [message drawActionList];
    obj.isNewVersion = isNewVersion;
    obj.canvasSize = [message canvasSize];
    
    obj.layers = [DrawLayer defaultOldLayersWithFrame:CGRectFromCGSize(message.canvasSize)];
    DrawPlayer *player =[DrawPlayer playerWithReplayObj:obj];
    [player showInController:self];

}

- (void)enterLargeImage:(PPMessage *)message
{
    _selectedMessage = message;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.canSave = YES;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [browser release];
    [nc release];
}

#pragma mark - mwPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (_selectedMessage.messageType == MessageTypeImage)
    {
        ImageMessage *imageMessage  = (ImageMessage *)_selectedMessage;
        NSURL *url = nil;
        if (imageMessage.status == MessageStatusFail) {
            url = [NSURL fileURLWithPath:imageMessage.imageUrl];
        } else {
            url = [NSURL URLWithString:imageMessage.imageUrl];
        }
        return [MWPhoto photoWithURL:url];
    }
    return nil;
}


#pragma mark - 


- (void)clickMessage:(PPMessage *)message
{
    switch (message.messageType) {
        case MessageTypeImage:
            [self enterLargeImage:message];
            break;
        case MessageTypeText:
            [self showActionOptionsForMessage:message];
            break;
        case MessageTypeDraw:
            [self enterReplayController:(DrawMessage *)message];
            break;
        case MessageTypeLocationRequest:
        {
            if (message.sourceType == SourceTypeSend) {
                [self showLocation:message];
            } else {
                [self showHandleAskLocatioActions:message];
            }
            break;
        }
        case MessageTypeLocationResponse:
            [self showLocation:message];
            break;
        default:
            break;
    }
}

- (void)showHandleAskLocatioActions:(PPMessage *)message
{
    MKBlockActionSheet *sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOpusOperation") delegate:nil cancelButtonTitle:NSLS(@"kCancel")  destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kReplyLocation"), NSLS(@"kRejectLocation"),NSLS(@"kShowOtherLocation"),nil];
    
    __block typeof (self) bself = self;
    [sheet setActionBlock:^(NSInteger buttonIndex){
        switch (buttonIndex) {
            case 0:
            {
                UserLocationController *controller = [[UserLocationController alloc] initWithType:LocationTypeFind isMe:YES latitude:0 longitude:0 messageType:MessageTypeLocationResponse reqMessageId:message.messageId];
                controller.delegate = bself;
                [self.navigationController pushViewController:controller animated:YES];
                [controller release];
                break;
            }
            case 1:
            {
                // TODO
                [[ChatService defaultService] sendReplyLocationMessage:0
                                                             longitude:0
                                                          reqMessageId:message.messageId
                                                           replyResult:REJECT_ASK_LOCATION
                                                          friendUserId:self.fid];
                break;
            }
            case 2:
            {
                [bself showLocation:message];
                break;
            }
            default:
                break;
        }
    }];
    [sheet showInView:self.view];
    [sheet release];
}

- (void)showLocation:(PPMessage *)message
{
    if (message.messageType == MessageTypeLocationRequest
        || message.messageType == MessageTypeLocationResponse) {
        
        BOOL isMe = (message.sourceType == SourceTypeSend);
        double latitude;
        double longitude;
        if (message.messageType == MessageTypeLocationRequest) {
            latitude = [(LocationReplyMessage*)message latitude];
            longitude = [(LocationReplyMessage*)message longitude];
        } else {
            if ([(LocationReplyMessage*)message replyResult] == REJECT_ASK_LOCATION)
            {
                return;
            }
            latitude = [(LocationReplyMessage*)message latitude];
            longitude = [(LocationReplyMessage*)message longitude];
        }
        
        UserLocationController *controller = [[UserLocationController alloc] initWithType:LocationTypeShow
                                                                                     isMe:isMe
                                                                                 latitude:latitude
                                                                                longitude:longitude
                                                                              messageType:message.messageType reqMessageId:nil];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}

- (void)showActionOptionsForMessage:(PPMessage *)message
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
        case MessageTypeImage:
            tag = ACTION_SHEET_TAG_IMAGE;
            otherOperation = NSLS(@"kLookLargeImage");
            break;
        case MessageTypeLocationRequest:
            tag = ACTION_SHEET_TAG_LOCATION_REQUEST;
            otherOperation = NSLS(@"kShowLocation");
            break;
        case MessageTypeLocationResponse:
        {
            tag = ACTION_SHEET_TAG_LOCATION_REQUEST;
            if ([(LocationReplyMessage *)message replyResult] == ACCEPT_ASK_LOCATION) {
                otherOperation = NSLS(@"kShowLocation");
            } else {
                otherOperation = nil;
            }
            break;
        }
        default:
            _showingActionSheet = NO;
            return;
    }
    [self resetASIndexesOfMessage:message];
    UIActionSheet *actionSheet = nil;
    
    if (message.status == MessageStatusFail) {
        if (otherOperation) {
            actionSheet=  [[UIActionSheet alloc]
                           initWithTitle:NSLS(@"kOpusOperation")
                           delegate:self
                           cancelButtonTitle:NSLS(@"kCancel")
                           destructiveButtonTitle:NSLS(@"kDelete")
                           otherButtonTitles:otherOperation, NSLS(@"kResend"), nil];
        } else {
            actionSheet=  [[UIActionSheet alloc]
                           initWithTitle:NSLS(@"kOpusOperation")
                           delegate:self
                           cancelButtonTitle:NSLS(@"kCancel")
                           destructiveButtonTitle:NSLS(@"kDelete")
                           otherButtonTitles:NSLS(@"kResend"), nil];
        }
        [actionSheet setDestructiveButtonIndex:_asIndexResend];
    }else
    {
        if (otherOperation) {
            actionSheet=  [[UIActionSheet alloc]
                           initWithTitle:NSLS(@"kOpusOperation")
                           delegate:self
                           cancelButtonTitle:NSLS(@"kCancel")
                           destructiveButtonTitle:NSLS(@"kDelete")
                           otherButtonTitles:otherOperation, nil];
        } else {
            actionSheet=  [[UIActionSheet alloc]
                           initWithTitle:NSLS(@"kOpusOperation")
                           delegate:self
                           cancelButtonTitle:NSLS(@"kCancel")
                           destructiveButtonTitle:NSLS(@"kDelete")
                           otherButtonTitles:nil];
        }
    }

    [actionSheet showInView:self.view];
    actionSheet.tag = tag;
    [actionSheet release];
    _selectedMessage = message;
}

#pragma mark options action.
- (void)didLongClickMessage:(PPMessage *)message
{
    if (message.messageType != MessageTypeText) {
        [self showActionOptionsForMessage:message];
    }else{
        [self clickMessage:message];
    }
}

- (void)didMessage:(PPMessage *)message loadImage:(UIImage *)image
{
//    [self.dataTableView reloadData];
    NSUInteger index = [_messageList indexOfObject:message];
    if (index < [_messageList count]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0
                                  ];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [self.dataTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _showingActionSheet = NO;
    if (_asIndexDelete == buttonIndex) {
        
        [[ChatService defaultService] deleteMessage:_selectedMessage];                
        [self reloadTableView];
        
    }else if(_asIndexCopy == buttonIndex && _selectedMessage.messageType == MessageTypeText)
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _selectedMessage.text;         
    }else if(_asIndexReplay == buttonIndex && _selectedMessage.messageType == MessageTypeDraw){
        [self enterReplayController:(DrawMessage *)_selectedMessage];
    }else if(_asIndexLookLarge == buttonIndex && _selectedMessage.messageType == MessageTypeImage){
        [self enterLargeImage:_selectedMessage];
    }else if(_asIndexShowLocation == buttonIndex &&
             (_selectedMessage.messageType == MessageTypeLocationRequest || _selectedMessage.messageType == MessageTypeLocationResponse)){
        [self showLocation:_selectedMessage];
    }else if(_asIndexResend == buttonIndex){
        
        [[ChatService defaultService] sendMessage:_selectedMessage];
        
        [self reloadTableView];
        [self tableViewScrollToBottom:YES];
    }
    _selectedMessage = nil;
}



#pragma mark load more chat list.

- (NSInteger)loadNewDataCount
{
    return 30;
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
            PPDebug(@"Last message Id is %@ from %@, text=%@", message.messageId, message.friendId, message.text);
            return message.messageId;
        }
    }
    return nil;
}

- (NSString *)firstMessageId
{
    for (PPMessage *message in _messageList) {
        if (message.isMessageSentOrReceived) {
            PPDebug(@"First message Id is %@ from %@, text=%@", message.messageId, message.friendId, message.text);
            return message.messageId;
        }
    }
    return nil;    
}

- (void)updateTitleForLoading
{
    [[CommonTitleView titleView:self.view] showLoading:NSLS(@"kLoadingMessage")];
}

- (void)clearTitleForLoading
{
    [[CommonTitleView titleView:self.view] hideLoading];
}

- (void)loadNewMessage:(BOOL)showActivity
{
    
    [self updateTitleForLoading];
    
    [[ChatService defaultService] loadMessageList:self.fid
                                  offsetMessageId:self.lastMessageId
                                          forward:YES
                                            limit:[self loadNewDataCount]];
    
 
}
- (void)loadMoreMessage
{
    [self updateTitleForLoading];

    [[ChatService defaultService] loadMessageList:self.fid
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
- (void)tableViewScrollToBottom:(BOOL)animated
{
    if ([self.messageList count] > 0) {
        NSInteger row = [self.messageList count] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.dataTableView scrollToRowAtIndexPath:indexPath 
                                  atScrollPosition:UITableViewScrollPositionBottom 
                                          animated:animated];
    }
}


- (void)reloadTableViewDataSource
{
    if (self.refreshHeaderView.hidden) {
        return;
    }
    [self loadMoreMessage];
}

#pragma mark -PhotoDrawSheetDelegate
- (void)didSelectImage:(UIImage *)image
{
    OfflineDrawViewController *odc = [[OfflineDrawViewController alloc] initWithTargetType:TypePhoto delegate:self];
    odc.bgImage = image;
    odc.bgImageName = [NSString stringWithFormat:@"%@.png", [NSString GetUUID]];
    [self presentModalViewController:odc animated:YES];
    //[self.navigationController pushViewController:odc animated:YES];
    [odc release];
}


#pragma mark - UserLocationControllerDelegate
- (void)didClickSendLocation:(double)latitude
                   longitude:(double)longitude
                 messageType:(MessageType)messageType
                reqMessageId:(NSString *)reqMessageId
{
    // TODO 
    if (messageType == MessageTypeLocationRequest) {
        [[ChatService defaultService] sendAskLocationMessage:latitude longitude:longitude friendUserId:self.fid];
    } else {
        [[ChatService defaultService] sendReplyLocationMessage:latitude longitude:longitude reqMessageId:reqMessageId replyResult:ACCEPT_ASK_LOCATION friendUserId:self.fid];
    }
}

@end
