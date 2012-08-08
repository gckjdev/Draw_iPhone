//
//  DrawToUserFeed.m
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawToUserFeed.h"

@implementation DrawToUserFeed
@synthesize targetUser = _targetUser;

- (id)initWithPBFeed:(PBFeed *)pbFeed
{
    self = [super initWithPBFeed:pbFeed];
    if (self) {
        self.targetUser = [FeedUser feedUserWithUserId:pbFeed.targetUserId nickName:pbFeed.targetUserNickName avatar:nil gender:YES];
    }
    return self;
}

- (void)updateDesc
{
    if ([self hasGuessed]) {
        self.desc = [NSString stringWithFormat:NSLS(@"kDrawToUserDesc"), self.wordText,self.targetUser.nickName];      
    }else{
        self.desc = [NSString stringWithFormat:NSLS(@"kDrawToUserNoWordDesc"), self.targetUser.nickName];      
    }

}

- (void)dealloc
{
    PPRelease(_targetUser);
    [super dealloc];
}
@end
