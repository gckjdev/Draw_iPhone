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
#import "DrawDataService.h"
#import "ShareService.h"
#import "UIButtonExt.h"
#import "FeedService.h"
#import "DeviceDetection.h"
#import "DrawGameAnimationManager.h"
#import "AccountManager.h"
#import "PPConfigManager.h"
#import "DrawFeed.h"
#import "ShowFeedController.h"
#import "UseItemScene.h"
#import "ShareAction.h"
#import "DrawUtils.h"
#import "UIViewUtils.h"
#import "UserGameItemService.h"
#import "FlowerItem.h"
#import "UserGameItemManager.h"
#import "BalanceNotEnoughAlertView.h"
#import "UIButton+WebCache.h"
#import "GameItemManager.h"
#import "TomatoItem.h"

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


- (void)initResultType
{
    if([self fromShowFeedController]){
        _resultType = FeedGuess;
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
        [_titleView setTitle:NSLS(@"kOnlineResultTitle")];
    }else{
        [_titleView setTitle:NSLS(@"kOfflineResultTitle")];        
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
        [[AccountService defaultService] chargeCoin:self.score source:type];
        [[AudioManager defaultManager] playSoundByName:SOUND_EFFECT_CONGRATULATIONS];
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
    ToolView* flower = [[[ToolView alloc] initWithItemType:ItemTypeFlower number:0] autorelease];
    
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
        ToolView* tomato = [[[ToolView alloc] initWithItemType:ItemTypeTomato number:0] autorelease];
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
    PBGameItem *flower = [[GameItemManager defaultManager] itemWithItemId:ItemTypeFlower];
    [self.upButton setBackgroundImageWithURL:[NSURL URLWithString:flower.image]];
    
    PBGameItem *tomato = [[GameItemManager defaultManager] itemWithItemId:ItemTypeTomato];
    [self.upButton setBackgroundImageWithURL:[NSURL URLWithString:tomato.image]];
    
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
        //在线画画
        upButton.hidden = downButton.hidden = YES;
        upLabel.hidden = downLabel.hidden = YES;

        //        saveButton.center = continueButton.center;
//        
//        CGPoint continueCenter = upButton.center;
//        continueCenter.y = continueButton.center.y;
//        continueButton.center = continueCenter;
        
//        continueButton.center = upButton.center;
        
        continueButton.center = CGPointMake(self.view.frame.size.width/3.0, continueButton.center.y);
        saveButton.center  = CGPointMake(self.view.frame.size.width*2/3.0, continueButton.center.y);
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
    
    self.titleView = [CommonTitleView createTitleView:self.view];
    [self.titleView setTarget:self];
    [self.titleView hideBackButton];
    [self.titleView setRightButtonImage:[UIImage imageNamed:@"run@2x.png"]];
    [self.titleView setRightButtonSelector:@selector(clickExitButton:)];
    
    self.wordLabel.textColor = COLOR_BROWN;

    self.drawImage.layer.borderWidth = 2;
    self.drawImage.layer.borderColor = [COLOR_GREEN CGColor];
    
    [self initResultType];
    [self initTitleLabel];
    [self initDrawImage];
    [self initScore];
    [self initResultLabel];
    [self setButtonImageAdapteIpad ];
    [self initActionButton];
    [self initAnswer];   
    [self setCanDragBack:NO];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [[DrawGameService defaultService] unregisterObserver:self];
    
    [self setAdView:nil];

    [super viewDidDisappear:animated];
        
}
- (void)viewDidAppear:(BOOL)animated
{
    [[DrawGameService defaultService] registerObserver:self];    
    
    [super viewDidAppear:animated];

}

- (void)viewDidUnload
{
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
    [self setTitleView:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {

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
    [_titleView release];
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
//        [self showActivityWithText:NSLS(@"kLoading")];
//        [[DrawDataService defaultService] matchDraw:self];
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
                                           contestId:_feed.contestId
                                          actionName:DB_FIELD_ACTION_SAVE_TIMES
                                            category:_feed.categoryType];
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
                                            score:[PPConfigManager offlineDrawMyWordScore]]
                      language:1
                      size:CGSizeMake(300, 300) //TODO should update the real size, here for test
                      isCompressed:NO];
    
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
        POSTMSG(NSLS(@"kSaveOpusOK"));
    }else{
        POSTMSG(NSLS(@"kSaveImageFail"));
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
        [self receiveTomato];
    }else{
        PPDebug(@"%@ give you a flower", userId);
        [self receiveFlower];
    }
    
}

