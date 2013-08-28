//
//  ChatController.m
//  Draw
//
//  Created by 小涛 王 on 12-5-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ChatController.h"
#import "MessageCell.h"
#import "ExpressionManager.h"
#import "DrawGameService.h"
#import "GameSessionUser.h"
#import "UserManager.h"
#import "DeviceDetection.h"
#import "UIImageUtil.h"
#import "ShareImageManager.h"
#import "FriendManager.h"
#import "CommonMessageCenter.h"
#import "AnimationManager.h"
#import "PPDebug.h"
#import "ChatService.h"
#import "NotificationManager.h"
#import "PPMessage.h"
#import "CustomUITextField.h"

#define NUM_EXPRESSION_IN_ONE_PAGE 5

#define WIDTH_EXPRESSION_IPHONE 30
#define WIDTH_EXPRESSION_IPAD WIDTH_EXPRESSION_IPHONE*2
#define WIDTH_EXPRESSION (([DeviceDetection isIPAD])?(WIDTH_EXPRESSION_IPAD):(WIDTH_EXPRESSION_IPHONE))

#define HEIGHT_EXPRESSION WIDTH_EXPRESSION


#define TAG_EXPRESSION_BUTTON 210

// For avatar
#define MAX_NUM_AVATAR 6

#define DISTANCE_BETWEEN_AVATAR_IPHONE 8
#define DISTANCE_BETWEEN_AVATAR_IPAD 26
#define  DISTANCE_BETWEEN_AVATAR (([DeviceDetection isIPAD])?(DISTANCE_BETWEEN_AVATAR_IPAD):(DISTANCE_BETWEEN_AVATAR_IPHONE))

#define WIDTH_AVATAR_IPHONE 36
#define WIDTH_AVATAR_IPAD 80
#define WIDTH_AVATAR (([DeviceDetection isIPAD])?(WIDTH_AVATAR_IPAD):(WIDTH_AVATAR_IPHONE))

#define HEIGHT_AVATAR WIDTH_AVATAR

#define RATIO_LABEL_WIDTH_DIVIDE_TEXT_LENGTH 1.2

#define MAX_WIDTH_NAME_LABEL_IPHONE 122.0/RATIO_LABEL_WIDTH_DIVIDE_TEXT_LENGTH
#define MAX_WIDTH_NAME_LABEL_IPAD 283/RATIO_LABEL_WIDTH_DIVIDE_TEXT_LENGTH
#define MAX_WIDTH_NAME_LABEL (([DeviceDetection isIPAD])?(MAX_WIDTH_NAME_LABEL_IPAD):(MAX_WIDTH_NAME_LABEL_IPHONE))

#define MAX_WIDTH_SEX_LABEL_IPHONE 50/RATIO_LABEL_WIDTH_DIVIDE_TEXT_LENGTH
#define MAX_WIDTH_SEX_LABEL_IPAD 100/RATIO_LABEL_WIDTH_DIVIDE_TEXT_LENGTH
#define MAX_WIDTH_SEX_LABEL (([DeviceDetection isIPAD])?(MAX_WIDTH_SEX_LABEL_IPAD):(MAX_WIDTH_SEX_LABEL_IPHONE))

#define MAX_SIZE_NAME_LABEL CGSizeMake(MAX_WIDTH_NAME_LABEL, CGFLOAT_MAX)
#define MAX_SIZE_SEX_LABEL CGSizeMake(MAX_WIDTH_SEX_LABEL, CGFLOAT_MAX)

#define EDGE_BETWEEN_NAME_LABEL_AND_MICRO_BLOG_VIEW_IPHONE 4
#define EDGE_BETWEEN_NAME_LABEL_AND_MICRO_BLOG_VIEW_IPAD EDGE_BETWEEN_NAME_LABEL_AND_MICRO_BLOG_VIEW_IPHONE*2
#define EDGE_BETWEEN_NAME_LABEL_AND_MICRO_BLOG_VIEW (([DeviceDetection isIPAD])?(EDGE_BETWEEN_NAME_LABEL_AND_MICRO_BLOG_VIEW_IPAD):(EDGE_BETWEEN_NAME_LABEL_AND_MICRO_BLOG_VIEW_IPHONE))

