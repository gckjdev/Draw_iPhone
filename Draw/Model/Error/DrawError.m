#import "DrawError.h"
//#import "DrawAppDelegate.h"
#import "GameNetworkConstants.h"
#import "CommonMessageCenter.h"

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

@end