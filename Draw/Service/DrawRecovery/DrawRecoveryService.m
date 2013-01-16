//
//  DrawRecoveryService.m
//  Draw
//
//  Created by qqn_pipi on 13-1-16.
//
//

#import "DrawRecoveryService.h"
#import "SynthesizeSingleton.h"



@implementation DrawRecoveryService

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawRecoveryService)

- (void)test
{
    [DrawRecoveryService defaultService];
}

- (int)recoveryDrawCount
{
    
}

- (void)start:(NSString *)targetUid
    contestId:(NSString *)contestId
       userId:(NSString *)userId
     nickName:(NSString *)nickName
         word:(Word *)word
     language:(NSInteger)language
{
    
}

- (void)backup:(NSData*)drawData;
- (void)stop;

@end
