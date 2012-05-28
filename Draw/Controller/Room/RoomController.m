//
//  RoomController.m
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoomController.h"
#import "DrawGameService.h"
#import "SelectWordController.h"
#import "ShowDrawController.h"
#import "GameSession.h"
#import "PPApplication.h"
#import "DrawAppDelegate.h"
#import "UINavigationController+UINavigationControllerAdditions.h"
#import "PPDebug.h"
#import "GameSessionUser.h"
#import "GameMessage.pb.h"
#import "UserManager.h"
#import "ShareImageManager.h"
#import "AccountService.h"
#import "AnimationManager.h"
#import "UserManager.h"
#import "LocaleUtils.h"
#import "DeviceDetection.h"
#import "AudioManager.h"
#import "DrawConstants.h"
#import "ConfigManager.h"
#import "ExpressionManager.h"
#import "StableView.h"
#import "ChatMessageView.h"

#define MAX_CHANGE_ROOM_PER_DAY     5

@interface RoomController ()

- (void)updateGameUsers;
- (void)updateRoomInfo;
- (void)updateStartButton;
- (void)updateOnlineUserLabel;

- (void)resetStartTimer;
- (void)scheduleStartTimer;
- (void)prolongStartTimer;

- (BOOL)isMyTurn;
- (NSInteger)userCount;
- (void)quitRoom;

- (void)showChatMessageViewOnUser:(NSString*)userId title:(NSString*)title message:(NSString*)message;
- (void)showChatMessageViewOnUser:(NSString*)userId title:(NSString*)title expression:(UIImage*)expression;

@end

@implementation RoomController

@synthesize prolongButton = _prolongButton;
@synthesize roomNameLabel;
@synthesize startGameButton;
@synthesize startTimer = _startTimer;
@synthesize clickCount = _clickCount;
@synthesize onlinePlayerCountLabel = _onlinePlayerCountLabel;
@synthesize privateChatController = _privateChatController;
@synthesize groupChatController = _groupChatController;
@synthesize isFriendRoom = _isFriendRoom;
@synthesize changeRoomButton;

#define QUICK_DURATION  2
#define MAX_CLICK_COUNT 5   

