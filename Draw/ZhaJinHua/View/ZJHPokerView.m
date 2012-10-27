//
//  ZJHPokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-26.
//
//

#import "ZJHPokerView.h"

@interface ZJHPokerView ()

@property (retain, nonatomic) ZJHUserInfo *userInfo;
@property (retain, nonatomic) NSMutableDictionary *pokerViewDic;
@property (assign, nonatomic) ZJHPokerSectorType sectorType;

@end

@implementation ZJHPokerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.pokerViewDic = [NSMutableDictionary dictionary];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_pokerViewDic release];
    [_userInfo release];

    [_poker1View release];
    [_poker2View release];
    [_poker3View release];
    [super dealloc];
}

- (void)updateZJHUserInfo:(ZJHUserInfo *)userInfo
{
    NSArray *pokers = userInfo.pokers;
    if ([pokers count] < 3) {
        return;
    }
    
    self.userInfo = userInfo;
    
    Poker *poker1 = [pokers objectAtIndex:0];
    Poker *poker2 = [pokers objectAtIndex:1];
    Poker *poker3 = [pokers objectAtIndex:2];
    
    [self.poker1View updatePoker:poker1];
    [self.poker2View updatePoker:poker2];
    [self.poker3View updatePoker:poker3];
    
    [self.pokerViewDic removeAllObjects];
    
    [self.pokerViewDic setObject:_poker1View forKey:[NSNumber numberWithInt:poker1.pokerId]];
    [self.pokerViewDic setObject:_poker2View forKey:[NSNumber numberWithInt:poker2.pokerId]];
    [self.pokerViewDic setObject:_poker3View forKey:[NSNumber numberWithInt:poker3.pokerId]];
}

- (void)show
{
}

- (void)makeSectorShape:(ZJHPokerSectorType)sectorType
{
    if (_sectorType == sectorType) {
        return;
    }
    
    switch (sectorType) {
        case ZJHPokerSectorTypeNone:
            
            break;
            
        case ZJHPokerSectorTypeRight:
            
            break;
            
        case ZJHPokerSectorTypeLeft:
            
            break;
            
        case ZJHPokerSectorTypeCenter:
            
            break;
            
        default:
            break;
    }
    
    self.sectorType = sectorType;

}


- (void)faceupCards:(BOOL)animation
{
    [self.poker1View faceUp:animation];
    [self.poker2View faceUp:animation];
    [self.poker3View faceUp:animation];
}

- (void)faceupCard:(int)cardId animation:(BOOL)animation
{
    [[_pokerViewDic objectForKey:[NSNumber numberWithInt:cardId]] faceUp:animation];
}

- (void)fold:(BOOL)animation
{
    NSEnumerator *enumerator = [self.pokerViewDic objectEnumerator];
    PokerView *pokerView;
    
    while ((pokerView = (PokerView *)[enumerator nextObject])) {
        /* code that acts on the dictionary’s values */
        if (pokerView.poker.faceUp) {
            [pokerView faceDown:animation];
            [pokerView backToOriginPosition:animation];
        }
    }
}

- (void)lose:(BOOL)animation
{
    NSEnumerator *enumerator = [self.pokerViewDic objectEnumerator];
    PokerView *pokerView;
    
    while ((pokerView = (PokerView *)[enumerator nextObject])) {
        /* code that acts on the dictionary’s values */
        if (pokerView.poker.faceUp) {
            [pokerView faceDown:animation];
            [pokerView backToOriginPosition:animation];
        }
    }
}

- (void)compare:(BOOL)animation
            win:(BOOL)win
{
    // TODO: 
}

#pragma mark - pravite methods

//- (void)makeSectorShape


@end
