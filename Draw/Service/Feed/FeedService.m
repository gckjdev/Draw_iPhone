//
//  FeedService.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "GameNetworkConstants.h"

static FeedService *_staticFeedService = nil;
@implementation FeedService

+ (FeedService *)defaultService
{
    if (_staticFeedService == nil) {
        _staticFeedService = [[FeedService alloc] init];
    }
    return _staticFeedService;
}

- (void)getFeedList:(FeedListType)feedListType 
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(id<FeedServiceDelegate>)delegate;
{
    
    NSString *userId = [[UserManager defaultManager] userId];
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       getFeedListWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:userId 
                                       feedListType:feedListType 
                                       offset:offset 
                                       limit:limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *list = nil;
            NSInteger resultCode = output.resultCode;
            if (resultCode == ERROR_SUCCESS){
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *pbFeedList = [response feedList];
                if ([pbFeedList count] != 0) {
                    list = [NSMutableArray array];    
                    for (PBFeed *pbFeed in pbFeedList) {
                        Feed *feed = [[Feed alloc] initWithPBFeed:pbFeed];
                        [list addObject:feed];
                    }
                }
            }
            if (delegate && [delegate respondsToSelector:@selector(didGetFeedList:resultCode:)]) {
                [delegate didGetFeedList:list resultCode:resultCode];
            }
            
        });
    });

}


@end