#define EDGE_BETWEEN_SEX_LABEL_AND_CITY_LABEL_IPHONE 2
#define EDGE_BETWEEN_SEX_LABEL_AND_CITY_LABEL_IPAD EDGE_BETWEEN_SEX_LABEL_AND_CITY_LABEL_IPHONE*2
#define EDGE_BETWEEN_SEX_LABEL_AND_CITY_LABEL (([DeviceDetection isIPAD])?(EDGE_BETWEEN_SEX_LABEL_AND_CITY_LABEL_IPAD):(EDGE_BETWEEN_SEX_LABEL_AND_CITY_LABEL_IPHONE))

@interface ChatController()
{
    NSString *_selectedUserId;
    GameChatType _chatType;
}

@property (retain, nonatomic) NSString *selectedUserId;
@property (retain, nonatomic) CommonDialog *inputDialog;

- (void)configureExpressionScrollView;
- (NSArray*)messages:(MessagesType)type;
- (void)updateCurrentSelectedUser:(NSArray*)userList;
- (NSArray*)getOtherUsers;
- (CGSize)getStringSize:(UIFont*)font string:(NSString*)string withinSize:(CGSize)withinSize;
- (NSString*)getUserNickName:(int)type userId:(NSString*)userId;
- (void)showChatInputDialog;
- (void)handleChatMessage:(NSString*)message;
- (UIImage*)getMicroImage:(GameSessionUser*)user;

@end

@implementation ChatController

@synthesize levelLabel;
@synthesize chatControllerDelegate;
@synthesize viewBgImageView;
@synthesize userView;
@synthesize chatInfoView;
@synthesize chatInfoViewBgImageView;
@synthesize selectedUserId = _selectedUserId;

@synthesize avatarHolderView;
@synthesize avatarView;
@synthesize nameLabel;
@synthesize microBlogImageView;
@synthesize alreadPayAttentionLabel;
@synthesize sexLabel;
@synthesize cityLabel;
@synthesize payAttentionButton;
@synthesize expressionScrollView;
@synthesize closeButton;
@synthesize chatTitleLabel;

- (id)initWithChatType:(GameChatType)chatType 
{
    self = [super init];
    if (self) {
        _chatType = chatType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    chatInfoViewBgImageView.backgroundColor = [UIColor clearColor];
    avatarHolderView.backgroundColor = [UIColor clearColor];
    
    [payAttentionButton setBackgroundImage:[[ShareImageManager defaultManager] normalButtonImage] forState:UIControlStateNormal];
    [payAttentionButton setTitle:NSLS(@"kFollowMe") forState:UIControlStateNormal];
    [alreadPayAttentionLabel setText:NSLS(@"kFollowed")];
    [chatTitleLabel setText:NSLS(@"kChatTitle")];
    [closeButton setTitle:NSLS(@"kClose") forState:UIControlStateNormal];
    
    SET_BUTTON_ROUND_STYLE_YELLOW(closeButton);
//    [closeButton setBackgroundImage:[[ShareImageManager defaultManager] commonDialogLeftBtnImage] forState:UIControlStateNormal];
    
    [self configureExpressionScrollView];
    
//    UIImage *bgImage = [[ShareImageManager defaultManager] messageImage];
    
    if (_chatType == GameChatTypeChatGroup) {
        viewBgImageView.hidden = YES;
        userView.hidden = YES;
//        [chatInfoViewBgImageView setImage:bgImage];
    }
     
    if (_chatType == GameChatTypeChatPrivate) {
//        viewBgImageView.image = bgImage;
        
        // Selected a user as defalut selected.
        GameSession *session = [[DrawGameService defaultService] session];
        GameSessionUser *user = [session.userList objectAtIndex:0];
        self.selectedUserId = user.userId;
    }
    
//    self.chatInfoViewBgImageView.layer.borderWidth = 2;
//    self.chatInfoViewBgImageView.layer.borderColor = [COLOR_GREEN CGColor];
    self.chatInfoViewBgImageView.backgroundColor = COLOR_GREEN;

//    self.viewBgImageView.layer.borderWidth = 2;
//    self.viewBgImageView.layer.borderColor = [COLOR_GREEN CGColor];
    self.viewBgImageView.backgroundColor = COLOR_GREEN;

    SET_BUTTON_ROUND_STYLE_YELLOW(self.payAttentionButton);
    
    self.nameLabel.textColor = COLOR_ORANGE;
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NotificationManager defaultManager]hideNotificationForType:NotificationTypeRoom];
    [super viewDidDisappear:animated];    
}


- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setSexLabel:nil];
    [self setCityLabel:nil];
    [self setExpressionScrollView:nil];
    [self setAvatarHolderView:nil];
    [self setMicroBlogImageView:nil];
    [self setAvatarView:nil];
    [self setUserView:nil];
    [self setChatInfoView:nil];
    [self setPayAttentionButton:nil];
    [self setChatInfoViewBgImageView:nil];
    [self setViewBgImageView:nil];
    [self setCloseButton:nil];
    [self setAlreadPayAttentionLabel:nil];
    [self setLevelLabel:nil];
    [self setChatTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [_selectedUserId release];
    [_inputDialog release];
    [nameLabel release];
    [sexLabel release];
    [cityLabel release];
    [expressionScrollView release];
    [avatarHolderView release];
    [microBlogImageView release];
    [avatarView release];
    [userView release];
    [chatInfoView release];
    [payAttentionButton release];
    [chatInfoViewBgImageView release];
    [viewBgImageView release];
    [closeButton release];
    [alreadPayAttentionLabel release];
    [levelLabel release];
    [chatTitleLabel release];
    [super dealloc];
}

#pragma mark - Table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MessageCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [dataList count] / 3;
    int remainder = [dataList count] % 3;
    
    if (remainder == 0) {
        return count;
    }else {
        return count+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [MessageCell getCellIdentifier];
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [MessageCell createCell:self];
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.messageCellDelegate = self;
    }
    cell.indexPath = indexPath;
    NSInteger index = indexPath.row;
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (int i = index * 3; i < (index * 3 + 3) && i < [dataList count]; ++ i) {
        NSString *message = [self.dataList objectAtIndex:i];
        [messages addObject:message];
        [cell setCellData:messages];
    }
    [messages release];

    return cell;
}

#pragma mark - Button actions.
- (IBAction)clickPayAttentionButton:(id)sender {
    
    [[FriendService defaultService] followUser:_selectedUserId viewController:self];
}

- (IBAction)clickClose:(id)sender {
    [self dismiss:YES];
}

- (void)clickExpression:(id)sender
{
    [self.view removeFromSuperview];

    NSString *key = [(UIButton*)sender titleForState:UIControlStateNormal];
    UIImage *expression = [[ExpressionManager defaultManager] pngExpressionForKey:key];
    
    if (chatControllerDelegate && [chatControllerDelegate respondsToSelector:@selector(didSelectExpression:toUser:)]) {
        NSString *nickName = [self getUserNickName:_chatType userId:_selectedUserId];
        [chatControllerDelegate didSelectExpression:expression toUser:nickName];
    }
    
    if (_chatType == GameChatTypeChatPrivate) {
        [[DrawGameService defaultService] privateChatExpression:[NSArray arrayWithObjects:_selectedUserId, nil] key:key]; 
    }else {
        [[DrawGameService defaultService] groupChatExpression:key]; 
    }
}


