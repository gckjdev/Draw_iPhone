//
//  GameAppProtocol.h
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameAppProtocol <NSObject>

- (NSString*)appId;
- (NSString*)gameId;
- (NSString*)umengId;
- (BOOL)disableAd;

// image resources
- (NSString*)background;

- (NSString*)lmwallId;
- (NSString*)lmAdPublisherId;
- (NSString*)aderAdPublisherId;
- (NSString*)mangoAdPublisherId;

@end
