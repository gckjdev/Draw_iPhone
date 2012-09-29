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

#define KEY_

@interface ReplayContestDrawController ()
@property (retain, nonatomic) DrawFeed *feed;
@end

@implementation ReplayContestDrawController
@synthesize holderView = _holderView;
@synthesize feed = _feed;
@synthesize showView = _showView;

- (void)dealloc
{
    [_showView stop];
    PPRelease(_showView);
    [_feed release];
    [_holderView release];
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
    
    self.showView = [[[ShowDrawView alloc] initWithFrame:self.holderView.frame] autorelease];
    
    NSMutableArray *list =  [NSMutableArray
                             arrayWithArray:
                             self.feed.drawData.drawActionList];
    [_showView setDrawActionList:list];
    double speed = [DrawAction calculateSpeed:_showView.drawActionList defaultSpeed:1.0/40.0 maxSecond:45];
    _showView.playSpeed = speed;
    [self.view addSubview:_showView];
    [self.holderView removeFromSuperview];
    [_showView play];
}

- (void)viewDidUnload
{
    [self setHolderView:nil];
    [super viewDidUnload];
}

#define ITEM_TAG_OFFSET 20120728
- (BOOL)throwItem:(ToolView*)toolView
{
    
    if([[ItemManager defaultManager] hasEnoughItem:toolView.itemType] == NO){
        //TODO go the shopping page.
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

- (IBAction)clickUpButton:(id)sender {
    if ([self.feed canSendFlower]) {
        
    }
}

- (IBAction)clickShareButton:(id)sender {
}

- (IBAction)clickDownButton:(id)sender {
    if ([self.feed canThrowTomato]) {
        //send 
    }else{
        //TIPS
    }
}
@end
