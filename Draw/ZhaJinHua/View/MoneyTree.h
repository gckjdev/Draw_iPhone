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
- (void)moneyTreeNotMature:(MoneyTree*)tree;
- (void)getMoney:(int)money fromTree:(MoneyTree*)tree;
- (void)coinDidRaiseUp:(MoneyTree*)tree;
- (void)treeDidMature:(MoneyTree*)tree;

- (void)treeFullCoins:(MoneyTree*)tree;

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
@property (assign, nonatomic) NSInteger coinsOnTree;
@property (assign, nonatomic) NSInteger coinValue;

- (void)startGrow;
- (void)kill;
- (CFTimeInterval)remainTimeToFullCoin;

@end
