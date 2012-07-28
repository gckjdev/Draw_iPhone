//
//  FacetimeService.h
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkClient.h"
#import "CommonService.h"
@class FacetimeNetworkClient;
@class PBGameUser;

typedef enum {
    MessageCommandError = 0,
    NoUserResponse = 1
}MatchUserFailedType;

@protocol FacetimeServiceDelegate <NSObject>

@optional
//match user
- (void)didMatchUser:(NSArray*)userList 
      isChosenToInit:(BOOL)isChosenToInit;
- (void)didMatchUserFailed:(MatchUserFailedType)type;

// server connection
- (void)didConnected;
- (void)didBroken;

@end

@interface FacetimeService : CommonService<CommonNetworkClientDelegate> {
    FacetimeNetworkClient* _networkClient;
}

+ (FacetimeService*)defaultService;
@property (nonatomic, assign) id<FacetimeServiceDelegate> connectionDelegate;
@property (nonatomic, assign) id<FacetimeServiceDelegate> matchDelegate;
@property (nonatomic, retain) NSString* serverAddress;
@property (nonatomic, assign) int serverPort;

- (BOOL)isConnected;
- (void)connectServer:(id<FacetimeServiceDelegate>)connectionDelegate;
- (void)disconnectServer;

- (void)sendFacetimeRequest:(id<FacetimeServiceDelegate>)aDelegate;
- (void)sendFacetimeRequestWithGender:(BOOL)gender 
                             delegate:(id<FacetimeServiceDelegate>)aDelegate;

@end