#pragma mark - FriendServiceDelegate delegate.
- (void)didFollowUser:(int)resultCode
{
    if (resultCode == 0) {
        [self popupMessage:NSLS(@"kFollowSuccessfully") title:nil];

        payAttentionButton.hidden = YES;
        alreadPayAttentionLabel.hidden = NO;
    } else {
        [self popupMessage:NSLS(@"kFollowFailed") title:nil];
    }
}

#pragma mark - MessageCell delegate.
- (void)didSelectMessage:(NSString*)message
{    
    if ([message isEqualToString:NSLS(@"kSelfDefine")]) {
        [self showChatInputDialog];
    }else {
        [self handleChatMessage:message];
    }
        
    return;
}

- (NSString*)getUserNickName:(int)type userId:(NSString*)userId
{
    NSString *title = nil;

    if (_chatType == GameChatTypeChatPrivate) {
        title = [[[DrawGameService defaultService] session] getNickNameByUserId:_selectedUserId];
    }else {
        title = NSLS(@"kAllUser");
    }

    return title;
}

- (void)showChatInputDialog
{
    NSString *title = [NSString stringWithFormat:NSLS(@"kChatDialogTitle"), [self getUserNickName:_chatType userId:_selectedUserId]];
    self.inputDialog = [CommonDialog createInputFieldDialogWith:title delegate:self];
    _inputDialog.inputTextField.placeholder = NSLS(@"kInputWhatYouWantToSay");
    [_inputDialog showInView:self.view];
}

- (void)didClickOk:(CommonDialog *)dialog infoView:(UITextField *)infoView
{
    [_inputDialog removeFromSuperview];
    [self handleChatMessage:infoView.text];
}

- (void)didClickCancel:(CommonDialog *)dialog
{
    [_inputDialog removeFromSuperview];
}

- (void)handleChatMessage:(NSString*)message
{
    [self.view removeFromSuperview];
    
    if (chatControllerDelegate && [chatControllerDelegate respondsToSelector:@selector(didSelectMessage:toUser:)]) {
        NSString *nickName = [self getUserNickName:_chatType userId:_selectedUserId]; 
        [chatControllerDelegate didSelectMessage:message toUser:nickName];
    }
    
    if ([message isEqualToString:NSLS(@"kWaitABit")] || [message isEqualToString:NSLS(@"kQuickQuick")]){
        return;
    }
    
    if (_chatType == GameChatTypeChatPrivate) {
        [[ChatService defaultService] sendTextMessage:message friendUserId:_selectedUserId];        
        [[DrawGameService defaultService] privateChatMessage:[NSArray arrayWithObjects:_selectedUserId, nil] message:message];            
    }else {
        [[DrawGameService defaultService] groupChatMessage:message];            
    }
}

- (void)configureExpressionScrollView
{
    float edge = (expressionScrollView.frame.size.width - NUM_EXPRESSION_IN_ONE_PAGE*WIDTH_EXPRESSION)/6;
    
    NSArray *expressions = [[ExpressionManager defaultManager] allPngKeys];
    
    int count = ceil([expressions count] / (double)NUM_EXPRESSION_IN_ONE_PAGE);
    
    [expressionScrollView setContentSize:CGSizeMake(expressionScrollView.frame.size.width * count, 0)];
    expressionScrollView.showsVerticalScrollIndicator = NO;
    expressionScrollView.showsHorizontalScrollIndicator = NO;
    expressionScrollView.pagingEnabled = YES;
    
    int i = 0;
    for (NSString *key in expressions) {
        UIImage *image = [[ExpressionManager defaultManager] pngExpressionForKey:key];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(edge+(WIDTH_EXPRESSION+edge)*i, expressionScrollView.frame.size.height/2-HEIGHT_EXPRESSION/2, WIDTH_EXPRESSION, HEIGHT_EXPRESSION)];
        button.tag = TAG_EXPRESSION_BUTTON+i++;
        [button setBackgroundImage:image forState:UIControlStateNormal];

        [button setTitle:key forState:UIControlStateNormal];
        [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickExpression:) forControlEvents:UIControlEventTouchUpInside];
        [expressionScrollView addSubview:button];
        [button release];
    }
}

