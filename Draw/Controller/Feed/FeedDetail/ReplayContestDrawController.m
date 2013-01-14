//
//  ReplayContestDrawController.m
//  Draw
//
//  Created by haodong on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReplayContestDrawController.h"
#import "DrawFeed.h"
#import "ShowDrawView.h"
#import "Draw.h"
#import "DrawAction.h"
#import "ShowDrawView.h"
#import "ItemService.h"
#import "ItemManager.h"
#import "StableView.h"
#import "DrawGameAnimationManager.h"
#import "CommonItemInfoView.h"
#import "FeedService.h"
#import "ShareService.h"
#import "CommonMessageCenter.h"
#import "AccountService.h"

#define KEY_

@interface ReplayContestDrawController ()
{
    int _maxTomato;
    int _maxFlower;
}
@property (retain, nonatomic) DrawFeed *feed;
@end

@implementation ReplayContestDrawController
@synthesize holderView = _holderView;
@synthesize feed = _feed;
@synthesize showView = _showView;
@synthesize upButton = _upButton;
@synthesize downButton = _downButton;
@synthesize titleLabel = _titleLabel;
@synthesize saveButton = _saveButton;

- (void)dealloc
{
    [_showView stop];
    PPRelease(_showView);
    [_feed release];
    [_holderView release];
    [_upButton release];
    [_downButton release];
    [_titleLabel release];
    [_saveButton release];
    [super dealloc];
}

- (id)initWithFeed:(DrawFeed *)feed
{
    self = [super init];
    if (self) {
        self.feed = feed;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleLabel setText:NSLS(@"kReplayTitle")];
    [self initToolViews];
    
    
    self.showView = [[[ShowDrawView alloc] initWithFrame:self.holderView.frame] autorelease];
    
    NSMutableArray *list =  [NSMutableArray
                             arrayWithArray:
                             self.feed.drawData.drawActionList];
    [_showView setDrawActionList:list];
//    _showView.speed = PlaySpeedTypeNormal;
    [self.view addSubview:_showView];
    [self.holderView removeFromSuperview];
    [_showView play];
}

- (void)viewDidUnload
{
    [self setHolderView:nil];
    [self setUpButton:nil];
    [self setDownButton:nil];
    [self setTitleLabel:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}

#define TOMATO_TOOLVIEW_TAG 20120718
#define FLOWER_TOOLVIEW_TAG 120120718
- (void)initToolViews
{
    ToolView* tomato = [[[ToolView alloc] initWithItemType:ItemTypeTomato number:[[ItemManager defaultManager] amountForItem:ItemTypeTomato]] autorelease];
    ToolView* flower = [[[ToolView alloc] initWithItemType:ItemTypeFlower number:[[ItemManager defaultManager] amountForItem:ItemTypeFlower]] autorelease];
    tomato.tag = TOMATO_TOOLVIEW_TAG;
    flower.tag = FLOWER_TOOLVIEW_TAG;
    [self.view addSubview:tomato];
    [self.view addSubview:flower];
    [tomato setCenter:_downButton.center];
    [flower setCenter:_upButton.center];
    [tomato addTarget:self action:@selector(clickDownButton:)];
    [flower addTarget:self action:@selector(clickUpButton:)];
    [flower setFrame:_upButton.frame];
    [tomato setFrame:_downButton.frame];
    
}

#define ITEM_TAG_OFFSET 20120728
- (BOOL)throwItem:(ToolView*)toolView
{
    
    if([[ItemManager defaultManager] hasEnoughItem:toolView.itemType] == NO){
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNoItemTitle") message:NSLS(@"kNoItemMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = ITEM_TAG_OFFSET + toolView.itemType;
        [dialog showInView:self.view];
        return NO;
    }
    UIImageView* throwingItem= [[[UIImageView alloc] initWithFrame:toolView.frame] autorelease];
    [throwingItem setImage:toolView.imageView.image];
    if (toolView.itemType == ItemTypeTomato) {
        [DrawGameAnimationManager showThrowTomato:throwingItem animInController:self rolling:YES];
    }
    if (toolView.itemType == ItemTypeFlower) {
        [DrawGameAnimationManager showThrowFlower:throwingItem animInController:self rolling:YES];
    }
    return YES;
}

- (void)setUpAndDownButtonEnabled:(BOOL)enabled
{
    [_upButton setEnabled:enabled];
    [_downButton setEnabled:enabled];
}

- (void)clickOk:(CommonDialog *)dialog
{
    switch (dialog.tag) {
        case (ItemTypeTomato + ITEM_TAG_OFFSET): {
            [CommonItemInfoView showItem:[Item tomato] infoInView:self];
        } break;
        case (ItemTypeFlower + ITEM_TAG_OFFSET): {
            [CommonItemInfoView showItem:[Item flower] infoInView:self];
        } break;
        case (ItemTypeTips + ITEM_TAG_OFFSET): {
            [CommonItemInfoView showItem:[Item tips] infoInView:self];
        } break;
        default:
            break;
    }
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)canotSendItemPopup
{
    NSString *title = [NSString stringWithFormat:NSLS(@"kCanotSendItemToContestOpus"),self.feed.itemLimit];
    return title;
}

- (IBAction)clickUpButton:(id)sender {
    
    if ([self.feed isMyOpus]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCanotSendToSelf") delayTime:1.5 isHappy:YES];
        return;
    }

    
    if (![self.feed canSendFlower]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:self.canotSendItemPopup
                                                       delayTime:1.5 
                                                         isHappy:YES];
        return;
    }
    
    ToolView* toolView = (ToolView*)sender; 
    if ([[ItemManager defaultManager] hasEnoughItem:ItemTypeFlower]) {
        // throw item animation
        if (![self throwItem:toolView]) 
            return;
        [[ItemService defaultService] sendItemAward:toolView.itemType
                                       targetUserId:_feed.author.userId
                                          isOffline:YES
                                         feedOpusId:_feed.feedId
                                         feedAuthor:_feed.author.userId]; 
        [toolView decreaseNumber];
        [self.feed increaseLocalFlowerTimes];
    } else {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNoItemTitle") message:NSLS(@"kNoItemMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = ITEM_TAG_OFFSET + toolView.itemType;
        [dialog showInView:self.view];
    }
}

