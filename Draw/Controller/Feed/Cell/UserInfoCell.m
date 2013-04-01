//
//  UserInfoCell.m
//  Draw
//
//  Created by  on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserInfoCell.h"
//#import "FeedService.h"
//#import "ShareImageManager.h"
@implementation UserInfoCell
@synthesize nickLabel;
@synthesize avatarView;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    UserInfoCell *cell = [topLevelObjects objectAtIndex:0];
    cell.delegate = delegate;
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"UserInfoCell";
}

+ (CGFloat)getCellHeight
{
    if ([DeviceDetection isIPAD]) {
        return 115.0f;
    }
    return 45.0f;
}

- (void)setCellInfo:(DrawFeed *)feed
{
    CGRect frame = self.avatarView.frame;
    [self.avatarView removeFromSuperview];
    NSString *userId = feed.author.userId;
    NSString *avatar = feed.author.avatar;
    NSString *nickName = feed.author.nickName;
    
    BOOL gender =  feed.author.gender;
    
    self.avatarView = [[[AvatarView alloc] initWithUrlString:avatar frame:frame gender:gender level:0] autorelease];
    [(AvatarView *)self.avatarView setUserId:userId];
    [self.avatarView setUserInteractionEnabled:NO];
    [self addSubview:self.avatarView];
//    self.avatarView.delegate = self;
    
    //name
//    if ([feed.author.signture length] > 0) {
    if (NO) {
        self.nickNameLabel.hidden = NO;
        self.signLabel.hidden = NO;
        self.nickLabel.hidden = YES;
        self.nickNameLabel.text = nickName;
//        self.signLabel.text = feed.author.signture;
    }else{
        self.nickNameLabel.hidden = YES;
        self.signLabel.hidden = YES;
        self.nickLabel.hidden = NO;
        [self.nickLabel setText:nickName];
    }
}

- (void)dealloc {
    PPDebug(@"%@ dealloc",self);
    PPRelease(nickLabel);
    PPRelease(avatarView);
    [_nickNameLabel release];
    [_signLabel release];
    [super dealloc];
}
@end






