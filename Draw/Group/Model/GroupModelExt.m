//
//  GroupModelExt.m
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import "GroupModelExt.h"
#import "TimeUtils.h"


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
    
}GroupNoticeType;


@implementation PBGroupNotice(Ext)

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

@end