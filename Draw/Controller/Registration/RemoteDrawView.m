//
//  RemoteDrawView.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "RemoteDrawView.h"
#import "RemoteDrawData.h"
#import "ShareImageManager.h"
#import "PPApplication.h"

@implementation RemoteDrawView
@synthesize avatarImage;
@synthesize nickNameLabel;
@synthesize paintButton;

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
        NSLog(@"create <RemoteDrawView> but cannot find cell object from Nib");
        return nil;
    }
    RemoteDrawView* button =  (RemoteDrawView*)[topLevelObjects objectAtIndex:0];
    return button;
}

- (void)setViewByRemoteDrawData:(RemoteDrawData *)remoteDrawData
{
    [avatarImage setImage:[[ShareImageManager defaultManager] avatarUnSelectImage]];
    [avatarImage setUrl:[NSURL URLWithString:remoteDrawData.avatar]];
    [GlobalGetImageCache() manage:avatarImage];
    
    
    [nickNameLabel setText:remoteDrawData.nickName];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [avatarImage release];
    [nickNameLabel release];
    [paintButton release];
    [super dealloc];
}

@end