- (void)cleanAvatars
{
    //remove all the old avatars
    for (AvatarView *view in avatarHolderView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)updatePlayerAvatars:(NSArray*)userList
{
    [self cleanAvatars];
    
    CGRect frame = CGRectMake(0, 0, WIDTH_AVATAR, HEIGHT_AVATAR);
    
    int i = 0;
    float edge = (avatarHolderView.frame.size.width - MAX_NUM_AVATAR*WIDTH_AVATAR - (MAX_NUM_AVATAR-1)*DISTANCE_BETWEEN_AVATAR) / 2;
    for (GameSessionUser *user in userList) {
        AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] frame:frame gender:user.gender level:user.level];
        aView.delegate = self;
        [aView setUserId:user.userId];

        if ([DeviceDetection isIPAD]) {
            aView.center = CGPointMake(edge+WIDTH_AVATAR/2 + (WIDTH_AVATAR+DISTANCE_BETWEEN_AVATAR) * i, avatarHolderView.frame.size.height/2);            
        }else{
            aView.center = CGPointMake(edge+WIDTH_AVATAR/2 + (WIDTH_AVATAR+DISTANCE_BETWEEN_AVATAR) * i, avatarHolderView.frame.size.height/2);   
        }
        
        [self.avatarHolderView addSubview:aView];
        
        [aView release];
        ++ i;                                  
    }
}

- (void)didClickOnAvatar:(NSString *)userId
{
    PPDebug(@"click user: %@", userId);
    for (UIView *view in avatarHolderView.subviews) {
        AvatarView *avatar = (AvatarView*)view;
        if ([avatar.userId isEqualToString:userId]) {
            [avatar setAvatarSelected:YES];
        }else {
            [avatar setAvatarSelected:NO];
        }
    }
    
    self.selectedUserId = userId;
    DrawGameService* drawService = [DrawGameService defaultService];
    GameSessionUser* user = [[drawService session] getUserByUserId:userId];
    
    AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] frame:self.avatarView.bounds gender:user.gender level:user.level];
    [aView setAvatarSelected:NO level:user.level];
    [avatarView addSubview:aView];
    [aView release];
    
    nameLabel.text = user.nickName;
    CGSize nameStringSize = [self getStringSize:nameLabel.font string:nameLabel.text withinSize:MAX_SIZE_NAME_LABEL];
    nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, nameStringSize.width*RATIO_LABEL_WIDTH_DIVIDE_TEXT_LENGTH, nameLabel.frame.size.height);
    
    [microBlogImageView setImage:[self getMicroImage:user]];
    microBlogImageView.center = CGPointMake(nameLabel.frame.origin.x+nameLabel.frame.size.width+EDGE_BETWEEN_NAME_LABEL_AND_MICRO_BLOG_VIEW+microBlogImageView.frame.size.width/2, nameLabel.center.y);
        
    sexLabel.text = (user.gender==YES) ? NSLS(@"kMale") : NSLS(@"kFemale");
    CGSize sexStringSize = [self getStringSize:sexLabel.font string:sexLabel.text withinSize:MAX_SIZE_SEX_LABEL];
    sexLabel.frame = CGRectMake(sexLabel.frame.origin.x, sexLabel.frame.origin.y, sexStringSize.width*RATIO_LABEL_WIDTH_DIVIDE_TEXT_LENGTH, sexLabel.frame.size.height);
    
    cityLabel.text = user.location;
    cityLabel.center = CGPointMake(sexLabel.frame.origin.x+sexLabel.frame.size.width+EDGE_BETWEEN_SEX_LABEL_AND_CITY_LABEL+cityLabel.frame.size.width/2, sexLabel.center.y);
    
    if ([[FriendManager defaultManager] isFollowFriend:_selectedUserId]) {
        payAttentionButton.hidden = YES;
        alreadPayAttentionLabel.hidden = NO;
    }else {
        payAttentionButton.hidden = NO;
        alreadPayAttentionLabel.hidden = YES;
    }
    int level = (user.level <= 0)?1:user.level;
    [levelLabel setText:[NSString stringWithFormat:@"LV:%d",level]];
    
    
}

