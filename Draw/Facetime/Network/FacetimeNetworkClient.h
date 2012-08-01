//
//  FacetimeNetworkClient.h
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkClient.h"
@class PBGameUser;

@interface FacetimeNetworkClient : CommonNetworkClient <CommonNetworkClientDelegate>

+ (FacetimeNetworkClient*)defaultInstance;
- (void)start:(NSString*)serverAddress port:(int)port;
- (void)askFaceTime:(PBGameUser*)user;
- (void)askFaceTime:(PBGameUser*)user 
             gender:(BOOL)gender;

@end