- (IBAction)clickShareButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    UIImage *image = self.feed.largeImage;
    if(image == nil){
        image =  [self.showView createImage];   
    }
    
    [[ShareService defaultService] shareWithImage:image 
                                       drawUserId:_feed.feedUser.userId
                                       isDrawByMe:[_feed isMyOpus] 
                                         drawWord:_feed.wordText];    
    
    
    [[DrawDataService defaultService] savePaintWithPBDraw:_feed.pbDraw image:image delegate:self];
    button.userInteractionEnabled = NO;
}

- (IBAction)clickDownButton:(id)sender {
    
    if ([self.feed isMyOpus]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCanotSendToSelf") delayTime:1.5 isHappy:YES];
        return;
    }

    
    if (![self.feed canThrowTomato]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:self.canotSendItemPopup
                                                       delayTime:1.5 
                                                         isHappy:YES];
        return;
    }
    
    ToolView* toolView = (ToolView*)sender;
    
    if ([[ItemManager defaultManager] hasEnoughItem:ItemTypeTomato]) {
        // throw item animation
        if (![self throwItem:toolView]) 
            return;
        
        // send request
        [[ItemService defaultService] sendItemAward:toolView.itemType
                                       targetUserId:_feed.author.userId
                                          isOffline:YES
                                         feedOpusId:_feed.feedId
                                         feedAuthor:_feed.author.userId];
        
        [toolView decreaseNumber];
        [self.feed increaseLocalTomatoTimes];
    }else{
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNoItemTitle") message:NSLS(@"kNoItemMessage") style:CommonDialogStyleDoubleButton delegate:self];
        dialog.tag = ITEM_TAG_OFFSET + toolView.itemType;
        [dialog showInView:self.view];
    }
}

- (void)didSaveOpus:(BOOL)succ
{
    [self hideActivity];
    self.saveButton.userInteractionEnabled = YES;
    if (succ) {
        [self popupMessage:NSLS(@"kSaveOpusOK") title:nil];
    }else{
        [self popupMessage:NSLS(@"kSaveImageFail") title:nil];
    }
}

#pragma mark - commonItemInfoView delegate
- (void)didBuyItem:(Item *)anItem 
            result:(int)result
{
    if (result == 0) {
        [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kBuySuccess") delayTime:1 isHappy:YES];
        ToolView* toolview = nil;
        switch (anItem.type) {
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
    if (result == ERROR_COINS_NOT_ENOUGH)
    {
        [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
    }
}

@end
