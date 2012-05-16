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
#import "PPDebug.h"

#define NUM_EXPRESSION_IN_ONE_PAGE 5
#define DISTANCE_BETWEEN_EXPRESSION 10
#define TAG_EXPRESSION_BUTTON 210

#define DISTANCE_BETWEEN_AVATAR 5

@interface ChatController()
{
    NSString *_userId;
    GameChatType _chatType;
}
@end

@implementation ChatController

@synthesize chatControllerDelegate;
@synthesize chatView;
@synthesize avatarHolderView;
@synthesize avatarView;
@synthesize nameLabel;
@synthesize microBlogImageView;
@synthesize sexLabel;
@synthesize cityLabel;
@synthesize expressionScrollView;

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
    self.chatView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:234.0/255.0 blue:155.0/255.0 alpha:1.0];
    
    self.dataList = [[MessageManager defaultManager] messagesForChatType:_chatType];;
    [self configureExpressionScrollView];
    
    // Selected a user as defalut selected.
    GameSession *session = [[DrawGameService defaultService] session];
    GameSessionUser *user = [session.userList objectAtIndex:0];
    _userId = user.userId;
}

- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setSexLabel:nil];
    [self setCityLabel:nil];
    [self setExpressionScrollView:nil];
    [self setAvatarHolderView:nil];
    [self setMicroBlogImageView:nil];
    [self setChatView:nil];
    [self setAvatarView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [_userId release];
    [nameLabel release];
    [sexLabel release];
    [cityLabel release];
    [expressionScrollView release];
    [avatarHolderView release];
    [microBlogImageView release];
    [chatView release];
    [avatarView release];
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
    return ([dataList count]/3+1);
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

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - Button actions.
- (IBAction)clickPayAttentionButton:(id)sender {
}

- (IBAction)clickClose:(id)sender {
    [self.view removeFromSuperview];
}

- (void)clickExpression:(id)sender
{
    [self.view removeFromSuperview];

    NSString *key = [(UIButton*)sender titleForState:UIControlStateNormal];
//    PPDebug(@"key = %@", key);
    UIImage *expression = [[ExpressionManager defaultManager] expressionForKey:key];
    
    if (chatControllerDelegate && [chatControllerDelegate respondsToSelector:@selector(didSelectMessage:)]) {
        [chatControllerDelegate didSelectExpression:expression];
    }
    
    if (_chatType == GameChatTypeChatPrivate) {
        [[DrawGameService defaultService] privateChatExpression:[NSArray arrayWithObjects:_userId, nil] key:key]; 
    }else {
        [[DrawGameService defaultService] groupChatExpression:[NSArray arrayWithObjects:_userId, nil] key:key]; 
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
        [[DrawGameService defaultService] privateChatMessage:[NSArray arrayWithObjects:_userId, nil] message:message];            
    }else {
        [[DrawGameService defaultService] groupChatMessage:[NSArray arrayWithObjects:_userId, nil] message:message];            
    }
    
    return;
}

- (void)configureExpressionScrollView
{
    float width = (self.expressionScrollView.frame.size.width-DISTANCE_BETWEEN_EXPRESSION)/NUM_EXPRESSION_IN_ONE_PAGE-DISTANCE_BETWEEN_EXPRESSION;
    float heigth = width;
    
    NSArray *expressions = [[ExpressionManager defaultManager] allKeys];
    [expressionScrollView setContentSize:CGSizeMake(DISTANCE_BETWEEN_EXPRESSION+(width+DISTANCE_BETWEEN_EXPRESSION)*[expressions count]+1, heigth)];
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

- (void)updatePlayerAvatars
{
    [self cleanAvatars];
    
    // Get avatar frame.
    float width = (self.avatarHolderView.frame.size.width-DISTANCE_BETWEEN_AVATAR)/6-DISTANCE_BETWEEN_AVATAR;
    float height = width;
    CGRect frame = CGRectMake(0, 0, width, height);
    
    int i = 0;
    GameSession *session = [[DrawGameService defaultService] session];
    for (GameSessionUser *user in session.userList) {
        AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] frame:frame gender:user.gender];
        aView.delegate = self;
        [aView setUserId:user.userId];

        if ([DeviceDetection isIPAD]) {
            aView.center = CGPointMake(DISTANCE_BETWEEN_AVATAR+width/2 + (width+DISTANCE_BETWEEN_AVATAR) * i, height);            
        }else{
            aView.center = CGPointMake(DISTANCE_BETWEEN_AVATAR+width/2 + (width+DISTANCE_BETWEEN_AVATAR) * i, height);   
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
    
    _userId = [userId retain];
    DrawGameService* drawService = [DrawGameService defaultService];
    GameSessionUser* user = [[drawService session] getUserByUserId:userId];
    nameLabel.text = user.nickName;
    sexLabel.text = (user.gender==YES) ? NSLS(@"kMale") : NSLS(@"kFemale");
    AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] frame:self.avatarView.bounds gender:user.gender];
    [aView setAvatarSelected:YES];
    [avatarView addSubview:aView];
}

- (void)showInView:(UIView*)superView
{
    // Add to superview.
    [superView addSubview:self.view];

    // Update player avatars.
    [self updatePlayerAvatars];
    
    GameSession *session = [[DrawGameService defaultService] session];
    
    NSUInteger index = [session.userList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        GameSessionUser *user = (GameSessionUser*)obj;
        if ([_userId isEqualToString:user.userId]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index == NSNotFound) {
        _userId = [[session.userList objectAtIndex:0] userId];
    }
    
    [self didClickOnAvatar:_userId];
}

- (void)dismiss
{
    [self.view removeFromSuperview];
}

@end