- (void)showInView:(UIView*)superView messagesType:(MessagesType)type selectedUserId:(NSString*)selectedUserId needAnimation:(BOOL)needAnimation
{
    self.dataList = [self messages:type];
    [dataTableView reloadData];

    if (_chatType == GameChatTypeChatPrivate) {
        // Add to superview.
        NSArray *otherUsers = [self getOtherUsers];
        if ([otherUsers count] == 0) {
            [self popupMessage:NSLS(@"kNobodyInRoom") title:nil];
            return;
        }

        [superView addSubview:self.view];
        if (needAnimation) {
            CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:0.3 delegate:self removeCompeleted:NO];
            [self.view.layer addAnimation:runIn forKey:@"runIn"];
        }

        // Update player avatars.
        [self updatePlayerAvatars:otherUsers];
        
        // Update current selected user.
        if (selectedUserId == nil) {
            [self updateCurrentSelectedUser:otherUsers];
        }else {
            self.selectedUserId = selectedUserId;
        }
        
        [self didClickOnAvatar:_selectedUserId];
    }else {
        // Add to superview.        
        [superView addSubview:self.view];
        
        if (needAnimation) {
            CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:0.3 delegate:self removeCompeleted:NO];
            [self.view.layer addAnimation:runIn forKey:@"runIn"];
        }
    }
}

- (NSArray*)messages:(MessagesType)type
{
    NSArray *array = [[MessageManager defaultManager] messagesForType:type];
    if (type == RoomMessages) {
        NSMutableArray *messages = [[[NSMutableArray alloc] init] autorelease];
        if ([[DrawGameService defaultService] isMyTurn]) {
            [messages addObject:NSLS(@"kWaitABit")];
        }else {
            [messages addObject:NSLS(@"kQuickQuick")];
        }
        
        for (NSString *message in array) {
            [messages addObject:message];
        }
        
        return messages;
    }else {
        return array;
    }
}

- (NSArray*)getOtherUsers
{
    GameSession *session = [[DrawGameService defaultService] session];

    NSMutableArray *otherUsers = [[[NSMutableArray alloc] init] autorelease];
    for (GameSessionUser *user in session.userList) {
        if (![[UserManager defaultManager] isMe:user.userId]) {
            [otherUsers addObject:user];
        }
    }
    
    return otherUsers;
}

- (void)updateCurrentSelectedUser:(NSArray*)userList
{    
    NSUInteger index = [userList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        GameSessionUser *user = (GameSessionUser*)obj;
        if ([_selectedUserId isEqualToString:user.userId]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index == NSNotFound) {
        self.selectedUserId = [[userList objectAtIndex:0] userId];
    }
}

- (void)dismiss:(BOOL)needAnimation
{
    if (needAnimation) {
        CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:0.3 delegate:self removeCompeleted:NO];
        [self.view.layer addAnimation:runOut forKey:@"runOut"];
    }else {
        [self.view removeFromSuperview];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([self.view.layer animationForKey:@"runOut"] == anim) {
        [self.view removeFromSuperview];
    }
}


- (UIImage*)getMicroImage:(GameSessionUser*)user
{
    if ([user isBindSina]) {
        return [[ShareImageManager defaultManager] sinaWeiboImage];
    }else if ([user isBindQQ]) {
        return [[ShareImageManager defaultManager] qqWeiboImage];
    }else if ([user isBindFacebook]) {
        return [[ShareImageManager defaultManager] facebookImage];
    }else {
        return nil;
    }
}

- (CGSize)getStringSize:(UIFont*)font string:(NSString*)string withinSize:(CGSize)withinSize
{
    CGSize size = [string sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
    
    return size;
}

@end
