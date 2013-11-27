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
    TypeQuit = 5
    
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
            return [NSString stringWithFormat:NSLS(@"kGroupAcceptDesc"), [self publisherName], self.groupName];
        case TypeReject:
            return [NSString stringWithFormat:NSLS(@"kGroupRejectDesc"), [self publisherName], [self targetName], self.groupName];
            
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
