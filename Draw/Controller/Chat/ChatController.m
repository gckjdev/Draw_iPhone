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
    NSMutableArray *_avatarArray;
    NSString *_userId;
    ChatType _type;
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

- (id)initWithChatType:(ChatType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.chatView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:234.0/255.0 blue:155.0/255.0 alpha:1.0];
    
    self.dataList = [[MessageManager defaultManager] messagesForChatType:_type];;
    [self configureExpressionScrollView];
    
    _avatarArray = [[[NSMutableArray alloc] init] retain];
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
    [_avatarArray release];
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
    NSString *key = [(UIButton*)sender titleForState:UIControlStateNormal];
    PPDebug(@"key = %@", key);
    [self.view removeFromSuperview];
}

#pragma mark - MessageCell delegate.
- (void)didSelectMessage:(NSString*)message
{    
    [self.view removeFromSuperview];
    if ([message isEqualToString:NSLS(@"kWaitABit")] || [message isEqualToString:NSLS(@"kQuickQuick")]){
        if(chatControllerDelegate && [chatControllerDelegate respondsToSelector:@selector(wantProlongStart)]){
            [chatControllerDelegate wantProlongStart];
        }
            
        return;
    }
    
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
    for (AvatarView *view in _avatarArray) {
        [view removeFromSuperview];
    }
    [_avatarArray removeAllObjects];
}

- (void)updatePlayerAvatars
{
    [self cleanAvatars];
    GameSession *session = [[DrawGameService defaultService] session];
    
    // Get avatar frame.
    float width = (self.avatarHolderView.frame.size.width-DISTANCE_BETWEEN_AVATAR)/6-DISTANCE_BETWEEN_AVATAR;
    float height = width;
    CGRect frame = CGRectMake(0, 0, width, height);
    
    int i = 0;
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
        [_avatarArray addObject:aView];
        [aView release];
        ++ i;                                  
    }
}

- (void)didClickOnAvatar:(NSString *)userId
{
    PPDebug(@"click user: %@", userId);
    _userId = [userId retain];
    DrawGameService* drawService = [DrawGameService defaultService];
    GameSessionUser* user = [[drawService session] getUserByUserId:userId];
    nameLabel.text = user.nickName;
    sexLabel.text = (user.gender==YES) ? NSLS(@"Male") : NSLS(@"Female");
    AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] frame:self.avatarView.frame gender:user.gender];
    [avatarView addSubview:aView];
}

- (void)showInView:(UIView*)superView
{
    // Add to superview.
    [superView addSubview:self.view];

    // Update player avatars.
    [self updatePlayerAvatars];
    
    // Selected a user as defalut selected.
    GameSession *session = [[DrawGameService defaultService] session];
    GameSessionUser *user = [session.userList objectAtIndex:0];
    [self didClickOnAvatar:user.userId];
}

@end
