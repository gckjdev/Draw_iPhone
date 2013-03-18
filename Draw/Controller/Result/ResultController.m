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
#import "OfflineGuessDrawController.h"
#import "DrawDataService.h"
#import "ShareService.h"
#import "AdService.h"
#import "UIButtonExt.h"
#import "FeedService.h"
#import "DeviceDetection.h"
#import "DrawGameAnimationManager.h"
#import "ItemManager.h"
#import "AccountManager.h"
#import "ConfigManager.h"
#import "ItemService.h"
#import "DrawFeed.h"
#import "ShowFeedController.h"
#import "UseItemScene.h"
#import "DrawSoundManager.h"
#import "ShareAction.h"
#import "DrawUtils.h"
#import "UIViewUtils.h"
#import "UserGameItemService.h"
#import "FlowerItem.h"
#import "UserGameItemManager.h"

#define CONTINUE_TIME 10

#define TOMATO_TOOLVIEW_TAG 20120718
#define FLOWER_TOOLVIEW_TAG 120120718

#define ITEM_FRAME  ([DeviceDetection isIPAD]?CGRectMake(0, 0, 122, 122):CGRectMake(0, 0, 61, 61))


@interface ResultController(){
    ShareAction* _shareAction;
}

- (void)throwItem:(ToolView*)toolView;
- (void)receiveFlower;
- (void)receiveTomato;


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
@synthesize upLabel;
@synthesize downLabel;
@synthesize backButton;
//@synthesize resultType = _resultType;
@synthesize useItemScene = _useItemScene;

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
     drawActionList:(NSArray *)drawActionList
              scene:(UseItemScene *)scene

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
        self.useItemScene = scene;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
         drawUserId:(NSString *)drawUserId
   drawUserNickName:(NSString *)drawUserNickName
           wordText:(NSString *)aWordText
              score:(NSInteger)aScore
            correct:(BOOL)correct
          isMyPaint:(BOOL)isMyPaint
     drawActionList:(NSArray *)drawActionList
               feed:(DrawFeed *)feed
              scene:(UseItemScene *)scene