- (void)dealloc {
    [changeRoomButton release];
    [_startTimer release];
    [startGameButton release];
    [roomNameLabel release];
    [_prolongButton release];
    [popupButton release];
    [_onlinePlayerCountLabel release];
    [_privateChatController release];
    [_groupChatController release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _userManager = [UserManager defaultManager];
        [self resetStartTimer];
        popupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [popupButton retain];
        
        [[DrawGameService defaultService] setRoomDelegate:self];        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
//    [self setBackgroundImageName:ROOM_BACKGROUND];    
    
    self.roomNameLabel.text = @"";
    
    [super viewDidLoad];
    [self.view addSubview:popupButton];
    popupButton.hidden = YES;
    CGFloat fontSize = 18;    
    if ([DeviceDetection isIPAD]) {
        fontSize = 18 * 2;
        [popupButton setContentEdgeInsets:UIEdgeInsetsMake(10 * 2, 0, 0, 0)];
    }else {
        [popupButton setContentEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
    }
    [popupButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];

    [popupButton setBackgroundImage:[[ShareImageManager defaultManager] popupImage] 
                                forState:UIControlStateNormal];
    [popupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidAppear:(BOOL)animated
{    
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    
    [[DrawGameService defaultService] registerObserver:self];
    
    [self updateOnlineUserLabel];
    [self updateGameUsers];
    [self updateRoomInfo];
    [self updateStartButton];
        
    [self.prolongButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] forState:UIControlStateNormal];
    [self.startGameButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];    
    [self.startGameButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateDisabled];    
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self resetStartTimer];
    [self hideActivity];
    [self clearUnPopupMessages];
    [super viewDidDisappear:animated];
    [[DrawGameService defaultService] unregisterObserver:self]; 
    [_privateChatController dismiss:NO];
    [_groupChatController dismiss:NO];
    PPDebug(@"<unregisterObserver> room controller");
}

- (void)viewDidUnload
{
    [[DrawGameService defaultService] unregisterObserver:self];
    [self setStartGameButton:nil];
    [self setRoomNameLabel:nil];
    [self setProlongButton:nil];
    [self setOnlinePlayerCountLabel:nil];
    [self setStartTimer:nil];
    [self setChangeRoomButton:nil];
    [self setPrivateChatController:nil];
    [self setGroupChatController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - GUI Update Methods
#define DRAWING_MARK_TAG    2012040401
#define AVATAR_FRAME_TAG    20120406
#define DRAWING_MARK_FRAME ([DeviceDetection isIPAD]) ? CGRectMake(40 * 2, 40 * 2, 25 * 2, 25 * 2) : CGRectMake(40, 40, 25, 25)
#define ORG_POINT  ([DeviceDetection isIPAD]) ? CGPointMake(124, 341) : CGPointMake(46, 150)
#define AVATAR_WIDTH ([DeviceDetection isIPAD]) ? 128 : 64
#define AVATAR_HEIGTH ([DeviceDetection isIPAD]) ? 124 : 62
- (void)prepareAvatars
{
    int imageStartTag = 31;
    int imageEndTag = 36;
    float seperatorX = ([DeviceDetection isIPAD]) ? 196 : 80;
    float seperatorY = ([DeviceDetection isIPAD]) ? 220 : 99;
    CGPoint orgPoint = ORG_POINT;
    for (int i = imageStartTag; i <= imageEndTag; i++) {
        AvatarView* avatarView = [[AvatarView alloc] initWithUrlString:@"" frame:CGRectMake(orgPoint.x+((i-31)%3)*seperatorX, orgPoint.y+((i-31)/3)*seperatorY, AVATAR_WIDTH, AVATAR_HEIGTH) gender:NO];
        avatarView.tag = i;
        [avatarView setImage:nil];
        avatarView.hidden = NO;
        avatarView.delegate = self;
        [self.view addSubview:avatarView];
        [avatarView release];
    }
}

- (void)updateOnlineUserLabel
{
    [self.onlinePlayerCountLabel setText:[NSString stringWithFormat:NSLS(@"kOnlineUserCount"), [DrawGameService defaultService].onlineUserCount]];
}

- (void)updateGameUsers
{        
    GameSession* session = [[DrawGameService defaultService] session];
    NSArray* userList = [session userList];
    int startTag = 21;
    int endTag = 26;
    int imageStartTag = 31;
    int imageEndTag = 36;
    
    for (GameSessionUser* user in userList){

        if (startTag > endTag) {
            return;
        }
        
        UILabel* label = (UILabel*)[self.view viewWithTag:startTag++];
        [label setText:[user nickName]];
        
        if ([session isMe:[user userId]]){
            NSString* title = [NSString stringWithFormat:NSLS(@"Me")];
            [label setText:title];
        }
        
        // set images

        NSString* avatar = nil;
        BOOL isMe = [session isMe:[user userId]];
        if (isMe){
            avatar = [[UserManager defaultManager] avatarURL];
        }
        else{
            avatar = [user userAvatar];
        } 
        
        AvatarView* imageView = (AvatarView*)[self.view viewWithTag:imageStartTag++];
        if (imageView == nil) {
            [self prepareAvatars];
        }
        [imageView setAvatarUrl:avatar gender:[user gender]];
        [imageView setUserId:user.userId];
        //[imageView setFrame:viewForFrame.frame];
        
        // set default image firstly
        PPDebug(@"user gender=%d", [user gender]);
//        if ([user gender])
//            [imageView setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
//        else
//            [imageView setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];

//        if (isMe){
//            [imageView setImage:[[UserManager defaultManager] avatarImage]];
//        }

        
//        UIView *view = [imageView viewWithTag:DRAWING_MARK_TAG];
//        [view removeFromSuperview];
        
//        UIImage* frameImage = nil;
//        
//        if ([[[DrawGameService defaultService] session] isCurrentPlayUser:user.userId]) {
//            UIImage *drawingMark = [[ShareImageManager defaultManager] drawingMarkLargeImage];
//            UIImageView *drawingImageView = [[UIImageView alloc] initWithImage:drawingMark];
//            [drawingImageView setFrame:DRAWING_MARK_FRAME];
//            drawingImageView.tag = DRAWING_MARK_TAG;
//            [imageView addSubview:drawingImageView];
//            [drawingImageView release];
//        }
//        else{
//            
//            frameImage = [[ShareImageManager defaultManager] avatarUnSelectImage];            
//        }
        
        if ([[[DrawGameService defaultService] session] isCurrentPlayUser:user.userId]) {
            [imageView setAvatarSelected:YES];
            [imageView setHasPen:YES];
        }
        else{
            [imageView setAvatarSelected:NO];
            [imageView setHasPen:NO];
        }
        
        // create image view
//        CGRect frame = imageView.bounds;
//        frame.origin.x = -3;
//        frame.origin.y = -3;
//        frame.size.width += 6;
//        frame.size.height += 10;
//        UIImageView *frameView = [[UIImageView alloc] initWithImage:frameImage];
//        frameView.frame = frame;
//        frameView.tag = AVATAR_FRAME_TAG;
//        [[imageView viewWithTag:AVATAR_FRAME_TAG] removeFromSuperview];
//        [imageView addSubview:frameView];     
//        [imageView sendSubviewToBack:frameView];
//        [frameView release];

    }
    
    // clean other label display and avatar
    for (int i=startTag; i<=endTag; i++){
        UILabel* label = (UILabel*)[self.view viewWithTag:startTag++];
        [label setText:@""];
    }
    
    // clean other image display
    for (int i=imageStartTag; i<=imageEndTag; i++){
        AvatarView* imageView = (AvatarView*)[self.view viewWithTag:imageStartTag++];
        [imageView setImage:nil];
        [imageView setUserId:nil];
        [imageView setHasPen:NO];
        [imageView setAvatarSelected:NO];
        
        [[imageView viewWithTag:AVATAR_FRAME_TAG] removeFromSuperview];
    }
    
    [self updateStartButton];
}

- (void)updatePopupButtonInset:(BOOL)isImage
{
    if (isImage) {
        if ([DeviceDetection isIPAD]) {
            [popupButton setContentEdgeInsets:UIEdgeInsetsMake(13 * 2, 0, 0, 0)];
        }else {
            [popupButton setContentEdgeInsets:UIEdgeInsetsMake(13, 0, 0, 0)];
        }
        
    }else{
        if ([DeviceDetection isIPAD]) {
            [popupButton setContentEdgeInsets:UIEdgeInsetsMake(8 * 2, 0, 0, 0)];
        }else {
            [popupButton setContentEdgeInsets:UIEdgeInsetsMake(8, 0, 0, 0)];
        }
    }
}

- (void)updateRoomInfo
{
    // update room name
    NSString* name = nil;
    if (_isFriendRoom == NO){
        name = [NSString stringWithFormat:NSLS(@"kRoomName"),  
                      [[[DrawGameService defaultService] session] roomName]];
    }
    else{
        name = [[[DrawGameService defaultService] session] roomName];
    }
    self.roomNameLabel.text = name;
    
    // update room left/right button
    if (_isFriendRoom){
        self.changeRoomButton.hidden = YES;
        self.onlinePlayerCountLabel.hidden = YES;
    }
    else{
        self.changeRoomButton.hidden = NO;
        self.onlinePlayerCountLabel.hidden = NO;
    }
}

- (void)updateStartButton
{
    if ([self isMyTurn]){
        NSString* title = [NSString stringWithFormat:NSLS(@"kClickToStart"), _currentTimeCounter];                           
        [self.startGameButton setTitle:title forState:UIControlStateNormal];
        [self.startGameButton setEnabled:YES];
        _hasClickStartGame = NO; // add by Gamy
        [self.prolongButton setTitle:NSLS(@"kWaitABit") forState:UIControlStateNormal];
    }
    else{
        NSString* title = [NSString stringWithFormat:NSLS(@"kStartAfter"), _currentTimeCounter];                           
        [self.startGameButton setTitle:title forState:UIControlStateNormal];
        [self.startGameButton setEnabled:NO];

        [self.prolongButton setTitle:NSLS(@"kQuickQuick") forState:UIControlStateNormal];
    }
    
    // one user cannot start...
    if ([self userCount] <= 1){
        [self.startGameButton setTitle:NSLS(@"kWaitForMoreUsers") forState:UIControlStateNormal];
        [self.startGameButton setEnabled:NO];     
        
        [self.prolongButton setHidden:YES];
    }
    else{
        [self.prolongButton setHidden:NO];
    }
}

- (NSInteger)userCount
{
    GameSession* session = [[DrawGameService defaultService] session];
    NSArray* userList = [session userList];
    return [userList count];
}


//- (AvatarView *)userAvatarForUserId:(NSString *)userId
//{
//    GameSession* session = [[DrawGameService defaultService] session];
//    NSArray* userList = [session userList];
//
//    int imageStartTag = 31;
//    
//    for (GameSessionUser* user in userList){
//        AvatarView *imageView = (AvatarView *)[self.view 
//                                                         viewWithTag:imageStartTag ++];
//        if([user.userId isEqualToString:userId]){
//            return imageView;
//        }
//    }
//    return nil;
//
//}

- (NSArray*)getAvatarList
{
    int imageStartTag = 31;
    int imageEndTag = 36;
    
    NSMutableArray *avatarList = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = imageStartTag; i <= imageEndTag; i++) {
        [avatarList addObject:[self.view viewWithTag:i]];
    }
    
    return avatarList;
}

- (AvatarView *)userAvatarForUserId:(NSString *)userId avatarList:(NSArray*)avatarList
{
    for (AvatarView *avatar in avatarList) {
        if ([avatar.userId isEqualToString:userId]) {
            return avatar;
        } 
    }
    
    return nil;
}

//- (void)userId:(NSString *)userId popupMessage:(NSString *)message
//{
//    AvatarView *player = [self userAvatarForUserId:userId];
//    if (player == nil) {
//        return;
//    }
//    CGFloat x = player.frame.origin.x;
//    CGFloat y = player.frame.origin.y + player.frame.size.height;
//    
//    CGSize size = [message sizeWithFont:popupButton.titleLabel.font];
//    if ([DeviceDetection isIPAD]) {
//        [popupButton setFrame:CGRectMake(x, y, size.width + 20 * 2, size.height + 15 * 2)];        
//    }else{
//        [popupButton setFrame:CGRectMake(x, y, size.width + 20, size.height + 15)];
//    }
//    [popupButton setTitle:message forState:UIControlStateNormal];
//    [popupButton setImage:nil forState:UIControlStateNormal];
//    [self updatePopupButtonInset:NO];
//    [popupButton setHidden:NO];
//    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:5];
//    [popupButton.layer addAnimation:animation forKey:@"DismissAnimation"];
//}

//- (void)userId:(NSString *)userId popupImage:(UIImage *)image title:(NSString*)title
//{    
//    AvatarView *player = [self userAvatarForUserId:userId avatarList:[self getAvatarList]];
//
//    if (player == nil) {
//        return;
//    }
//    CGFloat x = player.frame.origin.x;
//    CGFloat y = player.frame.origin.y + player.frame.size.height;
//    
//    CGSize size = [image size];
//    if ([DeviceDetection isIPAD]) {
//        [popupButton setFrame:CGRectMake(x, y, size.width + 30 * 2, size.height + 25 * 2)];        
//    }else{
//        [popupButton setFrame:CGRectMake(x, y, size.width + 30, size.height + 25)];
//    }
//    [popupButton setImage:image forState:UIControlStateNormal];
//    [popupButton setTitle:title forState:UIControlStateNormal];
//    [self updatePopupButtonInset:YES];
//    [popupButton setHidden:NO];
//    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:5];
//    [popupButton.layer addAnimation:animation forKey:@"DismissAnimation"];
//    [self.view bringSubviewToFront:popupButton];
//}


#pragma mark - Draw Game Service Delegate

- (void)didJoinGame:(GameMessage *)message
{
    [self hideActivity];
    if ([message resultCode] == 0){
        [self popupMessage:NSLS(@"kJoinGameSucc") title:nil];
    }
    else{
        [self popupMessage:NSLS(@"kJoinGameFailure") title:nil];
    }

    // update 
    [self updateGameUsers];
    [self updateRoomInfo];    
    [self updateOnlineUserLabel];
    if ([self userCount] > 1) {
        [self scheduleStartTimer];        
    }else{
        [self resetStartTimer];
    }
}

- (void)didStartGame:(GameMessage *)message
{    
    _hasClickStartGame = NO;
    [self hideActivity];
    [self updateGameUsers];
    
    if ([message resultCode] != 0){
        PPDebug(@"Start Game Failure Code=%d", [message resultCode]);
        [self popupHappyMessage:NSLS(@"kFailStartGame") title:@""];
        [self quitRoom];
        return;
    }
    
    [self popupHappyMessage:@"Start Game OK!" title:@""];
    [self resetStartTimer];
    
    SelectWordController *sw = [[SelectWordController alloc] init];
    [self.navigationController pushViewController:sw animated:NO];
    [sw release];    

}

- (void)showDrawViewController:(BOOL)animated
{
    if (![self isMyTurn]) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[ShowDrawController class]]) {
                return;
            }
        }
        ShowDrawController *controller = [[ShowDrawController alloc] init];
        [self.navigationController pushViewController:controller animated:animated];
        [controller release];
    }
}

