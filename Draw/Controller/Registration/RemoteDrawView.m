//
//  RemoteDrawView.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "RemoteDrawView.h"
#import "ShareImageManager.h"
#import "PPApplication.h"
#import "GameBasic.pb.h"
#import "Draw.pb.h"
#import "LogUtil.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "UIImageExt.h"
#import "DrawUtils.h"

@interface RemoteDrawView () 

@property (assign, nonatomic) int index;

@end

@implementation RemoteDrawView
@synthesize avatarImage;
@synthesize nickNameLabel;
@synthesize showDrawView;
@synthesize playbackButton;
@synthesize index;
@synthesize delegate;
@synthesize wordLabel;


- (void)dealloc {
    [showDrawView stop];
    PPRelease(avatarImage);
    PPRelease(nickNameLabel);
    PPRelease(showDrawView);
    PPRelease(playbackButton);
    PPRelease(wordLabel);
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


+ (RemoteDrawView*)creatRemoteDrawView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RemoteDrawView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"create <RemoteDrawView> but cannot find cell object from Nib");
        return nil;
    }
    RemoteDrawView* button =  (RemoteDrawView*)[topLevelObjects objectAtIndex:0];
    return button;
}


- (void)setViewByRemoteDrawData:(PBDraw *)remoteDrawData index:(int)aIndex
{
    PPDebug(@"avatar:%@",remoteDrawData.avatar);
    PPDebug(@"nickName:%@",remoteDrawData.nickName);
    PPDebug(@"word:%@",remoteDrawData.word);
    
    self.index = aIndex;
    
    //set word
    wordLabel.text = remoteDrawData.word;
    wordLabel.hidden = YES;
    
    //set avatar
    [avatarImage setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    if ([remoteDrawData.avatar length] > 0) {
        [avatarImage setUrl:[NSURL URLWithString:remoteDrawData.avatar]];
        [GlobalGetImageCache() manage:avatarImage];
    }
    
    
    //set nickName
    [nickNameLabel setText:remoteDrawData.nickName];
    
    //set drawView
    showDrawView.frame = DRAW_VIEW_FRAME;
    showDrawView.center = playbackButton.center;
    CGFloat multiple = self.playbackButton.frame.size.height / showDrawView.frame.size.height;
    showDrawView.transform = CGAffineTransformMakeScale(multiple, multiple);
    NSMutableArray *drawActionList = [[NSMutableArray alloc] init];
    for (PBDrawAction *pbDrawAction in remoteDrawData.drawDataList) {
        DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:pbDrawAction];
        [drawActionList addObject:drawAction];
        [drawAction release];
    }
    
    //画笔的缩放
    NSMutableArray *scaleActionList = nil;
    if ([DeviceDetection isIPAD]) {
        scaleActionList = [DrawAction scaleActionList:drawActionList 
                                               xScale:IPAD_WIDTH_SCALE 
                                               yScale:IPAD_HEIGHT_SCALE];
    } else {
        scaleActionList = drawActionList;
    }
    [showDrawView setDrawActionList:scaleActionList];
    [drawActionList release];
    
    
//    showDrawView.speed = PlaySpeedTypeNormal;
}


- (IBAction)clickPlaybackButton:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(didClickPlaybackButton:)]) {
        [delegate didClickPlaybackButton:self.index];
    }
}



@end
