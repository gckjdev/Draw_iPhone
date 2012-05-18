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


- (void)dealloc {
    [avatarImage release];
    [nickNameLabel release];
    [showDrawView release];
    [playbackButton release];
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
    
    //set avatar
    [avatarImage setImage:[[ShareImageManager defaultManager] avatarUnSelectImage]];
    [avatarImage setUrl:[NSURL URLWithString:remoteDrawData.avatar]];
    [GlobalGetImageCache() manage:avatarImage];
    
    //set nickName
    [nickNameLabel setText:remoteDrawData.nickName];
    
    //set drawView
    NSMutableArray *drawActionList = [[NSMutableArray alloc] init];
    for (PBDrawAction *pbDrawAction in remoteDrawData.drawDataList) {
        DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:pbDrawAction];
        [drawActionList addObject:drawAction];
        [drawAction release];
    }
    [showDrawView setDrawActionList:drawActionList];
    [drawActionList release];
    if ([DeviceDetection isIPAD]) {
        showDrawView.frame = DRAW_VEIW_FRAME_IPAD;
    }else {
        showDrawView.frame = DRAW_VEIW_FRAME;
    }
    showDrawView.center = playbackButton.center;
    CGFloat multiple = self.playbackButton.frame.size.height / showDrawView.frame.size.height;
    showDrawView.transform = CGAffineTransformMakeScale(multiple, multiple);
    showDrawView.playSpeed = 2/40.0;
}


- (IBAction)clickPlaybackButton:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(didClickPlaybackButton:)]) {
        [delegate didClickPlaybackButton:self.index];
    }
}



@end