- (void)didGameStart:(GameMessage *)message
{
    PPDebug(@"<RoomController>:didGameStart");
    [self resetStartTimer];    
    _hasClickStartGame = NO;
    [self updateGameUsers];    
    [self showDrawViewController:YES];
}

- (void)didGameTurnComplete:(GameMessage*)message
{
    PPDebug(@"<RoomController>:didGameTurnComplete");
    [self updateGameUsers];
    [self updateOnlineUserLabel];
    
}

- (void)didNewUserJoinGame:(GameMessage *)message
{
    [[AudioManager defaultManager] playSoundById:ENTER_ROOM];
    [self updateGameUsers]; 
    [self updateOnlineUserLabel];

    if (self.startTimer == nil && [self userCount] > 1) {
        [self scheduleStartTimer];
    }
}

- (void)didUserQuitGame:(GameMessage *)message
{
    [self updateGameUsers];   
    [self updateOnlineUserLabel];

    if ([self userCount] > 1) {
        [self scheduleStartTimer];        
    }else{
        [self resetStartTimer];
    }
   
}

//just for the wait and quit message
//- (void)userId:(NSString *)userId says:(NSString *)message
//{
//    NSString *nickName = [[[DrawGameService defaultService] session] getNickNameByUserId:userId];
//    NSString *text = [NSString stringWithFormat:message,nickName];
//    [self popupUnhappyMessage:text title:nil];    
//    [self popupMessage:message title:userId];
//    [self userId:userId popupMessage:message];
    //NSLS("kQuickMessage")
