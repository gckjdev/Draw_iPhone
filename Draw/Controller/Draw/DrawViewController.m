//
//  DrawViewController.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"
#import "DrawGameService.h"
#import "DrawColor.h"
#import "GameMessage.pb.h"
#import "Word.h"
#import "GameSessionUser.h"
#import "GameSession.h"
#import "LocaleUtils.h"
#import "AnimationManager.h"
#import "ResultController.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "RoomController.h"
#import "ShowDrawController.h"
#import "ShareImageManager.h"
#import "ColorView.h"
#import "UIButtonExt.h"
#import "HomeController.h"
#import "StableView.h"
#import "PPDebug.h"
#import "AccountManager.h"
#import "AccountService.h"

DrawViewController *staticDrawViewController = nil;
DrawViewController *GlobalGetDrawViewController()
{
    if (staticDrawViewController == nil) {
        staticDrawViewController = [[DrawViewController alloc] init];
    }
    return staticDrawViewController;
}

@implementation DrawViewController
@synthesize turnNumberButton;
@synthesize popupButton;
@synthesize eraserButton;
@synthesize wordButton;
@synthesize clockButton;
@synthesize cleanButton;
@synthesize penButton;
@synthesize word = _word;
@synthesize needResetData;

#define DRAW_TIME 60
#define PAPER_VIEW_TAG 20120403


#pragma mark - Static Method
+ (DrawViewController *)instance
{
    return GlobalGetDrawViewController();
}

+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController
{
    DrawViewController *vc = [DrawViewController instance];
    vc.word = word;
    int language = [[UserManager defaultManager] getLanguageType];
    vc.needResetData = YES;
    [[DrawGameService defaultService] startDraw:word.text level:word.level language:language];
    [fromController.navigationController pushViewController:vc animated:NO];            
}

+ (void)returnFromController:(UIViewController*)fromController
{
    DrawViewController *vc = [DrawViewController instance];
    vc.needResetData = NO;
    [fromController.navigationController popToViewController:vc animated:YES];
    
}
- (void)dealloc
{

    [_word release];
    [eraserButton release];
    [wordButton release];
    [clockButton release];
    [cleanButton release];
    [penButton release];
    [pickPenView release];
    [popupButton release];
    [turnNumberButton release];
    [avatarArray release];
    [drawView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - Construction

- (id)init{
    self = [super init];
    if (self) {
        drawGameService = [DrawGameService defaultService];
        drawView = [[DrawView alloc] initWithFrame:CGRectMake(8, 46, 304, 320)];   
        pickPenView = [[PickPenView alloc] initWithFrame:CGRectMake(8, 250, 302, 122)];
        avatarArray = [[NSMutableArray alloc] init];
        shareImageManager = [ShareImageManager defaultManager];
        [pickPenView setImage:[shareImageManager toolPopupImage]];
        pickPenView.delegate = self;
        drawGameService.drawDelegate = self;
    }
    return self;
}


- (void)initPickPenView
{
    [self.view addSubview:pickPenView];
    NSMutableArray *widthArray = [[NSMutableArray alloc] init];
    NSMutableArray *colorViewArray = [[NSMutableArray alloc] init];
    for (int i = 20; i >= 5 ;i -= 5) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [widthArray addObject:number];
    }
    [pickPenView setLineWidths:widthArray];
    [widthArray release];
    
    [colorViewArray addObject:[ColorView blackColorView]];
    [colorViewArray addObject:[ColorView redColorView]];
    [colorViewArray addObject:[ColorView yellowColorView]];
    [colorViewArray addObject:[ColorView blueColorView]];
    [colorViewArray addObject:[ColorView redColorView]];
    [colorViewArray addObject:[ColorView yellowColorView]];
    [colorViewArray addObject:[ColorView blueColorView]];

    
    [pickPenView setColorViews:colorViewArray];
    [colorViewArray release];
}

#pragma mark - Timer
- (void)updateTimeButton
{
    NSString *second = [NSString stringWithFormat:@"%d",retainCount];
    [self.clockButton setTitle:second forState:UIControlStateNormal];
}

- (void)resetTimer
{
    if (drawTimer && [drawTimer isValid]) {
        [drawTimer invalidate];
    }
    drawTimer = nil;
    retainCount = DRAW_TIME;
}
- (void)handleTimer:(NSTimer *)theTimer
{
    --retainCount;
    if (retainCount <= 0) {
        [self resetTimer];
        retainCount = 0;
        [self setToolButtonEnabled:NO];
    }
    [self updateTimeButton];
}


- (void)startTimer
{
    [self resetTimer];
    [self updateTimeButton];
    drawTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}


#pragma mark - Update Data
- (void)setToolButtonEnabled:(BOOL)enabled
{
    [eraserButton setEnabled:enabled];
    [cleanButton setEnabled:enabled];
    [drawView setDrawEnabled:enabled];
    [penButton setEnabled:enabled];
    [pickPenView setHidden:YES];
}

- (NSInteger)userCount
{
    GameSession *session = [[DrawGameService defaultService] session];
    return [session.userList count];
}

- (void)cleanAvatars
{
    //remove all the old avatars
    for (AvatarView *view in avatarArray) {
        [view removeFromSuperview];
    }
    [avatarArray removeAllObjects];
    
}

- (void)updatePlayerAvatars
{
    [self cleanAvatars];
    GameSession *session = [[DrawGameService defaultService] session];
    int i = 0;
    for (GameSessionUser *user in session.userList) {
        AvatarType type = Guesser;
        if([user.userId isEqualToString:session.drawingUserId])
        {
            type = Drawer;
        }
        AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] type:type];
        [aView setUserId:user.userId];
        //set center
        aView.center = CGPointMake(70 + 36 * i, 21);
        [self.view addSubview:aView];
        [avatarArray addObject:aView];
        [aView release];
        ++ i;                                  
    }
}


