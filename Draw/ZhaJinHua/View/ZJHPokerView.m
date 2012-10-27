//
//  ZJHPokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-26.
//
//

#import "ZJHPokerView.h"

#define POKER_X_AXIS_OFFSET 20

@interface ZJHPokerView ()

@property (retain, nonatomic) ZJHUserInfo *userInfo;
@property (retain, nonatomic) NSMutableDictionary *pokerViewDic;

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

- (void)makeSectorShape:(ZJHPokerSectorType)sectorType animation:(BOOL)animation
{
    switch (sectorType) {
        case ZJHPokerSectorTypeRight:
            [self.poker2View rotateToAngle:(M_PI * (1.0/6.0)) animation:animation];
            [self.poker3View rotateToAngle:(M_PI * (1.0/3.0)) animation:animation];
            break;
            
        case ZJHPokerSectorTypeLeft:
            [self.poker1View rotateToAngle:(-M_PI * (1.0/3.0)) animation:animation];
            [self.poker2View rotateToAngle:(-M_PI * (1.0/6.0)) animation:animation];
            break;
            
        case ZJHPokerSectorTypeCenter:
            [self.poker1View rotateToAngle:(-M_PI * (1.0/6.0)) animation:animation];
            [self.poker3View rotateToAngle:(M_PI * (1.0/6.0)) animation:animation];
            break;
            
        default:
            break;
    }
}

- (void)faceupCards:(BOOL)animation
{
    [self.poker1View moveToCenter:CGPointMake(_poker1View.center.x - POKER_X_AXIS_OFFSET, _poker1View.center.y) animation:animation];
    [self.poker1View faceUp:animation];
    
    [self.poker2View faceUp:animation];
    
    [self.poker3View moveToCenter:CGPointMake(_poker3View.center.x + POKER_X_AXIS_OFFSET, _poker3View.center.y) animation:animation];
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
    
}

- (void)win:(BOOL)animation
{
    
}

- (void)compare:(BOOL)animation
            win:(BOOL)win
{
    // TODO:
    if (win) {
        [self win:animation];
    }else {
        [self lose:animation];
    }
}

#pragma mark - pravite methods


@end
