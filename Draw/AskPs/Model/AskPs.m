//
//  AskPs.m
//  Draw
//
//  Created by haodong on 13-6-11.
//
//

#import "AskPs.h"


@implementation AskPs

- (void)setRequirements:(NSArray *)requirements
{
    PBAskPsBuilder *builder = [PBAskPs builderWithPrototype:self.pbOpusBuilder.askPs];
    [builder setRequirementArray:requirements];
    [self.pbOpusBuilder setAskPs:[builder build]];
}

- (void)setAwardCoinsPerUser:(int)awardCoinsPerUser
{
    PBAskPsBuilder *builder = [PBAskPs builderWithPrototype:self.pbOpusBuilder.askPs];
    [builder setAwardCoinsPerUser:awardCoinsPerUser];
    [self.pbOpusBuilder setAskPs:[builder build]];
}

- (void)setAwardCoinsMaxTotal:(int)awardCoinsMaxTotal
{
    PBAskPsBuilder *builder = [PBAskPs builderWithPrototype:self.pbOpusBuilder.askPs];
    [builder setAwardCoinsMaxTotal:awardCoinsMaxTotal];
    [self.pbOpusBuilder setAskPs:[builder build]];
}

- (void)setAwardIngotBestUser:(int)awardIngotBestUser
{
    PBAskPsBuilder *builder = [PBAskPs builderWithPrototype:self.pbOpusBuilder.askPs];
    [builder setAwardIngotBestUser:awardIngotBestUser];
    [self.pbOpusBuilder setAskPs:[builder build]];
}

- (void)setAwardBestUserId:(NSString *)awardBestUserId
{
    PBAskPsBuilder *builder = [PBAskPs builderWithPrototype:self.pbOpusBuilder.askPs];
    [builder setAwardBestUserId:awardBestUserId];
    [self.pbOpusBuilder setAskPs:[builder build]];
}

@end
