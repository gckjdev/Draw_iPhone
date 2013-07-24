//
//  UserNumberService.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "UserNumberService.h"
#import "UserManager.h"
#import "PPGameNetworkRequest.h"

@implementation UserNumberService

static UserNumberService* _defaultUserService;

+ (UserNumberService*)defaultService
{
    if (_defaultUserService == nil)
        _defaultUserService = [[UserNumberService alloc] init];
    
    return _defaultUserService;
}

- (void)getAndRegisterNumber:(UserNumberServiceResultBlock)block
{
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        PPDebug(@"<getAndRegisterNumber> user already has xiaoji number, skip");
        return;
    }
    
    dispatch_async(workingQueue, ^{

        CommonNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_GET_NEW_NUMBER
                                                                             parameters:nil
                                                                          isReturnArray:NO];
        
        NSString* number = [output.jsonDataDict objectForKey:PARA_XIAOJI_NUMBER];
        if (output.resultCode == 0){
            // save number
            [[UserManager defaultManager] setXiaojiNumber:number];
        }

        if (block != NULL){
           block(output.resultCode, number);
        }
        
    });
}


@end
