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
        if ([pbFeed.targetUserId length] != 0) {
            self.targetUser = [FeedUser feedUserWithUserId:pbFeed.targetUserId
                                                  nickName:pbFeed.targetUserNickName
                                                    avatar:nil
                                                    gender:YES
                                                 signature:pbFeed.signature
                                                       vip:pbFeed.vip];
        }
    }
    return self;
}


#define KEY_TARGET_USER @"TARGET_USER"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.targetUser = [aDecoder decodeObjectForKey:KEY_TARGET_USER];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.targetUser forKey:KEY_TARGET_USER];
}


- (void)updateDesc
{
    if ([self hasGuessed] || [self isMyOpus]) {
        if([self isDrawCategory]){
//            self.desc = [NSString stringWithFormat:NSLS(@"kDrawToUserDesc"), self.wordText,self.targetUser.nickName];
            
            if([self.opusDesc isEqualToString:@""]){
                self.desc = NSLS(@"kDrawToUserNoWordDesc");
            }else{
                self.desc = self.opusDesc;
            }
            
        }else if ([self isSingCategory]){
            self.desc = [NSString stringWithFormat:NSLS(@"kRecordToUserDesc"), self.wordText,self.targetUser.nickName];
        }
    }else{
        if([self isDrawCategory]){
//            self.desc = [NSString stringWithFormat:NSLS(@"kDrawToUserNoWordDesc"), self.targetUser.nickName];
            if([self.opusDesc isEqualToString:@""]){
                self.desc = NSLS(@"kDrawDescNoWord");
            }else{
                self.desc = self.opusDesc;
            }
           
        }else if ([self isSingCategory]){
            self.desc = [NSString stringWithFormat:NSLS(@"kRecordToUserNoWordDesc"), self.targetUser.nickName];
        }
    }
}

- (void)dealloc
{
    PPRelease(_targetUser);
    [super dealloc];
}
@end