//}

- (void)didGameAskQuick:(GameMessage *)message
{  
    [self updateOnlineUserLabel];
    
    if (![[[DrawGameService defaultService] userId] isEqualToString:[message userId]]) {
        [self showChatMessageViewOnUser:[message userId] title:nil message:NSLS(@"kQuickMessage")];
        [[AudioManager defaultManager] playSoundById:QUICK_QUICK];
    }

}

- (void)didGameReceiveChat:(GameMessage *)message
{
    NSString* content = [[message notification] chatContent];
    GameChatType chatType = [[message notification] chatType];
    
    if (chatType == GameChatTypeChatGroup) {
        if ([content hasPrefix:EXPRESSION_CHAT]) {
            NSString *key = [content stringByReplacingOccurrencesOfString:EXPRESSION_CHAT withString:NSLS(@"")];
            UIImage *image = [[ExpressionManager defaultManager] expressionForKey:key];  
            [self showChatMessageViewOnUser:[message userId] title:NSLS(@"kSayToAll") expression:image];
        }else if ([content hasPrefix:NORMAL_CHAT]) {
            NSString *msg = [content stringByReplacingOccurrencesOfString:NORMAL_CHAT withString:NSLS(@"")];
            [self showChatMessageViewOnUser:[message userId] title:NSLS(@"kSayToAll") message:msg];
        }
    }else {
        if ([content hasPrefix:EXPRESSION_CHAT]) {
            NSString *key = [content stringByReplacingOccurrencesOfString:EXPRESSION_CHAT withString:NSLS(@"")];
            UIImage *image = [[ExpressionManager defaultManager] expressionForKey:key]; 
            [self showChatMessageViewOnUser:[message userId] title:NSLS(@"kSayToYou") expression:image];
        }else if ([content hasPrefix:NORMAL_CHAT]) {
            NSString *msg = [content stringByReplacingOccurrencesOfString:NORMAL_CHAT withString:NSLS(@"")];
            [self showChatMessageViewOnUser:[message userId] title:NSLS(@"kSayToYou") message:msg];
        }
    }
}