{
    self = [self initWithImage:image
                    drawUserId:drawUserId
              drawUserNickName:drawUserNickName
                      wordText:aWordText
                         score:aScore
                       correct:correct
                     isMyPaint:isMyPaint
                drawActionList:drawActionList
                         scene:scene];
    _feed = feed;
    return self;
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

- (id)initWithImage:(UIImage *)image 
         drawUserId:(NSString *)drawUserId
   drawUserNickName:(NSString *)drawUserNickName
           wordText:(NSString *)aWordText 
              score:(NSInteger)aScore 
            correct:(BOOL)correct 
          isMyPaint:(BOOL)isMyPaint 
     drawActionList:(NSArray *)drawActionList 
               feed:(Feed *)feed

{
    self = [self initWithImage:image 
                    drawUserId:drawUserId 
              drawUserNickName:drawUserNickName 
                      wordText:aWordText 
                         score:aScore 
                       correct:correct 
                     isMyPaint:isMyPaint 
                drawActionList:drawActionList];
    
    if ([feed isKindOfClass:[DrawFeed class]]){
        _feed = (DrawFeed*)feed;
    }
    else{
        PPDebug(@"WARN : Feed is not DrawFeed");
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


- (BOOL)fromShowFeedController
{
    return [self hasSuperViewControllerForClass:[ShowFeedController class]];
}

- (BOOL)fromOfflineGuessController
{
    return [self hasSuperViewControllerForClass:[OfflineGuessDrawController class]];
}

- (void)initResultType
{
    if([self fromShowFeedController]){
        _resultType = FeedGuess;
        [self.backButton setImage:[ShareImageManager defaultManager].backButtonImage forState:UIControlStateNormal];
        [self.backButton setCenter:CGPointMake(self.view.frame.size.width - self.backButton.center.x, self.backButton.center.y)];
    }
    else if ([self fromOfflineGuessController]) 
    {
        _resultType = OfflineGuess;
        [self.backButton setImage:[ShareImageManager defaultManager].backButtonImage forState:UIControlStateNormal];
        [self.backButton setCenter:CGPointMake(self.view.frame.size.width - self.backButton.center.x, self.backButton.center.y)];
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
    
    [self.drawImage setShadowOffset:CGSizeMake(0, 3)
                               blur:0.6
                        shadowColor:[UIColor blackColor]];

}

- (int)calExp
{
    switch (_resultType) {
        case OnlineDraw: {
            return DRAWER_EXP;
        }break;
        case OnlineGuess: {
            return NORMAL_EXP;
        }break;
        case OfflineGuess: {
            return OFFLINE_GUESS_EXP;
        }break;
        case FeedGuess: {
            return OFFLINE_GUESS_EXP;
        }break;
        default:
            break;
    }
    return 0;
}

- (void)initScore
{
    //init score, award user
    [self.scoreLabel setText:[NSString stringWithFormat:@"+ %d",self.score]];
    if (self.score > 0) {
        PPDebug(@"<award guess> coins=%d", self.score);
        BalanceSourceType type = (_isMyPaint) ? DrawRewardType : GuessRewardType;
        [[AccountService defaultService] chargeAccount:self.score source:type];
        [[AudioManager defaultManager] playSoundByName:[DrawSoundManager defaultManager].congratulationsSound];
    }

    //init experience.
    NSInteger exp = 0;
    exp = [self calExp];
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

- (void)initToolViews
{
    ToolView* flower = [[[ToolView alloc] initWithItemType:ItemTypeFlower number:[[ItemManager defaultManager] amountForItem:ItemTypeFlower]] autorelease];
    flower.tag = FLOWER_TOOLVIEW_TAG;
    [self.view addSubview:flower];
    [flower addTarget:self action:@selector(clickUpButton:)];
    [flower setFrame:downButton.frame];
    
    flower.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    | !UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | !UIViewAutoresizingFlexibleWidth
    | !UIViewAutoresizingFlexibleHeight;
    
    if (![self isOffline]) {
        [flower setCenter:upButton.center];
        ToolView* tomato = [[[ToolView alloc] initWithItemType:ItemTypeTomato number:[[ItemManager defaultManager] amountForItem:ItemTypeTomato]] autorelease];
        tomato.tag = TOMATO_TOOLVIEW_TAG;
        [tomato setCenter:downButton.center];
        [self.view addSubview:tomato];
        [tomato addTarget:self action:@selector(clickDownButton:)];
        [tomato setFrame:downButton.frame];
        tomato.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
        | !UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | !UIViewAutoresizingFlexibleWidth
        | !UIViewAutoresizingFlexibleHeight;
    }
}
- (void)initActionButton
{
    //init the up & down button
    if (_resultType != OnlineDraw) {
        [self initToolViews];
        [upLabel setText:NSLS(@"kThrowFlower")];
        [downLabel setText:NSLS(@"kThrowTomato")];
        upButton.hidden = YES;
        downButton.hidden = YES;
        
        if (_resultType != OnlineGuess) {
            [upLabel setFrame:downLabel.frame];
            [downLabel setHidden:YES];
        }
        
    }else{
        upButton.hidden = downButton.hidden = YES;
        upLabel.hidden = downLabel.hidden = YES;
        continueButton.center = CGPointMake(self.view.center.x*0.75, continueButton.center.y);
        saveButton.center  = CGPointMake(self.view.center.x/4, continueButton.center.y);
    }
    
    //init the continue button
    if (_resultType == OnlineDraw || _resultType == OnlineGuess) {
        //在线猜画结果
        [self startTimer];        
        [self updateContinueButton:retainCount];     
    }else if(_resultType == OfflineGuess)
    {
        //离线，从“我要猜进入猜画结果”
        [self.continueButton setTitle:NSLS(@"kOneMore") forState:UIControlStateNormal];
        [self.continueButton setCenter:CGPointMake(self.view.frame.size.width/2, self.continueButton.center.y)];
    }else{
        //离线，从猜画详情进入猜画结果
        continueButton.hidden = YES;
        upButton.center = CGPointMake(self.view.frame.size.width*0.75, downButton.center.y);
        ToolView* flowerToolView = (ToolView*)[self.view viewWithTag:FLOWER_TOOLVIEW_TAG];
        [flowerToolView setCenter:CGPointMake(upButton.center.x, flowerToolView.center.y)];
        [upLabel setCenter:CGPointMake(upButton.center.x, downLabel.center.y)];
        [self.saveButton setCenter:CGPointMake(self.view.frame.size.width/4, self.saveButton.center.y)];
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

    /*
    if (self.adView == nil){
        self.adView = [[AdService defaultService] createAdInView:self 
                                                           frame:CGRectMake(0, 47, 320, 50) 
                                                       iPadFrame:CGRectMake(224, 815, 320, 50)
                                                         useLmAd:NO];   
    } 
    */
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
    [self setUpLabel:nil];
    [self setDownLabel:nil];
    [self setBackButton:nil];
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
    PPRelease(_useItemScene);
    PPRelease(experienceLabel);
    PPRelease(titleLabel);
    PPRelease(upLabel);
    PPRelease(downLabel);
    PPRelease(backButton);
    [super dealloc];
}

- (BOOL)isOffline
{
    return (_resultType == OfflineGuess || _resultType == FeedGuess);
}

- (IBAction)clickUpButton:(id)sender {
    
    ToolView* toolView = (ToolView*)sender;    
    
    [self throwItem:toolView];
}

- (IBAction)clickDownButton:(id)sender {

    ToolView* toolView = (ToolView*)sender;    
    
    [self throwItem:toolView];
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

- (void)showShareAction
{
    if (_shareAction == nil) {
        [self showActivityWithText:NSLS(@"kSaving")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _shareAction = [[ShareAction alloc] initWithFeed:_feed
                                                       image:_image];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideActivity];
                [_shareAction displayWithViewController:self onView:self.saveButton];
            });
            
        });        
    }
    else{
        [_shareAction displayWithViewController:self onView:self.saveButton];
    }
}
- (void)saveToLocal
{
    if (_isMyPaint == NO){
        [[FeedService defaultService] actionSaveOpus:_feed.feedId
                                          actionName:DB_FIELD_ACTION_SAVE_TIMES];
    }
    
    [[ShareService defaultService] shareWithImage:_image
                                       drawUserId:_drawUserId
                                       isDrawByMe:_isMyPaint
                                         drawWord:wordText];
    
    PBDraw *pbDraw = [[DrawDataService defaultService]
                      buildPBDraw:_drawUserId
                      nick:_drawUserNickName
                      avatar:nil
                      drawActionList:self.drawActionList
                      drawWord:[Word wordWithText:self.wordText
                                            level:WordLevelLow
                                            score:[ConfigManager offlineDrawMyWordScore]]
                      language:1
                      drawBg:nil
                      size:DRAW_VIEW_FRAME.size
                      isCompressed:YES];
    
    [[DrawDataService defaultService ] savePaintWithPBDraw:pbDraw
                                                     image:_image
                                                  delegate:self];
    self.saveButton.enabled = NO;
    self.saveButton.selected = YES;
}

- (IBAction)clickSaveButton:(id)sender {
    
    if ([self isOffline]) {
        [self showShareAction];
    } else {
        [self saveToLocal];
    }

    
}

- (void)didSaveOpus:(BOOL)succ
{
    if (succ) {
        [self popupMessage:NSLS(@"kSaveOpusOK") title:nil];
    }else{
        [self popupMessage:NSLS(@"kSaveImageFail") title:nil];
    }
}


- (IBAction)clickExitButton:(id)sender {
    
    UIViewController *viewController = [self superViewControllerForClass:[ShowFeedController class]];
    
    if (viewController) {
        [self.navigationController popToViewController:viewController animated:YES];
    }else{
        if ([[DrawGameService defaultService] session] != nil){
            [[DrawGameService defaultService] quitGame];
        }
        [HomeController returnRoom:self];
    }
    
}

- (void)didReceiveRank:(NSNumber*)rank fromUserId:(NSString*)userId
{        
    if (rank.integerValue == RANK_TOMATO) {
        PPDebug(@"%@ give you an tomato", userId);
        [[ItemService defaultService] receiveItem:ItemTypeTomato];
        [self receiveTomato];
    }else{
        PPDebug(@"%@ give you a flower", userId);
        [[ItemService defaultService] receiveItem:ItemTypeFlower];
        [self receiveFlower];
    }
    
}

#pragma mark - LevelServiceDelegate

- (void)levelUp:(int)level
{
//    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kUpgradeMsg"),level] delayTime:1.5 isHappy:YES];
    [AnimationManager fireworksAnimationAtView:self.view];
}


#pragma mark - draw data service delegate
- (void)didMatchDraw:(DrawFeed *)feed result:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0 && feed) {
        [HomeController startOfflineGuessDraw:feed from:self];
    }else{
        CommonMessageCenter *center = [CommonMessageCenter defaultCenter];
        [center postMessageWithText:NSLS(@"kMathOpusFail") delayTime:1.5 isHappy:NO];
    }
}

#pragma mark - throw item animation
#define ITEM_TAG_OFFSET 20120728
- (void)throwItem:(ToolView*)toolView
{
    if ((toolView.itemType == ItemTypeTomato
         && ![_useItemScene canThrowTomato])
        || (toolView.itemType == ItemTypeFlower
            && ![_useItemScene canThrowFlower])) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kCanotSendItemToOpus"),[_useItemScene itemLimitForType:toolView.itemType]] delayTime:1.5 isHappy:YES];
            self.downButton.enabled = NO;
        return;
    }
        
    __block typeof (self) bself = self;
    [[FlowerItem sharedFlowerItem] useItem:_feed.author.userId
                                 isOffline:[self isOffline]
                                feedOpusId:_feed.feedId
                                feedAuthor:_feed.author.userId
                                   forFree:NO
                             resultHandler:^(int resultCode, int itemId) {
        if (resultCode == ERROR_SUCCESS) {
            [bself throwItemAnimation:toolView];
            [toolView decreaseNumber];
        }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
        }
    }];
}

