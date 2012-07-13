//
//  ResultController.m
//  Draw
//
//  Created by  on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ResultController.h"
#import "HomeController.h"
#import "RoomController.h"
#import "DrawGameService.h"
#import "GameConstants.h"
#import "MyPaint.h"
#import "MyPaintManager.h"
#import "PPDebug.h"
#import "GameSession.h"
#import "GameTurn.h"
#import "ShareImageManager.h"
#import "LocaleUtils.h"
#import "AccountService.h"
#import "Account.h"
#import "DrawAction.h"
#import "WordManager.h"
#import "AudioManager.h"
#import "DrawConstants.h"
#import "AnimationManager.h"
#import "CommonMessageCenter.h"
#import "FeedController.h"
#import "FeedDetailController.h"
#import "OfflineGuessDrawController.h"
#import "DrawDataService.h"
#import "ShareService.h"
#import "AdService.h"
#import "UIButtonExt.h"
#import "FeedService.h"

#define CONTINUE_TIME 10

@interface ResultController()

//- (BOOL)fromFeedDetailController;
//- (BOOL)fromFeedController;

@end

@implementation ResultController
@synthesize drawImage;
@synthesize upButton;
@synthesize downButton;
@synthesize continueButton;
@synthesize saveButton;
@synthesize wordText;
@synthesize score;
@synthesize wordLabel;
@synthesize scoreLabel;
@synthesize whitePaper;
@synthesize resultLabel;
@synthesize drawActionList = _drawActionList;
@synthesize drawUserId = _drawUserId;
@synthesize drawUserNickName = _drawUserNickName;
@synthesize adView = _adView;
@synthesize experienceLabel;
@synthesize titleLabel;
//@synthesize resultType = _resultType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [[WordManager defaultManager] clearWordBaseDictionary];
    
}


- (id)initWithImage:(UIImage *)image 
         drawUserId:(NSString *)drawUserId
   drawUserNickName:(NSString *)drawUserNickName
           wordText:(NSString *)aWordText 
              score:(NSInteger)aScore 
            correct:(BOOL)correct 
          isMyPaint:(BOOL)isMyPaint 
     drawActionList:(NSArray *)drawActionList;

{
    self = [super init];
    if (self) {
        _image = image;
        [_image retain];
        self.wordText = aWordText;
        self.score = aScore;
        _correct = correct;
        _isMyPaint = isMyPaint;
        self.drawActionList = [NSArray arrayWithArray:drawActionList];
        
        self.drawUserNickName = drawUserNickName;
        self.drawUserId = drawUserId;        
        
        drawGameService = [DrawGameService defaultService];
    }
    return self;
}

- (void)updateContinueButton:(NSInteger)count
{
    [self.continueButton setTitle:[NSString stringWithFormat:NSLS(@"kContinue"),count] forState:UIControlStateNormal];
}

- (void)resetTimer
{
    if (continueTimer && [continueTimer isValid]) {
            [continueTimer invalidate];
    }
    continueTimer = nil;
    retainCount = CONTINUE_TIME;
}

- (void)handleContinueTimer:(NSTimer *)theTimer
{
    PPDebug(@"<ResultController> handle timer");    
    
    -- retainCount;
    if (retainCount <= 0) {
        retainCount = 0;
        [self clickContinueButton:nil];
        return;
    }
    [self updateContinueButton:retainCount];
}

- (void)startTimer
{
    [self resetTimer];
    continueTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleContinueTimer:) userInfo:nil repeats:YES];
}

- (void)setUpAndDownButtonEnabled:(BOOL)enabled
{
    [upButton setEnabled:enabled];
    [downButton setEnabled:enabled];
}


- (BOOL)fromFeedDetailController
{
    return [self hasSuperViewControllerForClass:[FeedDetailController class]];
}
//- (BOOL)fromFeedController
//{
//    return [self hasSuperViewControllerForClass:[FeedController class]];
//}
- (BOOL)fromOfflineGuessController
{
    return [self hasSuperViewControllerForClass:[OfflineGuessDrawController class]];
}

- (void)initResultType
{
    if([self fromFeedDetailController]){
        _resultType = FeedGuess;
    }
    else if ([self fromOfflineGuessController]) 
    {
        _resultType = OfflineGuess;
    }else if(_isMyPaint){
        _resultType = OnlineDraw;
    }else{
        _resultType = OnlineGuess;
    }

}

