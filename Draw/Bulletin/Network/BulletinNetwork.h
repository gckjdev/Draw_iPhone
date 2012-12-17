//
//  BulletinNetwork.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import <Foundation/Foundation.h>
@class CommonNetworkOutput;

@interface BulletinNetwork : NSObject

+ (CommonNetworkOutput*)getBulletins:(NSString*)baseURL
                               appId:(NSString*)appId
                              gameId:(NSString*)gameId
                              userId:(NSString*)userId
                          bulletinId:(NSString*)bulletinId;

@end