- (void)didGameProlong:(GameMessage *)message
{
    [self updateOnlineUserLabel];
    
    if (![[[DrawGameService defaultService] userId] isEqualToString:[message userId]]) {
        [self prolongStartTimer];
        [self showChatMessageViewOnUser:[message userId] title:nil message:NSLS(@"kWaitMessage")];
        [[AudioManager defaultManager] playSoundById:WAIT_WAIT];
    }
}

#pragma mark - Core Methods

- (void)joinGame
{
    [self showActivityWithText:NSLS(@"kJoining")];
    
    [[DrawGameService defaultService] setRoomDelegate:self];
    [[DrawGameService defaultService] registerObserver:self];
    PPDebug(@"<registerObserver> room controller");
    
    [[DrawGameService defaultService] joinGame:[_userManager userId]
                                      nickName:[_userManager nickName] 
                                        avatar:[_userManager avatarURL] 
                                        gender:[_userManager isUserMale] 
                                      location:[_userManager location]                                    
                                guessDiffLevel:[ConfigManager guessDifficultLevel]
                                   snsUserData:[_userManager snsUserData]];
    
}

- (void)startGame
{
    if (_hasClickStartGame){
        return;
    }
    
    [self resetStartTimer];
    
    _hasClickStartGame = YES;
    [self showActivityWithText:NSLS(@"kStartingGame")];
    [[DrawGameService defaultService] startGame];    
}

