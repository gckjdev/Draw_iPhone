//
//  Poker.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "Poker.h"

@interface Poker ()

@property (readwrite, nonatomic) int pokerId;
@property (readwrite, nonatomic) PBPokerRank rank;
@property (readwrite, nonatomic) PBPokerSuit suit;
@property (readwrite, nonatomic) BOOL faceUp;

@end

@implementation Poker

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithPBPoker:(PBPoker *)poker
{
    if (self = [super init]) {
        _pokerId = poker.pokerId;
        _rank = poker.rank;
        _suit = poker.suit;
        _faceUp =  poker.faceUp;
    }
    
    return self;
}

- (id)initWithPokerId:(int)pokerId
                 rank:(PBPokerRank)rank
                 suit:(PBPokerSuit)suit
               faceUp:(BOOL)faceUp
{
    if (self = [super init]) {
        _pokerId = pokerId;
        _rank = rank;
        _suit = suit;
        _faceUp = faceUp;
    }
    
    return self;
}

+ (Poker *)pokerFromPBPoker:(PBPoker *)pbPoker
{
    return [[[Poker alloc] initWithPBPoker:pbPoker] autorelease];
}

+ (Poker *)pokerWithPokerId:(int)pokerId
                       rank:(PBPokerRank)rank
                       suit:(PBPokerSuit)suit
                     faceUp:(BOOL)faceUp
{
    return [[[Poker alloc] initWithPokerId:pokerId
                                      rank:rank
                                      suit:suit
                                    faceUp:faceUp] autorelease];
}

- (void)setFaceUp
{
    _faceUp = TRUE;
}

@end