- (void)throwItemAnimation:(ToolView*)toolView
{
    BOOL itemEnough = [[UserGameItemManager defaultManager] hasEnoughItemAmount:toolView.itemType amount:1];
    UIImageView* throwingItem= [[[UIImageView alloc] initWithFrame:toolView.frame] autorelease];
    [throwingItem setImage:toolView.imageView.image];
    if (toolView.itemType == ItemTypeTomato) {
        [DrawGameAnimationManager showThrowTomato:throwingItem animInController:self rolling:YES itemEnough:itemEnough shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:self.useItemScene.sceneType] completion:^(BOOL finished) {
            //
        }];
        [_useItemScene throwATomato];
    }
    if (toolView.itemType == ItemTypeFlower) {
        [DrawGameAnimationManager showThrowFlower:throwingItem animInController:self rolling:YES itemEnough:itemEnough shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:self.useItemScene.sceneType] completion:^(BOOL finished) {
            //
        }];
        [_useItemScene throwAFlower];
    }
    
    
}


- (void)receiveFlower
{
    UIImageView* item = [[[UIImageView alloc] initWithFrame:ITEM_FRAME] autorelease];
    [self.view addSubview:item];
    [item setImage:[ShareImageManager defaultManager].flower];
    [DrawGameAnimationManager showReceiveFlower:item animationInController:self];
    //[self popupMessage:[NSString stringWithFormat:NSLS(@"kReceiveFlowerMessage"),REWARD_EXP, REWARD_COINS] title:nil];
}
- (void)receiveTomato
{
    UIImageView* item = [[[UIImageView alloc] initWithFrame:ITEM_FRAME] autorelease];
    [self.view addSubview:item];
    [item setImage:[ShareImageManager defaultManager].tomato];
    [DrawGameAnimationManager showReceiveFlower:item animationInController:self];
    //[self popupMessage:[NSString stringWithFormat:NSLS(@"kReceiveTomatoMessage"),REWARD_EXP, REWARD_COINS] title:nil];
}

