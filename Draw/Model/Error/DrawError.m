#import "DrawError.h"

extern NSString* GlobalGetTrafficServerURL();

@implementation DrawError

#define KEY(intX) @(intX)




+ (NSString *)errorMessageForCode:(NSInteger)code
{
    NSDictionary *errorMSGDict =
    @{
      
      KEY(ERROR_GROUP_DUPLICATE_NAME) : NSLS(@"kDuplicateGroupName"),
      KEY(ERROR_PARAMETER_GROUPID_EMPTY) : NSLS(@"kGroupIDEmpty"),
      KEY(ERROR_PARAMETER_GROUPID_NULL) : NSLS(@"kGroupIDEmpty"),      
      KEY(ERROR_GROUP_MULTIJOINED) : NSLS(@"kGroupMultiGroupsJoined"),
      KEY(ERROR_GROUP_MULTIREQUESTED) : NSLS(@"kGroupMultiGroupRequests"),
      KEY(ERROR_GROUP_PERMISSION) : NSLS(@"kGroupPermissionDenied"),
      KEY(ERROR_GROUP_FULL) : NSLS(@"kGroupMembersFull"),
      KEY(ERROR_GROUP_REJECTED) : NSLS(@"kGroupRequestWasRejected"),

      KEY(ERROR_GROUP_USER_NOT_REQUESTSTATUS) : NSLS(@"kNotRequestStatus"),
      KEY(ERROR_GROUP_INVALIDATE_ROLE) : NSLS(@"kInvalidateRole"),
      KEY(ERROR_GROUP_MEMBER_UNFOLLOW) : NSLS(@"kGroupMemberCanotUnfollowGroup"),
      KEY(ERROR_GROUP_REPEAT_FOLLOW) : NSLS(@"kRepeatFollowGroup"),
      KEY(ERROR_GROUP_NOTEXIST) : NSLS(@"kGroupNotExist"),
      KEY(ERROR_GROUP_LEVEL_SMALL) : NSLS(@"kGroupUpgradeSmall"), 

      KEY(ERROR_GROUP_NAME_EMPTY) : NSLS(@"kGroupNameIsEmpty"),
      KEY(ERROR_GROUP_NAME_TOO_LONG) : NSLS(@"kGroupNameTooLong"),
      
      KEY(ERROR_PARAMETER_NOTICEID_EMPTY): NSLS(@"kGroupNoticeIDEmpty"),
      KEY(ERROR_PARAMETER_NOTICEID_NULL): NSLS(@"kGroupNoticeIDEmpty"),
      KEY(ERROR_GROUP_REQUEST_HANDLE_TYPE_INVALID): NSLS(@"kInvalidHandleType"),
      KEY(ERROR_GROUP_NOTICE_NOTFOUND): NSLS(@"kGroupNoticeNotFound"),
      KEY(ERROR_GROUP_TITLEID_EXISTED)   : NSLS(@"kTitleIDExits"),
      KEY(ERROR_GROUP_NOT_MEMBER): NSLS(@"kNotGroupMember"),
      KEY(ERROR_GROUP_NOT_ADMIN): NSLS(@"kNotGroupAdmin"),
      KEY(ERROR_GROUP_NOT_INVITEE): NSLS(@"kNotInvitee"),
      KEY(ERROR_GROUP_TITLEID_NOTEXISTED)   : NSLS(@"kTitleIDNotFound"),
      KEY(ERROR_BALANCE_NOT_ENOUGH) : NSLS(@"kBalanceNotEnough"),
      KEY(ERROR_GROUP_BALANCE_NOT_ENOUGH) : NSLS(@"kGroupBalanceNotEnough"),
//      KEY(ERROR_GROUP_CREATION): NSLS(@"kCan'tCreateGroup"),
      };
    NSString *errorMessage = errorMSGDict[KEY(code)];    
    return [errorMessage length] == 0 ? NSLS(@"kUnknowError") : errorMessage;
}

+ (NSError *)errorWithCode:(NSInteger) code
{
    if (code == 0) {
        return nil;
    }
    NSString *errorMessage = [self errorMessageForCode:code];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorMessage};
    return [NSError errorWithDomain:GlobalGetTrafficServerURL() code:code userInfo:userInfo];
}

+ (void)postError:(NSError *)error
{
    POSTMSG([error localizedDescription]);
}

+ (void)postErrorWithCode:(NSInteger) code
{
    [self postError:[self errorWithCode:code]];
}

@end