#import "DrawError.h"

extern NSString* GlobalGetTrafficServerURL();

@implementation DrawError

#define KEY(intX) @(intX)



#define ERROR_GROUP_USER_NOT_REQUESTSTATUS  200011
#define ERROR_GROUP_INVALIDATE_ROLE  200012
#define ERROR_GROUP_MEMBER_UNFOLLOW  200013
#define ERROR_GROUP_REPEAT_FOLLOW  200014
#define ERROR_GROUP_NOTEXIST  200015
#define ERROR_GROUP_LEVEL_SMALL  200016


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
      
//      ERROR_BALANCE_NOT_ENOUGH
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