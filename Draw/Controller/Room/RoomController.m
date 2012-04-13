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
#import "HJManagedImageV.h"
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

@interface RoomController ()

- (void)updateGameUsers;
- (void)updateRoomName;
- (void)updateStartButton;

- (void)resetStartTimer;
- (void)scheduleStartTimer;
- (void)prolongStartTimer;

- (BOOL)isMyTurn;
- (NSInteger)userCount;

@end

@implementation RoomController

@synthesize prolongButton = _prolongButton;
@synthesize roomNameLabel;
@synthesize startGameButton;
@synthesize startTimer = _startTimer;
@synthesize clickCount = _clickCount;


#define QUICK_DURATION  2
#define MAX_CLICK_COUNT 5   

- (void)dealloc {
    [_startTimer release];
    [startGameButton release];
    [roomNameLabel release];
    [_prolongButton release];
    [popupButton release];
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
    [popupButton setBackgroundImage:[[ShareImageManager defaultManager] popupImage] 
                                forState:UIControlStateNormal];
    [popupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidAppear:(BOOL)animated
{    
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    
    [[DrawGameService defaultService] registerObserver:self];
    [[DrawGameService defaultService] setRoomDelegate:self];
    [self updateGameUsers];
    [self updateRoomName];
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
    PPDebug(@"<unregisterObserver> room controller");
}

- (void)viewDidUnload
{
    [[DrawGameService defaultService] unregisterObserver:self];
    [self setStartGameButton:nil];
    [self setRoomNameLabel:nil];
    [self setProlongButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GUI Update Methods
#define DRAWING_MARK_TAG    20120404
#define AVATAR_FRAME_TAG    20120406

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
        HJManagedImageV* imageView = (HJManagedImageV*)[self.view viewWithTag:imageStartTag++];
        [imageView clear];
        imageView.hidden = NO;
        
        NSString* avatar = nil;
        BOOL isMe = [session isMe:[user userId]];
        if (isMe){
            avatar = [[UserManager defaultManager] avatarURL];
        }
        else{
            avatar = [user userAvatar];
        }   
        
        if ([avatar length] > 0){            
            [imageView setUrl:[NSURL URLWithString:avatar]];
        }else{
            if (isMe){
                [imageView setImage:[[UserManager defaultManager] avatarImage]];
            }
            else{
                if ([user gender])
                    [imageView setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
                else
                    [imageView setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
            }
        }
        
        [GlobalGetImageCache() manage:imageView];
        
        UIView *view = [imageView viewWithTag:DRAWING_MARK_TAG];
        [view removeFromSuperview];
                
        UIImage* frameImage = nil;
        
        if ([[[DrawGameService defaultService] session] isCurrentPlayUser:user.userId]) {
            UIImage *drawingMark = [[ShareImageManager defaultManager] drawingMarkLargeImage];
            UIImageView *drawingImageView = [[UIImageView alloc] initWithImage:drawingMark];
            [drawingImageView setFrame:CGRectMake(40, 40, 25, 25)];
            drawingImageView.tag = DRAWING_MARK_TAG;
            [imageView addSubview:drawingImageView];
            [drawingImageView release];
            
            frameImage = [[ShareImageManager defaultManager] avatarSelectImage];
        }
        else{
            
            frameImage = [[ShareImageManager defaultManager] avatarUnSelectImage];            
        }
        
        // create image view
        CGRect frame = imageView.bounds;
        frame.origin.x = -3;
        frame.origin.y = -3;
        frame.size.width += 6;
        frame.size.height += 10;
        UIImageView *frameView = [[UIImageView alloc] initWithImage:frameImage];
        frameView.frame = frame;
        frameView.tag = AVATAR_FRAME_TAG;
        [[imageView viewWithTag:AVATAR_FRAME_TAG] removeFromSuperview];
        [imageView addSubview:frameView];     
        [imageView sendSubviewToBack:frameView];
        [frameView release];

    }
    
    // clean other label display
    for (int i=startTag; i<=endTag; i++){
        UILabel* label = (UILabel*)[self.view viewWithTag:startTag++];
        [label setText:@""];
    }
    
    // clean other image display
    for (int i=imageStartTag; i<=imageEndTag; i++){
        HJManagedImageV* imageView = (HJManagedImageV*)[self.view viewWithTag:imageStartTag++];
        [imageView clear];
        imageView.hidden = YES;
        UIView *view = [imageView viewWithTag:DRAWING_MARK_TAG];
        [view removeFromSuperview];
        
        [[imageView viewWithTag:AVATAR_FRAME_TAG] removeFromSuperview];
    }
    
    [self updateStartButton];
}

- (void)updateRoomName
{
    NSString* name = [NSString stringWithFormat:NSLS(@"kRoomName"),  
                      [[[DrawGameService defaultService] session] roomName]];
    self.roomNameLabel.text = name;
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


- (HJManagedImageV *)userAvatarForUserId:(NSString *)userId
{
    GameSession* session = [[DrawGameService defaultService] session];
    NSArray* userList = [session userList];

    int imageStartTag = 31;
    
    for (GameSessionUser* user in userList){
        HJManagedImageV *imageView = (HJManagedImageV *)[self.view 
                                                         viewWithTag:imageStartTag ++];
        if([user.userId isEqualToString:userId]){
            return imageView;
        }
    }
    return nil;

}

- (void)userId:(NSString *)userId popupMessage:(NSString *)message
{
    
    HJManagedImageV *player = [self userAvatarForUserId:userId];
    if (player == nil) {
        return;
    }
    CGFloat x = player.frame.origin.x;
    CGFloat y = player.frame.origin.y + player.frame.size.height;

    
    CGFloat fontSize = 18;    
    [popupButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]];
    [popupButton setFrame:CGRectMake(x, y, size.width + 20, size.height + 15)];
    [popupButton setTitle:message forState:UIControlStateNormal];
    [popupButton setHidden:NO];
    UIEdgeInsets inSets = UIEdgeInsetsMake(8, 0, 0, 0);
    [popupButton setTitleEdgeInsets:inSets];
    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:5];
    [popupButton.layer addAnimation:animation forKey:@"DismissAnimation"];
}

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
    [self updateRoomName];    
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
        [self popupHappyMessage:[NSString stringWithFormat:@"Start Game Fail, Code = %d", [message resultCode]] title:@""];
        return;
    }
    
    [self popupHappyMessage:@"Start Game OK!" title:@""];
    [self resetStartTimer];
    
    SelectWordController *sw = [[SelectWordController alloc] init];
    [self.navigationController pushViewController:sw animated:NO];
    [sw release];    

}

- (void)showDrawViewController
{
    if (![self isMyTurn]) {
        [ShowDrawController startGuessFromController:self];
    }
}

- (void)didGameStart:(GameMessage *)message
{
    PPDebug(@"<RoomController>:didGameStart");
    [self resetStartTimer];    
    _hasClickStartGame = NO;
    [self updateGameUsers];    
    [self showDrawViewController];
}

- (void)didGameTurnComplete:(GameMessage*)message
{
    PPDebug(@"<RoomController>:didGameTurnComplete");
    [self updateGameUsers];
}

- (void)didNewUserJoinGame:(GameMessage *)message
{
    [self updateGameUsers];    
    if (self.startTimer == nil && [self userCount] > 1) {
        [self scheduleStartTimer];
    }
}

- (void)didUserQuitGame:(GameMessage *)message
{
    [self updateGameUsers];    
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
    if (![[[DrawGameService defaultService] userId] isEqualToString:[message userId]]) {
//        [self userId:[message userId] says:(NSLS(@"kQuickMessage"))];         
        [self userId:[message userId] popupMessage:(NSLS(@"kQuickMessage"))];         

    }

}

- (void)didGameProlong:(GameMessage *)message
{
    if (![[[DrawGameService defaultService] userId] isEqualToString:[message userId]]) {
//        [self userId:[message userId] says:(NSLS(@"kWaitMessage"))];   
        [self prolongStartTimer];
        [self userId:[message userId] popupMessage:(NSLS(@"kWaitMessage"))];         
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
                                        gender:[_userManager isUserMale]];
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


#pragma mark - Dialog Delegates

- (void)clickOk:(CommonDialog *)dialog
{
    switch (dialog.tag) {
        case ROOM_DIALOG_CHANGE_ROOM:
        {
            _changeRoomTimes ++;
            [self showActivityWithText:NSLS(@"kChangeRoom")];
//            [[AccountService defaultService] deductAccount:1 source:ChangeRoomType];
            [[DrawGameService defaultService] changeRoom];            
        }
            break;
        
        case ROOM_DIALOG_QUIT_ROOM:
        {
            [[DrawGameService defaultService] quitGame];
            [self.navigationController popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];            
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

#define MAX_CHANGE_ROOM_PER_DAY     5

- (IBAction)clickChangeRoom:(id)sender
{
    if (_changeRoomTimes > MAX_CHANGE_ROOM_PER_DAY){
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"Message") 
                                                           message:NSLS(@"kChangeRoomMaxTimes") 
                                                             style:CommonDialogStyleSingleButton 
                                                         deelegate:self];
        
        [dialog showInView:self.view];
        return;
    }
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kChangeRoomTitle") 
                                message:NSLS(@"kChangeRoomConfirm") 
                                  style:CommonDialogStyleDoubleButton 
                              deelegate:self];
    dialog.tag = ROOM_DIALOG_CHANGE_ROOM;
    [dialog showInView:self.view];
    
    
}

- (IBAction)clickProlongStart:(id)sender
{
    time_t currentTime = time(0);
    if ([self isMyTurn]){
        if (currentTime - quickDuration > QUICK_DURATION) {
            if (_clickCount <= MAX_CLICK_COUNT){
                [self prolongStartTimer];
                quickDuration = currentTime;
                _clickCount ++;
            }
            else{
                [self popupMessage:NSLS(@"kExceedMaxProlongTimes") title:nil];
            }
        }else{
            [self popupMessage:NSLS(@"kClickTooFast") title:nil];
        }
    }
    else{
        // TODO send an urge request
        if (currentTime - quickDuration > QUICK_DURATION) {
            [[DrawGameService defaultService] askQuickGame];            
            quickDuration = currentTime;
        }else{
            [self popupMessage:NSLS(@"kClickTooFast") title:nil];
        }

    }
}

- (IBAction)clickMenu:(id)sender
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameTitle") 
                                message:NSLS(@"kQuitGameConfirm") 
                                  style:CommonDialogStyleDoubleButton
                              deelegate:self];
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
    [app.roomController updateRoomName];            
}

+ (void)returnRoom:(UIViewController*)superController startNow:(BOOL)startNow
{
    RoomController *roomController = [RoomController defaultInstance];
    [superController.navigationController popToViewController:roomController animated:NO];
    
    [roomController setClickCount:0];

    [[roomController.view viewWithTag:ROOM_DIALOG_QUIT_ROOM] removeFromSuperview];
    [[roomController.view viewWithTag:ROOM_DIALOG_CHANGE_ROOM] removeFromSuperview];
    
    if (startNow) {
//        [roomController performSelector:@selector(showDrawViewController) withObject:nil afterDelay:0.0f];
        [roomController showDrawViewController];
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

#define START_TIMER_INTERVAL    (1)
#define PROLONG_INTERVAL        (10)
#define DEFAULT_START_TIME      (20)

- (void)resetStartTimer
{
    _currentTimeCounter = DEFAULT_START_TIME;
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
    if (_currentTimeCounter >= DEFAULT_START_TIME){
        _currentTimeCounter = DEFAULT_START_TIME;
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

@end
