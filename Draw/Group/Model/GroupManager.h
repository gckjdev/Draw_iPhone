//
//  GroupManager.h
//  Draw
//
//  Created by Gamy on 13-11-9.
//
//

#import <Foundation/Foundation.h>



@interface GroupManager : NSObject
@property(nonatomic, retain)NSMutableArray *followedGroupIds;

+ (id)defaultManager;

+ (NSInteger)capacityForLevel:(NSInteger)level;
+ (NSInteger)monthlyFeeForLevel:(NSInteger)level;


- (BOOL)followedGroup:(NSString *)groupId;

@end