- (void)initTitleLabel
{
    if (_resultType == OnlineDraw || _resultType == OnlineDraw) {
        [titleLabel setText:NSLS(@"kOnlineResultTitle")];
    }else{
        [titleLabel setText:NSLS(@"kOfflineResultTitle")];        
    }
}

- (void)initDrawImage
{
    ShareImageManager *shareImageManager = [ShareImageManager defaultManager];
    [self.whitePaper setImage:[shareImageManager whitePaperImage]];
    [self.drawImage setImage:_image];
}

- (void)initScore
{
    //init score
    [self.scoreLabel setText:[NSString stringWithFormat:@"+ %d",self.score]];
    //add score
    if (self.score > 0) {
        BalanceSourceType type = (_isMyPaint) ? DrawRewardType : GuessRewardType;
        [[AccountService defaultService] chargeAccount:self.score source:type];    
        
        [[AudioManager defaultManager] playSoundById:GAME_WIN];
    }

    //init experience.
    NSInteger exp = 0;
    if (_isMyPaint) {
        exp = DRAWER_EXP;
    }else{
        exp = NORMAL_EXP;
    }
    [[LevelService defaultService] addExp:exp delegate:self];
    [self.experienceLabel setText:[NSString stringWithFormat:@"+ %d",exp]];
}

- (void)initAnswer
{
    NSString *answer = nil;
    if (self.wordText) {
        answer = self.wordText;        
        if ([LocaleUtils isTraditionalChinese]) {
            answer = [WordManager changeToTraditionalChinese:answer];
        }
    }else{
        answer = NSLS(@"kNoWord");
    }
    
    [self.wordLabel setText:answer];

}

- (void)initResultLabel
{
    if (_isMyPaint) {
        [self.resultLabel setText:NSLS(@"kTurnResult")];   
    }else if (_correct) {
        [self.resultLabel setText:NSLS(@"kCongratulations")];        
    }else{
        [self.resultLabel setText:NSLS(@"kPity")];
    }
}
- (void)initActionButton
{
    //init the up & down button
    if (_resultType != OnlineDraw) {
        [upButton setTitle:NSLS(@"kThrowFlower") forState:UIControlStateNormal];
        [downButton setTitle:NSLS(@"kThrowTomato") forState:UIControlStateNormal];
    }else{
        upButton.hidden = downButton.hidden = YES;
        continueButton.frame = upButton.frame;
    }
    
    //init the continue button
    if (_resultType == OnlineDraw || _resultType == OnlineGuess) {
        [self startTimer];        
        [self updateContinueButton:retainCount];     
    }else if(_resultType == OfflineGuess)
    {
        [self.continueButton setTitle:NSLS(@"kOneMore") forState:UIControlStateNormal];
    }else{
        continueButton.hidden = YES;
        downButton.center = CGPointMake(self.view.frame.size.width/2, downButton.center.y);
    }
    
    //init the share button
    [self.saveButton setTitle:NSLS(@"kSaveAndShare") forState:UIControlStateNormal];
    
    
    [self.saveButton centerImageAndTitle:-1];
    [self.continueButton centerImageAndTitle:-1];
    [self.upButton centerImageAndTitle:-1];
    [self.downButton centerImageAndTitle:-1];
        
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{        
    
    self.adView = [[AdService defaultService] createAdInView:self 
                                                       frame:CGRectMake(0, 0, 320, 50) 
                                                   iPadFrame:CGRectMake(224, 755, 320, 50)
                                                     useLmAd:NO];    
    [super viewDidLoad];
    [self initResultType];
    [self initTitleLabel];
    [self initDrawImage];
    [self initScore];
    [self initResultLabel];
    [self initActionButton];
    [self initAnswer];        
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[DrawGameService defaultService] unregisterObserver:self];
    
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];

    [super viewDidDisappear:animated];
        
}
- (void)viewDidAppear:(BOOL)animated
{
    [[DrawGameService defaultService] registerObserver:self];    
    
    [super viewDidAppear:animated];

    if (self.adView == nil){
        self.adView = [[AdService defaultService] createAdInView:self 
                                                           frame:CGRectMake(0, 0, 320, 50) 
                                                       iPadFrame:CGRectMake(224, 755, 320, 50)
                                                         useLmAd:NO];        
    }        
}

