//
//  PPGameNetworkRequest.h
//  Draw
//
//  Created by qqn_pipi on 13-6-9.
//
//

#import <Foundation/Foundation.h>
#import "GameConstants.pb.h"
#import "GameBasic.pb.h"
#import "GameMessage.pb.h"
#import "PPNetworkRequest.h"
#import "PPGameNetworkRequest.h"
#import "GameNetworkConstants.h"

typedef void (^ PBResponseResultBlock) (DataQueryResponse *response, NSError* error);

@interface GameNetworkOutput : CommonNetworkOutput

@property (nonatomic, retain) DataQueryResponse* pbResponse;

@end

@interface PPGameNetworkRequest : NSObject

+ (GameNetworkOutput*)apiServerGetAndResponseJSON:(NSString *)method
                                       parameters:(NSDictionary *)parameters
                                    isReturnArray:(BOOL)isReturnArray;

+ (GameNetworkOutput*)apiServerGetAndResponsePB:(NSString *)method
                                     parameters:(NSDictionary *)parameters;

+ (GameNetworkOutput*)apiServerPostAndResponseJSON:(NSString *)method
                                        parameters:(NSDictionary *)parameters
                                          postData:(NSData*)postData
                                     isReturnArray:(BOOL)isReturnArray;

+ (GameNetworkOutput*)apiServerPostAndResponsePB:(NSString *)method
                                      parameters:(NSDictionary *)parameters
                                        postData:(NSData*)postData;

// TRAFFIC API SERVER, GET REQUEST
+ (GameNetworkOutput*)trafficApiServerGetAndResponseJSON:(NSString *)method
                                              parameters:(NSDictionary *)parameters
                                           isReturnArray:(BOOL)isReturnArray;


+ (GameNetworkOutput*)trafficApiServerGetAndResponsePB:(NSString *)method
                                            parameters:(NSDictionary *)parameters;


// TRAFFIC API SERVER, POST REQUEST
+ (GameNetworkOutput*)trafficApiServerPostAndResponseJSON:(NSString *)method
                                               parameters:(NSDictionary *)parameters
                                                 postData:(NSData*)postData
                                            isReturnArray:(BOOL)isReturnArray;

+ (GameNetworkOutput*)trafficApiServerPostAndResponsePB:(NSString *)method
                                             parameters:(NSDictionary *)parameters
                                               postData:(NSData*)postData;

// TRAFFIC API SERVER, POST+UPLOAD REQUEST
+ (GameNetworkOutput*)trafficApiServerUploadAndResponsePB:(NSString *)method
                                               parameters:(NSDictionary *)parameters
                                            imageDataDict:(NSDictionary *)imageDict
                                             postDataDict:(NSDictionary *)dataDict
                                         progressDelegate:(id)progressDelegate;

+ (GameNetworkOutput*)sendGetRequestWithBaseURL:(NSString*)baseURL
                                         method:(NSString *)method
                                     parameters:(NSDictionary *)parameters
                                       returnPB:(BOOL)returnPB
                                returnJSONArray:(BOOL)returnJSONArray;

+ (void)loadPBData:(dispatch_queue_t)queue
           hostURL:(NSString*)hostURL
            method:(NSString *)method
        parameters:(NSDictionary *)parameters
          callback:(PBResponseResultBlock)callback
       isPostError:(BOOL)isPostError;

+ (void)loadPBData:(dispatch_queue_t)queue
           hostURL:(NSString*)hostURL
            method:(NSString *)method
          postData:(NSData *)postData
        parameters:(NSDictionary *)parameters
          callback:(PBResponseResultBlock)callback
       isPostError:(BOOL)isPostError;


@end
