//
//  GroupModelExt.h
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import <Foundation/Foundation.h>
#import "Group.pb.h"

@interface PBGroupNotice(Ext)

- (NSString *)desc;
- (NSString *)msg;
- (NSString *)createDateString;

- (BOOL)isInvitation;
- (BOOL)isGuestInvitation;
- (BOOL)isJoinRequest;
@end

@interface PBGroup(Ext)

- (NSURL *)medalImageURL;
- (NSURL *)bgImageURL;
- (NSString *)creatorNickName;
- (BOOL)creatorIsMe;

- (PBGroupUsersByTitle *)adminsByTitle;
- (PBGroupUsersByTitle *)guestsByTitle;

@end

@interface PBGroupTitle(Ext)

- (BOOL)isCustomTitle;
- (BOOL)isAdminTitle;

@end


@interface PBGroupUsersByTitle(Ext)

//- (BOOL)isCreator;
- (BOOL)isCustomTitle;
- (BOOL)isAdminTitle;
- (NSString *)titleName;
- (NSString *)desc;

@end




@interface PBGameUser(Ext)

@end


@interface PBGroupUserRole(Ext) 

@end