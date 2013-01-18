//
//  MoneyTree.h
//  Draw
//
//  Created by Kira on 12-11-5.
//
//

#import <UIKit/UIKit.h>
#define MAX_COINS_ON_TREE  2

@class MoneyTree;
@protocol MoneyTreeDelegate <NSObject>

@optional

// 点击树时，如果树还没有金币的时候回调
- (void)moneyTreeNoCoin:(MoneyTree*)tree;

// 点击树时，如果树上有金币的时候回调
- (void)getMoney:(int)money fromTree:(MoneyTree*)tree;

- (void)coinDidRaiseUp:(MoneyTree*)tree;

// 树长大的回调
- (void)treeDidMature:(MoneyTree*)tree;

// 长满金币时回调
- (void)treeFullCoins:(MoneyTree*)tree;

// 倒计时回调
- (void)treeUpdateRemainSeconds:(int)seconds
                     toFullCoin:(MoneyTree*)tree;

@end

@interface MoneyTree : UIButton {
    NSTimer* _treeTimer;
    NSTimer* _treeUpdateTimer;
    UILabel* _rewardCoinLabel;
    UIView* _rewardView;
    UIImageView* _rewardCoinView;
    NSMutableArray*  _layerQueue;
    CFTimeInterval _remainTime;
}
@property (assign, nonatomic) CFTimeInterval growthTime;
@property (assign, nonatomic) CFTimeInterval gainTime;
@property (assign, nonatomic) BOOL isMature;
@property (assign, nonatomic) id<MoneyTreeDelegate> delegate;
@property (assign, nonatomic, readonly) NSInteger coinsOnTree;
@property (assign, nonatomic) NSInteger coinValue;

- (void)startGrow;
- (void)kill;
- (CFTimeInterval)remainTimeToFullCoin;
- (CFTimeInterval)totalTime;

@end
