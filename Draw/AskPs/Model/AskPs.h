//
//  AskPs.h
//  Draw
//
//  Created by haodong on 13-6-11.
//
//

#import <Foundation/Foundation.h>
#import "Opus.h"

@interface AskPs:Opus

- (void)setRequirements:(NSArray *)requirements;
- (void)setAwardCoinsPerUser:(int)awardCoinsPerUser;
- (void)setAwardCoinsMaxTotal:(int)awardCoinsMaxTotal;
- (void)setAwardIngotBestUser:(int)awardIngotBestUser;
- (void)setAwardBestUserId:(NSString *)awardBestUserId;

@end