- (BOOL)isMyTurn
{
    return [[DrawGameService defaultService] isMyTurn];
}

- (void)quitRoom
{
    [[DrawGameService defaultService] quitGame];
    [self.navigationController popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];             
}
         
         
#pragma mark - Dialog Delegates

- (void)clickOk:(CommonDialog *)dialog
{
    switch (dialog.tag) {
        case ROOM_DIALOG_CHANGE_ROOM:
        {
            _changeRoomTimes ++;
            [self showActivityWithText:NSLS(@"kChangeRoom")];
            if (_changeRoomTimes >= MAX_CHANGE_ROOM_PER_DAY){
                [[AccountService defaultService] deductAccount:1 source:ChangeRoomType];
            }
            [[DrawGameService defaultService] changeRoom];            
        }
            break;
        
        case ROOM_DIALOG_QUIT_ROOM:
        {
            [self quitRoom];
//            [[DrawGameService defaultService] quitGame];
//            [self.navigationController popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];            
        }
            break;
        
        default:
            break;
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}


#pragma mark - Button Click Action

- (IBAction)clickStart:(id)sender
{
    [self startGame];
}



- (IBAction)clickChangeRoom:(id)sender
{
    // update data before change room
    [[DrawGameService defaultService] setNickName:[_userManager nickName]];
    [[DrawGameService defaultService] setAvatar:[_userManager avatarURL]];
    [[DrawGameService defaultService] setGender:[_userManager isUserMale]];
    [[DrawGameService defaultService] setGuessDiffLevel:[ConfigManager guessDifficultLevel]];
    
    if (_changeRoomTimes >= MAX_CHANGE_ROOM_PER_DAY){
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"Message") 
                                                           message:NSLS(@"kChangeRoomMaxTimes") 
                                                             style:CommonDialogStyleDoubleButton 
                                                         delegate:self];
        
        dialog.tag = ROOM_DIALOG_CHANGE_ROOM;
        [dialog showInView:self.view];
        return;
    }
    else{
    
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kChangeRoomTitle") 
                                    message:NSLS(@"kChangeRoomConfirm") 
                                      style:CommonDialogStyleDoubleButton 
                                  delegate:self];
        dialog.tag = ROOM_DIALOG_CHANGE_ROOM;
        [dialog showInView:self.view];
    }
    
    
}

