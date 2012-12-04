//
//  ReplacedPoker.m
//  Draw
//
//  Created by 王 小涛 on 12-12-4.
//
//

#import "ReplacedPoker.h"

@implementation ReplacedPoker

//@synthesize oldPoker = _oldPoker;
//@synthesize newPoker = _newPoker;

- (void)dealloc
{
    [super dealloc];
    [_oldPoker release];
    [_newPoker release];
}

- (id)initWithOldPoker:(Poker *)oldPoker
              newPoker:(Poker *)newPoker
{
    if (self = [super init]) {
        self.oldPoker = oldPoker;
        self.newPoker = newPoker;
    }
    
    return self;
}

+ (ReplacedPoker *)replacedPokerWithOldPoker:(Poker *)oldPoker
                                    newPoker:(Poker *)newPoker
{
    return [[[ReplacedPoker alloc] initWithOldPoker:oldPoker newPoker:newPoker] autorelease];
}

@end
