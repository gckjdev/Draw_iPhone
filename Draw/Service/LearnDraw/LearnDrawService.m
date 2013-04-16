//
//  LearnDrawService.m
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "LearnDrawService.h"
#import "GameNetworkConstants.h"
#import "GameNetworkRequest.h"
#import "ConfigManager.h"
#import "UserManager.h"
#import "Draw.pb.h"
#import "GameMessage.pb.h"
#import "LearnDrawManager.h"
#import "FeedManager.h"
#import "BalanceNotEnoughAlertView.h"
#import "AccountService.h"
#import "UIViewUtils.h"
//#import "<#header#>"


@implementation LearnDrawService

SYNTHESIZE_SINGLETON_FOR_CLASS(LearnDrawService)


- (NSString *)userId
{
    return [[UserManager defaultManager] userId];
}

- (void)addOpusToLearnDrawPool:(NSString *)opusId
                         price:(NSInteger)price
                          type:(LearnDrawType)type
                 resultHandler:(RequestDictionaryResultHandler)handler
{
    if ([[self userId] length] == 0) {
        return;
    }
    dispatch_async(workingQueue, ^{
        
        NSDictionary *dict = @{PARA_OPUS_ID : opusId,
                               PARA_USERID : [[UserManager defaultManager] userId],
                               PARA_APPID : [ConfigManager appId],
                               PARA_PRICE : [@(price) stringValue],
                               PARA_TYPE : [@(type) stringValue]
                               };
        
        CommonNetworkOutput *output = [GameNetworkRequest sendGetRequestWithBaseURL:
                                       TRAFFIC_SERVER_URL
                                                                             method:METHOD_ADD_LEARN_DRAW
                                                                         parameters:dict
                                                                           returnPB:NO
                                                                        returnArray:NO];

        NSInteger resultCode = output.resultCode;
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(handler,nil,resultCode);
        });
    });
}


- (void)buyLearnDraw:(NSString *)opusId
               price:(int)price
            fromView:(UIView *)fromView
       resultHandler:(RequestDictionaryResultHandler)handler
{
    if ([[self userId] length] == 0) {
        return;
    }

    if (![[AccountService defaultService] hasEnoughBalance:price
                                                 currency:PBGameCurrencyIngot]) {
        [BalanceNotEnoughAlertView showInController:[fromView theViewController]];
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *dict = @{PARA_OPUS_ID : opusId,
                               PARA_USERID : [[UserManager defaultManager] userId],
                               PARA_APPID : [ConfigManager appId],
                               };
        
        CommonNetworkOutput *output = [GameNetworkRequest sendGetRequestWithBaseURL:
                                       TRAFFIC_SERVER_URL
                                                                             method:METHOD_BUY_LEARN_DRAW
                                                                         parameters:dict
                                                                           returnPB:NO
                                                                        returnArray:NO];
        
        NSInteger resultCode = output.resultCode;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultCode == ERROR_SUCCESS) {
                [[LearnDrawManager defaultManager] addBoughtOpusId:opusId];
                [[AccountService defaultService] chargeIngot:-price source:ChargeLearnDraw];
            }
            EXECUTE_BLOCK(handler,nil,resultCode);
        });
    });
}


- (void)removeLearnDraw:(NSString *)opusId
          resultHandler:(RequestDictionaryResultHandler)handler
{
    if ([[self userId] length] == 0) {
        return;
    }

    dispatch_async(workingQueue, ^{
        
        NSDictionary *dict = @{PARA_OPUS_ID : opusId,
                               PARA_USERID : [[UserManager defaultManager] userId],
                               PARA_APPID : [ConfigManager appId],
                               };
        
        CommonNetworkOutput *output = [GameNetworkRequest sendGetRequestWithBaseURL:
                                       TRAFFIC_SERVER_URL
                                                                             method:METHOD_REMOVE_LEARN_DRAW
                                                                         parameters:dict
                                                                           returnPB:NO
                                                                        returnArray:NO];
        
        NSInteger resultCode = output.resultCode;
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(handler,nil,resultCode);
        });
    });

}


