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
#pragma mark - View lifecycle




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
    NSString *second = [NSString stringWithFormat:@"%d",retainCount];
    [self.clockButton setTitle:second forState:UIControlStateNormal];
}


- (void)startTimer
{
    [self resetTimer];
    drawTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

- (id)init{
    self = [super init];
    if (self) {
        drawGameService = [DrawGameService defaultService];
        drawView = [[DrawView alloc] initWithFrame:CGRectMake(8, 46, 304, 355)];   
        pickPenView = [[PickPenView alloc] initWithFrame:CGRectMake(8, 285, 302, 122)];
        avatarArray = [[NSMutableArray alloc] init];
        shareImageManager = [ShareImageManager defaultManager];
        [pickPenView setImage:[shareImageManager toolPopupImage]];
        pickPenView.delegate = self;
        drawGameService.drawDelegate = self;
    }
    return self;
}

- (void)resetData
{
    [drawView clearAllActions];
    [popupButton setHidden:YES];
    [self.wordButton setTitle:self.word.text forState:UIControlStateNormal];
    retainCount = DRAW_TIME;
    NSString *second = [NSString stringWithFormat:@"%d",retainCount];
    [self.clockButton setTitle:second forState:UIControlStateNormal];
    [self updatePlayerAvatars];
    [self startTimer];
    [self setToolButtonEnabled:YES];
    [self.turnNumberButton setTitle:[NSString stringWithFormat:@"%d",drawGameService.roundNumber] forState:UIControlStateNormal];
//    gameComplete = NO;
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    drawView.delegate = self;
//    [self.view addSubview:drawView];
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

    hasPushResultController = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
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



//- (void)alert:(NSString *)message
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLS(@"kConfirm") otherButtonTitles:nil];
//    [alertView show];
//    [alertView release];
//}


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


- (void)popGuessMessage:(NSString *)message userId:(NSString *)userId
{
    AvatarView *player = [self avatarViewForUserId:userId];
    if (player == nil) {
        return;
    }
    CGFloat x = player.frame.origin.x;
    CGFloat y = player.frame.origin.y + player.frame.size.height;
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:14]];
    [popupButton setFrame:CGRectMake(x, y, size.width + 20, size.height + 15)];
    [popupButton setTitle:message forState:UIControlStateNormal];
    [popupButton setHidden:NO];
    UIEdgeInsets inSets = UIEdgeInsetsMake(7, 0, 0, 0);
    [popupButton setTitleEdgeInsets:inSets];
    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:4];
    [popupButton.layer addAnimation:animation forKey:@"DismissAnimation"];
}

- (void)popUpRunAwayMessage:(NSString *)userId
{
    AvatarView *player = [self avatarViewForUserId:userId];
    if (player == nil) {
        return;
    }
    NSString *nickName = [[drawGameService session] getNickNameByUserId:userId];
    NSString *message = [NSString stringWithFormat:NSLS(@"kRunAway"),nickName];
    CGFloat x = 8;
    CGFloat y = player.frame.origin.y + player.frame.size.height;
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:14]];
    [popupButton setFrame:CGRectMake(x, y, size.width + 20, size.height + 15)];
    [popupButton setTitle:message forState:UIControlStateNormal];
    [popupButton setHidden:NO];
    UIEdgeInsets inSets = UIEdgeInsetsMake(7, 0, 0, 0);
    [popupButton setTitleEdgeInsets:inSets];
    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:4];
    [popupButton.layer addAnimation:animation forKey:@"DismissAnimation"];
    
}



#define SCORE_MARK_TAG 20120402
- (void)addScore:(NSInteger)score toUser:(NSString *)userId
{
    AvatarView *avatarView = [self avatarViewForUserId:userId];
    [avatarView setScore:score];

}



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


- (void)didGameTurnComplete:(GameMessage *)message
{
    if (!hasPushResultController) {
        UIImage *image = [drawView createImage];
        NSInteger gainCoin = [[message notification] turnGainCoins];
        ResultController *rc = [[ResultController alloc] initWithImage:image
                                                              wordText:self.word.text 
                                                                 score:gainCoin                                                         correct:NO
                                                             isMyPaint:YES];
        [self.navigationController pushViewController:rc animated:YES];
        hasPushResultController = YES;
        [rc release];
        [self resetTimer];
    }else{
        PPDebug(@"warning:<didGameTurnComplete> but hasPushResultController = YES");
    }
}

- (void)didUserQuitGame:(GameMessage *)message
{
    NSString *userId = [message userId];
    [self popUpRunAwayMessage:userId];

    [self updatePlayerAvatars];
    if ([self userCount] <= 1) {
        [self popupUnhappyMessage:NSLS(@"kAllUserQuit") title:nil];
        [RoomController returnRoom:self startNow:NO];
    }

    
}
#pragma mark pick view delegate
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
}

- (IBAction)clickChangeRoomButton:(id)sender {
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton deelegate:self];
    [self.view addSubview:dialog];
}

- (void)clickOk:(CommonDialog *)dialog
{
    [dialog removeFromSuperview];
    [drawGameService quitGame];
    [HomeController returnRoom:self];

}
- (void)clickBack:(CommonDialog *)dialog
{
    [dialog removeFromSuperview];
}
@end
