//
//  GroupManager.h
//  Draw
//
//  Created by Gamy on 13-11-9.
//
//

#import <Foundation/Foundation.h>

@interface GroupManager : NSObject
+ (NSInteger)capacityForLevel:(NSInteger)level;
+ (NSInteger)monthlyFeeForLevel:(NSInteger)level;
//+ (NSInteger)creationFeeForLevel:(NSInteger)level;
@end