- (void)viewDidUnload
{    
    
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];    
    
    [self setUpButton:nil];
    [self setDownButton:nil];
    [self setContinueButton:nil];
    [self setSaveButton:nil];
    [self setDrawImage:nil];
    _image = nil;
    [self setWordLabel:nil];
    [self setScoreLabel:nil];
    [self setWhitePaper:nil];
    [self setResultLabel:nil];
    [self setExperienceLabel:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {

    [[AdService defaultService] clearAdView:_adView];
    PPRelease(_adView);
    
    PPRelease(_drawUserId);
    PPRelease(_drawUserNickName);
    PPRelease(upButton);
    PPRelease(downButton);
    PPRelease(continueButton);
    PPRelease(saveButton);
    PPRelease(drawImage);
    PPRelease(_image);
    PPRelease(wordText);
    PPRelease(wordLabel);
    PPRelease(scoreLabel);
    PPRelease(whitePaper);
    PPRelease(resultLabel);
    PPRelease(_drawActionList);
    [experienceLabel release];
    [titleLabel release];
    [super dealloc];
}
- (IBAction)clickUpButton:(id)sender {
    
    if (_resultType == OfflineGuess) {
//    TODO  send flower http request.
        
    }else{
//    TODO  send flower socket request.
        [[DrawGameService defaultService] rankGameResult:RANK_FLOWER]; 
        
    }

    [self setUpAndDownButtonEnabled:NO];
}

- (IBAction)clickDownButton:(id)sender {
    if (_resultType == OfflineGuess) {
        //    TODO  send tomato http request.
        
    }else{
        //    TODO  send tomato socket request.
        [[DrawGameService defaultService] rankGameResult:RANK_TOMATO];        
    }
    [self setUpAndDownButtonEnabled:NO];
}

- (IBAction)clickContinueButton:(id)sender {
    
    
    if (_resultType == OfflineGuess) {
        [self showActivityWithText:NSLS(@"kLoading")];
        [[DrawDataService defaultService] matchDraw:self];
    }else{
        [self resetTimer];
        if ([drawGameService sessionStatus] == SESSION_WAITING) {
            [RoomController returnRoom:self startNow:NO];        
        }else{
            [RoomController returnRoom:self startNow:YES];
        }
    }

}

- (IBAction)clickSaveButton:(id)sender {

    [[ShareService defaultService] shareWithImage:_image drawUserId:_drawUserId isDrawByMe:_isMyPaint drawWord:wordText];    
    
    [[DrawDataService defaultService] saveActionList:self.drawActionList userId:_drawUserId nickName:_drawUserNickName isMyPaint:_isMyPaint word:self.wordText image:_image viewController:self];
    self.saveButton.enabled = NO;
    self.saveButton.selected = YES;
}

- (IBAction)clickExitButton:(id)sender {
    
    UIViewController *viewController = [self superViewControllerForClass:[FeedDetailController class]];
    
    if (viewController) {
        [self.navigationController popToViewController:viewController animated:YES];
    }else{
        if ([self hasSuperViewControllerForClass:[OfflineGuessDrawController class]]) {
            [[DrawGameService defaultService] quitGame];
        }
        [HomeController returnRoom:self];
    }
    
}

- (void)didReceiveRank:(NSNumber*)rank fromUserId:(NSString*)userId
{
    if (rank.integerValue == RANK_TOMATO) {
        PPDebug(@"%@ give you an tomato", userId);
    }else{
        PPDebug(@"%@ give you a flower", userId);
    }
    
    // TODO show animation here
}

#pragma mark - LevelServiceDelegate

- (void)levelUp:(int)level
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kUpgradeMsg"),level] delayTime:1.5 isHappy:YES];
    [AnimationManager fireworksAnimationAtView:self.view];
}


#pragma mark - draw data service delegate
- (void)didMatchDraw:(Feed *)feed result:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0 && feed) {
        [HomeController startOfflineGuessDraw:feed from:self];
    }else{
        CommonMessageCenter *center = [CommonMessageCenter defaultCenter];
        [center postMessageWithText:NSLS(@"kMathOpusFail") delayTime:1.5 isHappy:NO];
    }
}


@end