- (AvatarView *)avatarViewForUserId:(NSString *)userId
{
    
    for (AvatarView *view in avatarArray) {
        if ([view.userId isEqualToString:userId]) {
            return view;
        }
    }
    return nil;
}



- (void)resetData
{
    [drawView clearAllActions];
    [popupButton setHidden:YES];
    NSString *wordText = [NSString stringWithFormat:NSLS(@"kDrawWord"),self.word.text];
    [self.wordButton setTitle:wordText forState:UIControlStateNormal];
    retainCount = DRAW_TIME;
    [self updatePlayerAvatars];
    [self startTimer];
    [self setToolButtonEnabled:YES];
    
    [self.turnNumberButton setTitle:[NSString stringWithFormat:@"%d",drawGameService.roundNumber] forState:UIControlStateNormal];
}


- (void)popGuessMessage:(NSString *)message userId:(NSString *)userId onLeftTop:(BOOL)onLeftTop
{
    AvatarView *player = [self avatarViewForUserId:userId];
    if (player == nil) {
        return;
    }
    CGFloat x = player.frame.origin.x;
    CGFloat y = player.frame.origin.y + player.frame.size.height;
    if (onLeftTop) {
        x = player.frame.origin.x;
        y = player.frame.origin.y + player.frame.size.height;
    }
    
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

- (void)popGuessMessage:(NSString *)message userId:(NSString *)userId
{
    [self popGuessMessage:message userId:userId onLeftTop:NO];
}

- (void)popUpRunAwayMessage:(NSString *)userId
{
    NSString *nickName = [[drawGameService session] getNickNameByUserId:userId];
    NSString *message = [NSString stringWithFormat:NSLS(@"kRunAway"),nickName];
    [self popGuessMessage:message userId:userId onLeftTop:YES];
}


- (void)addScore:(NSInteger)score toUser:(NSString *)userId
{
    AvatarView *avatarView = [self avatarViewForUserId:userId];
    [avatarView setScore:score];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    drawView.delegate = self;
    UIView *paperView = [self.view viewWithTag:PAPER_VIEW_TAG];
    [self.view insertSubview:drawView aboveSubview:paperView];

    [self initPickPenView];
    [self.popupButton setBackgroundImage:[shareImageManager popupImage] 
                                forState:UIControlStateNormal];
    [self.view bringSubviewToFront:wordButton];
    [self.view bringSubviewToFront:popupButton];
}

- (void)viewDidAppear:(BOOL)animated
{

    if (needResetData) {
        [self resetData];
    }
    [pickPenView setHidden:YES];
    [super viewDidAppear:animated];
    [drawGameService registerObserver:self];        
    colorShopConroller = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self resetTimer];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{

    [self setWord:nil];
    [self setEraserButton:nil];
    [self setWordButton:nil];
    [self setClockButton:nil];
    [self setCleanButton:nil];
    [self setPenButton:nil];
    [self setPopupButton:nil];
    [self setTurnNumberButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark - Draw Game Service Delegate
- (void)didReceiveGuessWord:(NSString*)wordText 
                guessUserId:(NSString*)guessUserId 
               guessCorrect:(BOOL)guessCorrect
                  gainCoins:(int)gainCoins
{
    if (![drawGameService.userId isEqualToString:guessUserId]) {
        if (!guessCorrect) {
            [self popGuessMessage:wordText userId:guessUserId];        
        }else{
            [self popGuessMessage:NSLS(@"kGuessCorrect") userId:guessUserId];
            [self addScore:gainCoins toUser:guessUserId];
        }
        
    }
}



#pragma mark - Observer Method/Game Process
- (void)didGameTurnComplete:(GameMessage *)message
{
    PPDebug(@"DrawViewController:<didGameTurnComplete>");

    UIImage *image = [drawView createImage];
    NSInteger gainCoin = [[message notification] turnGainCoins];
    ResultController *rc = [[ResultController alloc] initWithImage:image
                                                          wordText:self.word.text 
                                                             score:gainCoin                                                         correct:NO
                                                             isMyPaint:YES];
    if (colorShopConroller) {
        [colorShopConroller.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:rc animated:NO];
    }else{
        [self.navigationController pushViewController:rc animated:YES];
    }
    [rc release];
    [self resetTimer];
    
    // rem by Benson, // this will crash the app, see log below
    //  *** Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSArrayM: 0x933fb10> was mutated while being enumerated.'
    [drawGameService unregisterObserver:self];  
}

- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *userId = [message userId];
    [self popUpRunAwayMessage:userId];
    
    [self updatePlayerAvatars];
    if ([self userCount] <= 1) {
        [self popupUnhappyMessage:NSLS(@"kAllUserQuit") title:nil];        
    }
}

#pragma mark - Pick view delegate
- (void)didPickedColorView:(ColorView *)colorView
{
    [drawView setLineColor:colorView.drawColor];
}
- (void)didPickedLineWidth:(NSInteger)width
{
    [drawView setLineWidth:width];
}
- (void)didPickedMoreColor
{
    //present a buy color controller;
    ColorShopController *colorShop = [ColorShopController instanceWithDelegate:self];
    colorShop.callFromDrawView = YES;
    [self.navigationController pushViewController:colorShop animated:YES];
    colorShopConroller = colorShop;
}

#pragma mark - Common Dialog Delegate
#define ESCAPE_DEDUT_COIN 1
- (void)clickOk:(CommonDialog *)dialog
{
    [dialog removeFromSuperview];
    
    if (dialog.style == CommonDialogStyleDoubleButton && [[AccountManager defaultManager] hasEnoughBalance:1]) {
        [drawGameService quitGame];
        [HomeController returnRoom:self];
        [[AccountService defaultService] deductAccount:ESCAPE_DEDUT_COIN source:EscapeType];
    }

}
- (void)clickBack:(CommonDialog *)dialog
{
    [dialog removeFromSuperview];
}

#pragma mark - Draw View Delegate

- (void)didDrawedPaint:(Paint *)paint
{
    
    NSInteger intColor  = [DrawUtils compressDrawColor:paint.color];    
    NSMutableArray *pointList = [[[NSMutableArray alloc] init] autorelease];
    for (NSValue *pointValue in paint.pointList) {
        CGPoint point = [pointValue CGPointValue];
        NSNumber *pointNumber = [NSNumber numberWithInt:[DrawUtils compressPoint:point]];
        [pointList addObject:pointNumber];
    }
    [[DrawGameService defaultService]sendDrawDataRequestWithPointList:pointList color:intColor width:paint.width];
}

- (void)didStartedTouch
{
    [pickPenView setHidden:YES];
}


#pragma mark - Actions

- (IBAction)clickChangeRoomButton:(id)sender {
    CommonDialogStyle style;
    NSString *message = nil;
    if ([[AccountManager defaultManager] hasEnoughBalance:ESCAPE_DEDUT_COIN]) {
        style = CommonDialogStyleDoubleButton;
        message = NSLS(@"kDedutCoinQuitGameAlertMessage");
    }else{
        style = CommonDialogStyleSingleButton;
        message = NSLS(@"kNoCoinQuitGameAlertMessage");
    }

    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:message style:style deelegate:self];
    [dialog showInView:self.view];
}

- (IBAction)clickRedraw:(id)sender {
    [drawGameService cleanDraw];
    [drawView addCleanAction];
    [pickPenView setHidden:YES];
}

- (IBAction)clickEraserButton:(id)sender {
    [drawView setLineColor:[DrawColor whiteColor]];
    [pickPenView setHidden:YES];
}

- (IBAction)clickPenButton:(id)sender {
    [pickPenView setHidden:!pickPenView.hidden];
}

@end