- (void)getAllBoughtLearnDrawIdListWithResultHandler:(RequestArrayResultHandler)handler
{
    if ([[self userId] length] == 0) {
        return;
    }

    dispatch_async(workingQueue, ^{
        
        NSDictionary *dict = @{
                               PARA_USERID : [[UserManager defaultManager] userId],
                               PARA_APPID : [ConfigManager appId],
                               };
        
        CommonNetworkOutput *output = [GameNetworkRequest sendGetRequestWithBaseURL:
                                       TRAFFIC_SERVER_URL
                                                                             method:METHOD_GET_USER_LEARDRAWID_LIST
                                                                         parameters:dict
                                                                           returnPB:YES
                                                                        returnArray:NO];
        
        NSInteger resultCode = output.resultCode;
        NSArray *list = nil;
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            list = response.idListList;
        }
        @catch (NSException *exception) {
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultCode == ERROR_SUCCESS) {
                [[LearnDrawManager defaultManager] updateBoughtList:list];
            }
            EXECUTE_BLOCK(handler,list,resultCode);
        });
    });
}

- (void)getBoughtLearnDrawOpusListWithOffset:(NSInteger)offset
                                       limit:(NSInteger)limit
                               ResultHandler:(RequestArrayResultHandler)handler
{
    if ([[self userId] length] == 0) {
        return;
    }

    dispatch_async(workingQueue, ^{
        
        NSDictionary *dict = @{
                               PARA_USERID : [[UserManager defaultManager] userId],
                               PARA_APPID : [ConfigManager appId],
                               PARA_OFFSET: [@(offset) stringValue],
                               PARA_LIMIT : [@(limit) stringValue]
                               };
        
        CommonNetworkOutput *output = [GameNetworkRequest sendGetRequestWithBaseURL:
                                       TRAFFIC_SERVER_URL
                                                                             method:METHOD_GET_USER_LEARNDRAW_LIST
                                                                         parameters:dict
                                                                           returnPB:YES
                                                                        returnArray:NO];
        
        NSInteger resultCode = output.resultCode;
        NSArray *list = nil;
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            list = [FeedManager parsePbFeedList:response.feedList];
        }
        @catch (NSException *exception) {
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(handler,list,resultCode);
        });
    });
}

- (void)getLearnDrawOpusListWithType:(LearnDrawType)type
                            sortType:(SortType)sortType
                              offset:(NSInteger)offset
                               limit:(NSInteger)limit
                       ResultHandler:(RequestArrayResultHandler)handler
{
    NSString *userId = [self userId];
    if ([userId length] == 0) {
        userId = @"";
    }

    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *dict = @{
                               PARA_USERID : userId,
                               PARA_APPID : [ConfigManager appId],
                               PARA_OFFSET: [@(offset) stringValue],
                               PARA_LIMIT : [@(limit) stringValue],
                               PARA_TYPE : [@(type) stringValue],
                               PARA_SORT_BY : [@(sortType) stringValue]
                               };
        
        CommonNetworkOutput *output = [GameNetworkRequest sendGetRequestWithBaseURL:
                                       TRAFFIC_SERVER_URL
                                                                             method:METHOD_GET_LEARNDRAW_LIST
                                                                         parameters:dict
                                                                           returnPB:YES
                                                                        returnArray:NO];
        
        NSInteger resultCode = output.resultCode;
        NSArray *list = nil;
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            list = [FeedManager parsePbFeedList:response.feedList];
        }
        @catch (NSException *exception) {
            resultCode = ERROR_CLIENT_PARSE_DATA;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            if (resultCode == ERROR_SUCCESS) {
//
//            }
            EXECUTE_BLOCK(handler,list,resultCode);
        });
    });
}

@end
