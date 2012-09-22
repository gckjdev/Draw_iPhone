//
//  UserManager+DiceUserManager.m
//  Draw
//
//  Created by Orange on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserManager+DiceUserManager.h"
#import "GameBasic.pb.h"
#import "CustomDiceManager.h"



@implementation UserManager (DiceUserManager)
- (PBGameUser*)toDicePBGameUser
{
    PBKeyValue_Builder* customDiceInfobuiler = [[[PBKeyValue_Builder alloc] init] autorelease];
    [customDiceInfobuiler setName:CUSTOM_DICE];
    [customDiceInfobuiler setValue:[NSString stringWithFormat:@"%d",[[CustomDiceManager defaultManager] getMyDiceType]]];
    return [self toPBGameUserWithKeyValues:[NSArray arrayWithObject:[customDiceInfobuiler build]]];
}
@end