#pragma mark - LevelServiceDelegate

- (void)levelUp:(int)level
{
//    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kUpgradeMsg"),level] delayTime:1.5 isHappy:YES];
    [AnimationManager fireworksAnimationAtView:self.view];
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
    
    if (toolView.itemType == ItemTypeFlower) {
        __block typeof (self) bself = self;
        [[FlowerItem sharedFlowerItem] useItem:_feed.author.userId
                                     isOffline:[self isOffline]
                                      drawFeed:_feed
//                                    feedOpusId:_feed.feedId
//                                    feedAuthor:_feed.author.userId
                                       forFree:NO
                                 resultHandler:^(int resultCode, int itemId, BOOL isBuy) {
                                     if (resultCode == ERROR_SUCCESS) {
                                         [bself throwItemAnimation:toolView isBuy:isBuy];
                                         [toolView decreaseNumber];
                                     }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
                                         if ([self isOffline]) {
                                             [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
                                         }else{
                                             [BalanceNotEnoughAlertView showInController:bself];
                                         }
                                     }else if (resultCode == ERROR_NETWORK){
                                         [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:NO];
                                     }
                                 }];
    }
    
    if (toolView.itemType == ItemTypeTomato) {
        __block typeof (self) bself = self;
        [[TomatoItem sharedTomatoItem] useItem:_feed.author.userId
                                     isOffline:[self isOffline]
                                    feedOpusId:_feed.feedId
                                    feedAuthor:_feed.author.userId
                                       forFree:NO
                                 resultHandler:^(int resultCode, int itemId, BOOL isBuy) {
                                     if (resultCode == ERROR_SUCCESS) {
                                         [bself throwItemAnimation:toolView isBuy:isBuy];
                                         [toolView decreaseNumber];
                                     }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH){
                                         if ([self isOffline]) {
                                             [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
                                         }else{
                                             [BalanceNotEnoughAlertView showInController:bself];
                                         }
                                     }else if (resultCode == ERROR_NETWORK){
                                         [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:NO];
                                     }
                                 }];

    }
}

- (void)throwItemAnimation:(ToolView*)toolView isBuy:(BOOL)isBuy
{
    UIImageView* throwingItem= [[[UIImageView alloc] initWithFrame:toolView.frame] autorelease];
    [throwingItem setImage:[toolView backgroundImageForState:UIControlStateNormal]];
    if (toolView.itemType == ItemTypeTomato) {
        [DrawGameAnimationManager showThrowTomato:throwingItem animInController:self rolling:YES itemEnough:!isBuy shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:self.useItemScene.sceneType] completion:^(BOOL finished) {
            //
        }];
        [_useItemScene throwATomato];
    }
    if (toolView.itemType == ItemTypeFlower) {
        [DrawGameAnimationManager showThrowFlower:throwingItem animInController:self rolling:YES itemEnough:!isBuy shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:self.useItemScene.sceneType] completion:^(BOOL finished) {
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
}
- (void)receiveTomato
{
    UIImageView* item = [[[UIImageView alloc] initWithFrame:ITEM_FRAME] autorelease];
    [self.view addSubview:item];
    [item setImage:[ShareImageManager defaultManager].tomato];
    [DrawGameAnimationManager showReceiveFlower:item animationInController:self];
}

#pragma mark - Common Dialog Delegate
#define SHOP_DIALOG_TAG 20120406


#pragma mark - commonItemInfoView delegate
- (void)didBuyItem:(int)itemId
            result:(int)result
{
    if (result == 0) {
        [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kBuySuccess") delayTime:1 isHappy:YES];
    }
    if (result == ERROR_BALANCE_NOT_ENOUGH)
    {
        if ([self isOffline]) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
        }else{
            [BalanceNotEnoughAlertView showInController:self];
        }
    }
}

-(void)setButtonImageAdapteIpad{
    
    if (ISIPAD){
        [self.saveButton setImage:[UIImage imageNamedFixed:@"draw_share@2x.png"] forState:UIControlStateNormal];
        [self.continueButton setImage:[UIImage imageNamedFixed:@"playagain@2x.png"] forState:UIControlStateNormal];
        [self.upButton setImage:[UIImage imageNamedFixed:@"flower_result@2x.png"] forState:UIControlStateNormal];
        [self.downButton setImage:[UIImage imageNamedFixed:@"tomato_result@2x.png"] forState:UIControlStateNormal];
    }
    
}


@end