- (IBAction)clickProlongStart:(id)sender
{
    if ([self isMyTurn]){
        if (_clickCount <= MAX_CLICK_COUNT){
            [self prolongStartTimer];
            _clickCount ++;
            [self showChatMessageViewOnUser:[[DrawGameService defaultService] userId] title:nil message:NSLS(@"kWaitMessage")];
        }
        else{
            [self popupMessage:NSLS(@"kExceedMaxProlongTimes") title:nil];
        }
    }
    else{
        [[DrawGameService defaultService] askQuickGame];            
        [self showChatMessageViewOnUser:[[DrawGameService defaultService] userId] title:nil message:NSLS(@"kQuickMessage")];
    }
}

- (IBAction)clickGroupChat:(id)sender {
    if (_groupChatController == nil) {
        _groupChatController = [[ChatController alloc] initWithChatType:GameChatTypeChatGroup];
    }
    _groupChatController.chatControllerDelegate = self;
    
    [_groupChatController showInView:self.view messagesType:RoomMessages selectedUserId:nil needAnimation:YES];
}

- (IBAction)clickPrivateChat:(id)sender {
    if (_privateChatController == nil) {
        _privateChatController = [[ChatController alloc] initWithChatType:GameChatTypeChatPrivate];
    }
    _privateChatController.chatControllerDelegate = self;
   
    [_privateChatController showInView:self.view messagesType:RoomMessages selectedUserId:nil needAnimation:YES];
}

- (IBAction)clickMenu:(id)sender
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameTitle") 
                                message:NSLS(@"kQuitGameConfirm") 
                                  style:CommonDialogStyleDoubleButton
                              delegate:self];
    dialog.tag = ROOM_DIALOG_QUIT_ROOM;
    [dialog showInView:self.view];
    
}

#pragma mark - Room Enter/Return

+ (RoomController*)defaultInstance
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.roomController == nil){    
        app.roomController = [[[RoomController alloc] init] autorelease];
    }
    
    return app.roomController;
}

+ (void)firstEnterRoom:(UIViewController*)superController
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.roomController == nil){    
        app.roomController = [[[RoomController alloc] init] autorelease];
    }
            
    [[app.roomController.view viewWithTag:ROOM_DIALOG_QUIT_ROOM] removeFromSuperview];
    [[app.roomController.view viewWithTag:ROOM_DIALOG_CHANGE_ROOM] removeFromSuperview];

    [superController.navigationController pushViewController:app.roomController 
                           animatedWithTransition:UIViewAnimationTransitionCurlUp];
    
    // update 
    if ([app.roomController userCount] > 1) {
        [app.roomController scheduleStartTimer];        
    }else{
        [app.roomController resetStartTimer];
    }    
    
    
    [app.roomController setClickCount:0];
    [app.roomController updateGameUsers];
    [app.roomController updateRoomInfo];            
}

+ (void)enterRoom:(UIViewController*)superController isFriendRoom:(BOOL)isFriendRoom
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.roomController == nil){    
        // first time enter room
        app.roomController = [[[RoomController alloc] init] autorelease];
        [app.roomController setIsFriendRoom:isFriendRoom];        
        [RoomController firstEnterRoom:superController];
        return;
    }
    
    // set friend room flag
    [app.roomController setIsFriendRoom:isFriendRoom];        
    
    if ([superController.navigationController.viewControllers containsObject:app.roomController]){
        // room controller exists in root view controllers
        [RoomController returnRoom:superController startNow:NO];
    }
    else{
        // room controller doesn't exist in navigation contoller view layers        
        [RoomController firstEnterRoom:superController];
    }
}

+ (void)returnRoom:(UIViewController*)superController startNow:(BOOL)startNow
{
    RoomController *roomController = [RoomController defaultInstance];
    [superController.navigationController popToViewController:roomController animated:NO];
    
    [roomController setClickCount:0];

    [[roomController.view viewWithTag:ROOM_DIALOG_QUIT_ROOM] removeFromSuperview];
    [[roomController.view viewWithTag:ROOM_DIALOG_CHANGE_ROOM] removeFromSuperview];
    
    if (startNow) {
        [roomController showDrawViewController:NO];
        return;
    }
    
    if ([roomController userCount] > 1) {
        [roomController scheduleStartTimer];        
    }else
    {
        [roomController resetStartTimer];        
    }

}