#pragma mark - Common Dialog Delegate
#define SHOP_DIALOG_TAG 20120406


- (void)clickOk:(CommonDialog *)dialog
{
    switch (dialog.tag) {
//        case (ItemTypeTomato + ITEM_TAG_OFFSET): {
//            [CommonItemInfoView showItem:[Item tomato] infoInView:self];
//        } break;
//        case (ItemTypeFlower + ITEM_TAG_OFFSET): {
//            [CommonItemInfoView showItem:[Item flower] infoInView:self];
//        } break;
//        case (ItemTypeTips + ITEM_TAG_OFFSET): {
//            [CommonItemInfoView showItem:[Item tips] infoInView:self];
//        } break;
        default:
            break;
    }

}
- (void)clickBack:(CommonDialog *)dialog
{
    
}

#pragma mark - commonItemInfoView delegate
- (void)didBuyItem:(int)itemId
            result:(int)result
{
    if (result == 0) {
        [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kBuySuccess") delayTime:1 isHappy:YES];
        ToolView* toolview = nil;
        switch (itemId) {
            case ItemTypeFlower: {
                toolview = (ToolView*)[self.view viewWithTag:FLOWER_TOOLVIEW_TAG];
            } break;
            case ItemTypeTomato: {
                toolview = (ToolView*)[self.view viewWithTag:TOMATO_TOOLVIEW_TAG];
            } break;
            default:
                break;
        }
        [toolview setNumber:[[ItemManager defaultManager] amountForItem:toolview.itemType]];
    }
    if (result == ERROR_BALANCE_NOT_ENOUGH)
    {
        [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
    }
}


@end
