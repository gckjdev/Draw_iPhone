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

@implementation RemoteDrawView
@synthesize avatarImage;
@synthesize nickNameLabel;
@synthesize paintButton;
@synthesize showDrawView;

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

- (void)setViewByRemoteDrawData:(PBDraw *)remoteDrawData
{
    PPDebug(@"avatar:%@",remoteDrawData.avatar);
    PPDebug(@"nickName:%@",remoteDrawData.nickName);
    PPDebug(@"word:%@",remoteDrawData.word);
    
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
    showDrawView.frame = DRAW_VEIW_FRAME;
    showDrawView.center = paintButton.center;
    [showDrawView setDrawActionList:drawActionList];
    [drawActionList release];
    showDrawView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    
}

- (void)dealloc {
    [avatarImage release];
    [nickNameLabel release];
    [paintButton release];
    [showDrawView release];
    [super dealloc];
}

@end