#pragma mark - Timer Handling

#define START_TIMER_INTERVAL            (1)
#define PROLONG_INTERVAL                (10)
#define DEFAULT_START_TIME_FOR_DRAW     (20)
#define DEFAULT_START_TIME_FOR_GUESS    (30)

- (void)resetStartTimer
{
    if ([self isMyTurn]){
        _currentTimeCounter = DEFAULT_START_TIME_FOR_DRAW;
    }
    else{
        _currentTimeCounter = DEFAULT_START_TIME_FOR_GUESS;
    }
    
    [self updateStartButton];
    if (self.startTimer != nil){
        if ([self.startTimer isValid]){
            [self.startTimer invalidate];
        }
        
        self.startTimer = nil;
    }
}

- (void)scheduleStartTimer
{
    [self resetStartTimer];
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:START_TIMER_INTERVAL
                                                       target:self 
                                                     selector:@selector(handleStartTimer:) 
                                                     userInfo:nil 
                                                      repeats:YES];
}

- (void)prolongStartTimer
{
    _currentTimeCounter += PROLONG_INTERVAL;
    if (_currentTimeCounter >= DEFAULT_START_TIME_FOR_DRAW){
        _currentTimeCounter = DEFAULT_START_TIME_FOR_DRAW;
    }
    
    // notice all other users
    if ([self isMyTurn]){
        [[DrawGameService defaultService] prolongGame];
    }
}

- (void)handleStartTimer:(id)sender
{
    PPDebug(@"<handleStartTimer> fire start game timer");
    
    _currentTimeCounter --;
    [self updateStartButton];    

    if (_currentTimeCounter <= 0){
        // start game directly!
        if ([self isMyTurn]){
            [self resetStartTimer];
            [self startGame];
        }
        else{
            // if you are not host, you have to wait again...
            [self scheduleStartTimer];
        }
    }
}

#pragma mark - Chat Handling

- (void)didSelectMessage:(NSString *)message toUser:(NSString *)userNickName
{
    if ([message isEqualToString:NSLS(@"kWaitABit")] || [message isEqualToString:NSLS(@"kQuickQuick")]){
        [self clickProlongStart:nil];
    }else {
        NSString *title = [NSString stringWithFormat:NSLS(@"kSayToXXX"), userNickName];
        [self showChatMessageViewOnUser:[[DrawGameService defaultService] userId] title:title message:message];
    }
}

- (void)didSelectExpression:(UIImage *)expression toUser:(NSString *)userNickName
{
    NSString *title = [NSString stringWithFormat:NSLS(@"kSayToXXX"), userNickName];
    [self showChatMessageViewOnUser:[[DrawGameService defaultService] userId] title:title expression:expression];
}

- (void)didClickOnAvatar:(NSString*)userId
{
    if (userId == nil || [[UserManager defaultManager] isMe:userId]) {
        return;
    }
    
    if (_privateChatController == nil) {
        self.privateChatController = 
        [[[ChatController alloc] initWithChatType:GameChatTypeChatPrivate] autorelease];
    }
    _privateChatController.chatControllerDelegate = self;
    
    [_privateChatController showInView:self.view messagesType:RoomMessages selectedUserId:userId needAnimation:YES];
}

- (void)showChatMessageViewOnUser:(NSString*)userId title:(NSString*)title message:(NSString*)message
{
    AvatarView *player = [self userAvatarForUserId:userId avatarList:[self getAvatarList]];
    CGPoint origin = CGPointMake(player.frame.origin.x-15, player.frame.origin.y+player.frame.size.height);
    [ChatMessageView showMessage:message title:title origin:origin superView:self.view];
}

- (void)showChatMessageViewOnUser:(NSString*)userId title:(NSString*)title expression:(UIImage*)expression
{
    AvatarView *player = [self userAvatarForUserId:userId avatarList:[self getAvatarList]];
    CGPoint origin = CGPointMake(player.frame.origin.x, player.frame.origin.y+player.frame.size.height);
    
    [ChatMessageView showExpression:expression title:title origin:origin superView:self.view];
}

@end
