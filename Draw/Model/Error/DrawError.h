//Error manager.

#import "GameNetworkConstants.h"

#define DRAW_ERROR(x) [DrawError errorWithCode:x]

@interface DrawError : NSObject {

}

+ (NSError *)errorWithCode:(NSInteger) code;
+ (void)postError:(NSError *)error;
+ (void)postErrorWithCode:(NSInteger) code;

@end