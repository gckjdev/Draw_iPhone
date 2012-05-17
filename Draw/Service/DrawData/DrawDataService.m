//
//  DrawDataService.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "DrawDataService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "GameMessage.pb.h"


static DrawDataService* _defaultDrawDataService = nil;

@implementation DrawDataService

+ (DrawDataService *)defaultService{
    if (_defaultDrawDataService == nil) {
        _defaultDrawDataService = [[DrawDataService alloc] init];
    }
    return _defaultDrawDataService;
}


- (void)findRecentDraw:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest findDrawWithProtocolBuffer:SERVER_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *list = nil;
            
            if (output.resultCode == ERROR_SUCCESS){
                DataQueryResponse *travelResponse = [DataQueryResponse parseFromData:output.responseData];
                list = [travelResponse drawDataList];
            }
            if ([viewController respondsToSelector:@selector(didFindRecentDraw:result:)]){
                [viewController didFindRecentDraw:list result:output.resultCode];
            }
        });
    });
}

@end
