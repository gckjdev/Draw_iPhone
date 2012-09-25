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
- (NSString*)defaultBroadImage;
- (NSString*)defaultAdBoardImage;
- (NSString*)lmwallId;
- (NSString*)lmAdPublisherId;
- (NSString*)aderAdPublisherId;
- (NSString*)mangoAdPublisherId;
- (NSString*)wanpuAdPublisherId;

- (NSString*)sinaAppKey;
- (NSString*)sinaAppSecret;

- (NSString*)qqAppKey;
- (NSString*)qqAppSecret;

- (NSString*)facebookAppKey;
- (NSString*)facebookAppSecret;

- (NSString*)removeAdProductId;

- (NSString*)askFollowTitle;
- (NSString*)askFollowMessage;
- (NSString*)sinaWeiboId;
- (NSString*)qqWeiboId;

@end
