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
@property (readwrite, nonatomic) int rank;
@property (readwrite, nonatomic) int suit;
@property (readwrite, nonatomic) BOOL faceUp;

@end

@implementation Poker

@synthesize pokerId = _pokerId;
@synthesize rank = _rank;
@synthesize suit = _suit;
@synthesize faceUp = _faceUp;

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

+ (Poker *)pokerFromPBPoker:(PBPoker *)pbPoker
{
    return [[[Poker alloc] initWithPBPoker:pbPoker] autorelease];
}

- (void)setFaceUp
{
    _faceUp = TRUE;
}

@end
