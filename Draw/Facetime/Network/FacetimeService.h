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

@protocol FacetimeServiceDelegate <NSObject>

@optional
//match user
- (void)didMatchUser:(PBGameUser*)user;
- (void)didMatchFailed;

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

- (void)connectServer:(id<FacetimeServiceDelegate>)connectionDelegate;

- (void)sendFacetimeRequest;

- (void)sendFacetimeRequestForMaleWithGender:(BOOL)gender;

@end
