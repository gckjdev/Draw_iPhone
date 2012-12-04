//
//  ZJHPokerView.h
//  Draw
//
//  Created by 王 小涛 on 12-10-26.
//
//

#import <UIKit/UIKit.h>
#import "PokerView.h"
#import "ZJHUserPlayInfo.h"

#define SMALL_POKER_VIEW_WIDTH ([DeviceDetection isIPAD] ? 56 : 28)
#define SMALL_POKER_VIEW_HEIGHT ([DeviceDetection isIPAD] ? 72 : 36)
#define SMALL_POKER_GAP (SMALL_POKER_VIEW_WIDTH * 0.15)

#define BIG_POKER_VIEW_WIDTH ([DeviceDetection isIPAD] ? 70 : 35)
#define BIG_POKER_VIEW_HEIGHT ([DeviceDetection isIPAD] ? 96 : 48)
#define BIG_POKER_GAP (BIG_POKER_VIEW_WIDTH * ([DeviceDetection isIPAD] ? 1.06 : 1.05))

typedef enum {
    ZJHPokerSectorTypeNone = 0,
    ZJHPokerSectorTypeRight = 1,        // 左边的牌固定，右边两张牌向右扇开
    ZJHPokerSectorTypeLeft = 2,         // 右边的牌固定，左边两张牌向左扇开
    ZJHPokerSectorTypeCenter = 3        // 中间的牌固定，两边往外扇开
} ZJHPokerSectorType;

typedef enum {
    ZJHPokerXMotionTypeNone = 0,
    ZJHPokerXMotionTypeRight = 1,       // 左边的牌固定，右边两张牌向右移动
    ZJHPokerXMotionTypeLeft = 2,        // 右边的牌固定，左边两张牌向左移动
    ZJHPokerXMotionTypeCenter = 3       // 中间的牌固定，两边往外移动
} ZJHPokerXMotionType;

@class ZJHPokerView;

@protocol ZJHPokerViewProtocol <NSObject>

@optional
- (void)didClickPokerView:(PokerView *)pokerView;
- (void)didClickShowCardButton:(PokerView *)pokerView;
- (void)didClickChangeCardButton:(PokerView *)pokerView;

- (void)didClickBombButton:(ZJHPokerView *)zjhPokerView;

@end

@interface ZJHPokerView : UIView <PokerViewProtocol>

@property (assign, nonatomic) IBOutlet id<ZJHPokerViewProtocol> delegate;
@property (retain, nonatomic) PokerView *pokerView1;
@property (retain, nonatomic) PokerView *pokerView2;
@property (retain, nonatomic) PokerView *pokerView3;

- (void)updateWithPokers:(NSArray *)pokers
                    size:(CGSize)size
                     gap:(CGFloat)gap;

- (void)dismissButtons;
- (void)clear;

// 别人看牌时，调用这个接口，把牌摊成扇形
- (void)makeSectorShape:(ZJHPokerSectorType)sectorType animation:(BOOL)animation;

// 自己看牌时，调用这个接口，把自己三张牌都翻过来。
- (void)faceUpCardsWithCardType:(NSString *)cardType
                    xMotiontype:(ZJHPokerXMotionType)xMotiontype
                      animation:(BOOL)animation;

// 别人亮牌时，调用这个接口，把自己那张亮的牌翻过来。
- (void)faceUpCard:(int)cardId animation:(BOOL)animation;

// 自己亮牌时，调用这个接口，把自己那张亮的牌设置标志。
- (void)setShowCardFlag:(int)cardId animation:(BOOL)animation;

- (void)changeCard:(int)cardId toCard:(Poker *)poker animation:(BOOL)animation;

// 别人或自己弃牌，调用这个接口，表示弃牌
- (void)foldCards:(BOOL)animation;

// 别人或自己比牌，调用这个接口，表示比牌结果

- (void)winCards:(BOOL)animation;
- (void)loseCards:(BOOL)animation;

- (void)showBomb;
- (void)clearBomb;

@end
