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
#import "PPDebug.h"

#define NUM_EXPRESSION_IN_ONE_PAGE 5
#define DISTANCE_BETWEEN_EXPRESSION 10
#define TAG_EXPRESSION_BUTTON 210

// For avatar
#define MAX_NUM_AVATAR 6
#define DISTANCE_BETWEEN_AVATAR 8
#define WIDTH_AVATAR 36
#define HEIGHT_AVATAR WIDTH_AVATAR

@interface ChatController()
{
    NSString *_selectedUserId;
    GameChatType _chatType;
}

@property (retain, nonatomic) NSString *selectedUserId;

@end

@implementation ChatController

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
@synthesize sexLabel;
@synthesize cityLabel;
@synthesize payAttentionButton;
@synthesize expressionScrollView;
@synthesize closeButton;

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
    
    [payAttentionButton setBackgroundImage:[UIImage strectchableImageName:@"normal_button.png"] forState:UIControlStateNormal];
    
    [self configureExpressionScrollView];
    
    UIImage *bgImage = [UIImage strectchableImageName:@"messagebg.png"];
    if (_chatType == GameChatTypeChatGroup) {
        viewBgImageView.hidden = YES;
        userView.hidden = YES;
        
        UIImage *bgImage = [UIImage strectchableImageName:@"messagebg.png"];
        [chatInfoViewBgImageView setImage:bgImage];
    }
     
    if (_chatType == GameChatTypeChatPrivate) {
        viewBgImageView.image = bgImage;
        
        // Selected a user as defalut selected.
        GameSession *session = [[DrawGameService defaultService] session];
        GameSessionUser *user = [session.userList objectAtIndex:0];
        self.selectedUserId = user.userId;
    }
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [_selectedUserId release];
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
    [self.view removeFromSuperview];
}

- (void)clickExpression:(id)sender
{
    [self.view removeFromSuperview];

    NSString *key = [(UIButton*)sender titleForState:UIControlStateNormal];
    UIImage *expression = [[ExpressionManager defaultManager] expressionForKey:key];
    
    if (chatControllerDelegate && [chatControllerDelegate respondsToSelector:@selector(didSelectMessage:)]) {
        [chatControllerDelegate didSelectExpression:expression];
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
        [payAttentionButton setTitle:NSLS(@"kMyFollow") forState:UIControlStateNormal];
        payAttentionButton.userInteractionEnabled = NO;
    } else {
        [self popupMessage:NSLS(@"kFollowFailed") title:nil];
    }
}

#pragma mark - MessageCell delegate.
- (void)didSelectMessage:(NSString*)message
{    
    [self.view removeFromSuperview];

    if (chatControllerDelegate && [chatControllerDelegate respondsToSelector:@selector(didSelectMessage:)]) {
        [chatControllerDelegate didSelectMessage:message];
    }
        
    if (_chatType == GameChatTypeChatPrivate) {
        [[DrawGameService defaultService] privateChatMessage:[NSArray arrayWithObjects:_selectedUserId, nil] message:message];            
    }else {
        [[DrawGameService defaultService] groupChatMessage:message];            
    }
    
    return;
}

- (void)configureExpressionScrollView
{
    float width = (self.expressionScrollView.frame.size.width-DISTANCE_BETWEEN_EXPRESSION)/NUM_EXPRESSION_IN_ONE_PAGE-DISTANCE_BETWEEN_EXPRESSION;
    float heigth = width;
    
    NSArray *expressions = [[ExpressionManager defaultManager] allKeys];
    [expressionScrollView setContentSize:CGSizeMake(DISTANCE_BETWEEN_EXPRESSION+(width+DISTANCE_BETWEEN_EXPRESSION)*[expressions count]+1, expressionScrollView.frame.size.height)];
    int i = 0;
    for (NSString *key in expressions) {
        UIImage *image = [[ExpressionManager defaultManager] expressionForKey:key];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(DISTANCE_BETWEEN_EXPRESSION+(width+DISTANCE_BETWEEN_EXPRESSION)*i, /*expressionScrollView.frame.size.height*/0, width, heigth)];
        button.tag = TAG_EXPRESSION_BUTTON+i++;
        [button setImage:image forState:UIControlStateNormal];
        [button setTitle:key forState:UIControlStateNormal];
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
        AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] frame:frame gender:user.gender];
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
    nameLabel.text = user.nickName;
    sexLabel.text = (user.gender==YES) ? NSLS(@"kMale") : NSLS(@"kFemale");
    AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] frame:self.avatarView.bounds gender:user.gender];
    [aView setAvatarSelected:YES];
    [avatarView addSubview:aView];
}

- (void)showInView:(UIView*)superView messagesType:(MessagesType)type selectedUserId:(NSString*)selectedUserId
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
    }
    
    [closeButton setBackgroundImage:[UIImage strectchableImageName:@"red_button.png"] forState:UIControlStateNormal];
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

- (void)dismiss
{
    [self.view removeFromSuperview];
}

@end
