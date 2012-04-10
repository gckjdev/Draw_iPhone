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

#define CONTINUE_TIME 10

@implementation ResultController
@synthesize drawImage;
@synthesize upButton;
@synthesize downButton;
@synthesize continueButton;
@synthesize saveButton;
@synthesize exitButton;
@synthesize wordText;
@synthesize score;
@synthesize wordLabel;
@synthesize scoreLabel;
@synthesize whitePaper;
@synthesize titleLabel;
@synthesize drawActionList = _drawActionList;

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
}


- (id)initWithImage:(UIImage *)image wordText:(NSString *)aWordText score:(NSInteger)aScore correct:(BOOL)correct isMyPaint:(BOOL)isMyPaint drawActionList:(NSArray *)drawActionList;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self saveActionList:self.drawActionList];
    
    [self.drawImage setImage:_image];
    NSString *answer = nil;
    if (self.wordText) {
        answer = [NSString stringWithFormat:NSLS(@"kAnswer"),self.wordText];        
    }else{
        answer = NSLS(@"kNoWord");
    }

    [self.wordLabel setText:answer];
    [self.scoreLabel setText:[NSString stringWithFormat:@"+%d",self.score]];

    [self startTimer];
    [self setUpAndDownButtonEnabled:YES];
    
    ShareImageManager *shareImageManager = [ShareImageManager defaultManager];
    [self.whitePaper setImage:[shareImageManager whitePaperImage]];
    [self.saveButton setBackgroundImage:[shareImageManager orangeImage] 
                               forState:UIControlStateNormal];
    [self.continueButton setBackgroundImage:[shareImageManager greenImage] 
                                   forState:UIControlStateNormal];
    [self.exitButton  setBackgroundImage:[shareImageManager redImage] 
                                forState:UIControlStateNormal];

    [self updateContinueButton:retainCount];
    [self.exitButton setTitle:NSLS(@"kExit") forState:UIControlStateNormal];
    [self.saveButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
    if (_isMyPaint) {
            [self.titleLabel setText:NSLS(@"kTurnResult")];                
    }else{
        if (_correct) {
            [self.titleLabel setText:NSLS(@"kCongratulations")];        
        }else{
            [self.titleLabel setText:NSLS(@"kPity")];
        }
    }

    //add score
    if (self.score > 0) {
        BalanceSourceType type = (_isMyPaint) ? DrawRewardType : GuessRewardType;
        [[AccountService defaultService] chargeAccount:self.score source:type];    
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [drawGameService unregisterObserver:self];
//    [drawGameService setRoomDelegate:nil];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
//    [drawGameService setRoomDelegate:self];
//    [drawGameService registerObserver:self];
//    [self.upButton setEnabled:YES];
//    [self.downButton setEnabled:YES];
}

- (void)viewDidUnload
{
    [self setUpButton:nil];
    [self setDownButton:nil];
    [self setContinueButton:nil];
    [self setSaveButton:nil];
    [self setExitButton:nil];
    [self setDrawImage:nil];
    _image = nil;
    [self setWordLabel:nil];
    [self setScoreLabel:nil];
    [self setWhitePaper:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [upButton release];
    [downButton release];
    [continueButton release];
    [saveButton release];
    [exitButton release];
    [drawImage release];
    [_image release];
    [wordText release];
    [wordLabel release];
    [scoreLabel release];
    [whitePaper release];
    [titleLabel release];
    [_drawActionList release];
    [super dealloc];
}
- (IBAction)clickUpButton:(id)sender {
    [drawGameService rankGameResult:RANK_GOOD];
    [self setUpAndDownButtonEnabled:NO];
}

- (IBAction)clickDownButton:(id)sender {
    [drawGameService rankGameResult:RANK_BAD];
    [self setUpAndDownButtonEnabled:NO];
}

- (IBAction)clickContinueButton:(id)sender {
    [self resetTimer];
    if ([drawGameService sessionStatus] == SESSION_WAITING) {
        [RoomController returnRoom:self startNow:NO];        
    }else{
        [RoomController returnRoom:self startNow:YES];
    }

}

- (IBAction)clickSaveButton:(id)sender {
    UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
}

- (IBAction)clickExitButton:(id)sender {
    [[DrawGameService defaultService] quitGame];
    [HomeController returnRoom:self];
}

- (void)saveActionList:(NSArray *)actionList
{
 
    if (actionList.count == 0) {
        PPDebug(@"actionList has no object");        
    }

    if ([DrawAction isDrawActionListBlank:actionList]) {
        return;
    }
    time_t aTime = time(0);
    NSString* imageName = [NSString stringWithFormat:@"%d.png", aTime];
    if (_image!=nil) 
    {
        //此处首先指定了图片存取路径（默认写到应用程序沙盒 中）
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        if (!paths) {
            PPDebug(@"Document directory not found!");
        }
        //并给文件起个文件名
        NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        //此处的方法是将图片写到Documents文件中 如果写入成功会弹出一个警告框,提示图片保存成功
        NSData* imageData = UIImagePNGRepresentation(_image);
        BOOL result=[imageData writeToFile:uniquePath atomically:YES];
        PPDebug(@"<DrawGameService> save image to path:%@ result:%d , canRead:%d", uniquePath, result, [[NSFileManager defaultManager] fileExistsAtPath:uniquePath]);
        if (result) {
            NSString* drawUserId = [[[drawGameService session] currentTurn] lastPlayUserId];
            NSString* drawUserNickName = [[drawGameService session] getNickNameByUserId:drawUserId];
            NSString* drawWord = [[[drawGameService session] currentTurn] word];
            if (drawWord == nil){
                drawWord = [[[drawGameService session] currentTurn] lastWord];
            }
            
            NSData* drawActionListData = [NSKeyedArchiver archivedDataWithRootObject:actionList];
            [[MyPaintManager defaultManager ] createMyPaintWithImage:uniquePath 
                                                                data:drawActionListData 
                                                          drawUserId:drawUserId 
                                                    drawUserNickName:drawUserNickName 
                                                            drawByMe:_isMyPaint 
                                                            drawWord:drawWord];
        }
    }
   
}

- (void)didReceiveRank:(NSNumber*)rank fromUserId:(NSString*)userId
{
    if (rank.integerValue == RANK_BAD) {
        NSLog(@"%@ give you an egg", userId);
    }else{
        NSLog(@"%@ give you a flower", userId);
    }
}


@end
