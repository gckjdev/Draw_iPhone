//
//  GroupModelExt.m
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import "GroupModelExt.h"
#import "TimeUtils.h"
#import "GroupConstants.h"

typedef enum{
    TypeBulletin = 0,
    TypeRequest = 1,
    TypeExpel = 2,
    TypeAccept = 3,
    TypeReject = 4,
    TypeQuit = 5, 

    TypeInviteMember = 6,
    TypeInviteGuest = 7,

    TypeRejectMemberInvitation = 8,
    TypeRejectGuestInvitation = 9,
    
    TypeAcceptMemberInvitation = 10,
    TypeAcceptGuestInvitation = 11,
    
}NoticeType;





@implementation PBGroupNotice(Ext)

- (BOOL)isInvitation
{
    return TypeInviteMember == self.type || TypeInviteGuest == self.type;
}
- (BOOL)isJoinRequest
{
    return TypeRequest == self.type;
}

- (NSString *)desc
{
    switch (self.type) {
        case TypeBulletin:
            return [NSString stringWithFormat:NSLS(@"kGroupBulletinDesc"), [self publisherName], self.groupName];
            
        case TypeRequest:
            return [NSString stringWithFormat:NSLS(@"kGroupJoinDesc"), [self publisherName], self.groupName];
        case TypeExpel:
            return [NSString stringWithFormat:NSLS(@"kGroupExpelDesc"), [self publisherName], [self targetName], self.groupName];
        case TypeQuit:
            return [NSString stringWithFormat:NSLS(@"kGroupQuitDesc"), [self publisherName], self.groupName];
            
        case TypeAccept:
            return [NSString stringWithFormat:NSLS(@"kGroupAcceptDesc"), [self publisherName], [self targetName], self.groupName];
        case TypeReject:
            return [NSString stringWithFormat:NSLS(@"kGroupRejectDesc"), [self publisherName], [self targetName], self.groupName];

        case TypeInviteMember:
            return [NSString stringWithFormat:NSLS(@"kGroupInviteMemberDesc"), [self publisherName], [self targetName], self.groupName];
            
        case TypeInviteGuest:
            return [NSString stringWithFormat:NSLS(@"kGroupInviteGuestDesc"), [self publisherName], [self targetName], self.groupName];
            
        case TypeRejectMemberInvitation:
            return [NSString stringWithFormat:NSLS(@"kGroupRejectMemberInvitationDesc"), [self publisherName], [self targetName], self.groupName];
        case TypeRejectGuestInvitation:
            return [NSString stringWithFormat:NSLS(@"kGroupRejectGuestInvitationDesc"), [self publisherName], [self targetName], self.groupName];
            
        case TypeAcceptMemberInvitation:
            return [NSString stringWithFormat:NSLS(@"TypeAcceptMemberInvitation"), [self publisherName], self.groupName];
        case TypeAcceptGuestInvitation:
            return [NSString stringWithFormat:NSLS(@"TypeAcceptGuestInvitation"), [self publisherName], self.groupName];

        default:
            return nil;
    }

}

- (NSString *)publisherName
{
    if ([[UserManager defaultManager] isMe:self.publisher.userId]) {
        return NSLS(@"kI");
    }else{
        return self.publisher.nickName;
    }
}

- (NSString *)targetName
{
    if ([[UserManager defaultManager] isMe:self.target.userId]) {
        return NSLS(@"kMe");
    }else{
        return self.target.nickName;
    }
}


- (NSString *)msg
{
    if ([self.message length] == 0) {
        return nil;
    }
    switch (self.type) {
        case TypeBulletin:
            return [NSString stringWithFormat:NSLS(@"kContentDesc"), [self message]];

        case TypeRequest:
        case TypeExpel:
        case TypeReject:
            return [NSString stringWithFormat:NSLS(@"kPostscriptDesc"), [self message]];

        case TypeQuit:
        case TypeAccept:
        default:
            return nil;
    }
}

- (NSDate *)cDate
{
    return [NSDate dateWithTimeIntervalSince1970:self.createDate];
}

- (NSString *)createDateString
{
    return dateToTimeLineString(self.cDate);
}


@end


@implementation PBGroup(Ext)

- (NSURL *)medalImageURL
{
    return [NSURL URLWithString:self.medalImage];
}
- (NSURL *)bgImageURL
{
    return [NSURL URLWithString:self.bgImage];
}

- (NSUInteger)hash
{
    return [groupId hash];
}

- (BOOL)isEqual:(id)object
{
    PBGroup *other = object;
    return [self.groupId isEqualToString:other.groupId];
}

- (NSString *)creatorNickName
{
    if ([self creatorIsMe]) {
        return NSLS(@"kMe");
    }else{
        return self.creator.nickName;
    }
}
- (BOOL)creatorIsMe
{
   return [[UserManager defaultManager] isMe:self.creator.userId];
}

- (PBGroupUsersByTitle *)adminsByTitle
{
    PBGroupUsersByTitle_Builder *builder = [[PBGroupUsersByTitle_Builder alloc] init];
    PBGroupTitle_Builder *titleBuilder = [[PBGroupTitle_Builder alloc] init];
    [titleBuilder setTitle:NSLS(@"kAdmin")];
    [titleBuilder setTitleId:GroupRoleAdmin];
    [builder setTitle:[titleBuilder build]];
    if ([self.adminsList count] > 0) {
        [builder addAllUsers:self.adminsList];
    }
    PBGroupUsersByTitle *adminTitles = [builder build];
    [titleBuilder release];
    [builder release];
    return adminTitles;
}

- (PBGroupUsersByTitle *)guestsByTitle
{
    PBGroupUsersByTitle_Builder *builder = [[PBGroupUsersByTitle_Builder alloc] init];
    PBGroupTitle_Builder *titleBuilder = [[PBGroupTitle_Builder alloc] init];
    [titleBuilder setTitle:NSLS(@"kGuest")];
    [titleBuilder setTitleId:GroupRoleGuest];
    [builder setTitle:[titleBuilder build]];
    if ([self.guestsList count] > 0) {
        [builder addAllUsers:self.guestsList];
    }
    PBGroupUsersByTitle *adminTitles = [builder build];
    [titleBuilder release];
    [builder release];
    return adminTitles;
}

@end

@implementation PBGroupTitle(Ext)

- (BOOL)isCustomTitle
{
    if (self.titleId >= CUSTOM_TITLE_START) {
        return YES;
    }
    return NO;
}

- (BOOL)isAdminTitle
{
    return self.titleId == GroupRoleAdmin ||
    self.titleId == GroupRoleCreator;
}

@end

@implementation PBGroupUsersByTitle (Ext)

- (BOOL)isCustomTitle
{
    return [self.title isCustomTitle];
}

- (BOOL)isAdminTitle
{
    return [self.title isAdminTitle];
}

- (NSString *)titleName
{
    return self.title.title;
}

- (NSString *)firstMemberNickName
{
    NSArray *list = self.usersList;
    if ([list count] > 0) {
        PBGameUser *user = list[0];
        return user.nickName;
    }
    return @"";
}

- (NSString *)desc
{
    return [NSString stringWithFormat:NSLS(@"kGroupTitleDesc"), [self titleName], [[self usersList] count]];
}
@end

@implementation PBGameUser(Ext)

- (NSUInteger)hash
{
    return self.userId.hash;
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}


@end


@implementation PBGroupUserRole(Ext)


@end

