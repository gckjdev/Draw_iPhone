//
//  ZJHAvatarView.m
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import "ZJHAvatarView.h"

@implementation ZJHAvatarView
@synthesize roundAvatar = _roundAvatar;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize nickNameLabel = _nickNameLabel;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_roundAvatar release];
    [_backgroundImageView release];
    [_nickNameLabel release];
    [super dealloc];
}

@end
