//
//  MoneyTree.h
//  Draw
//
//  Created by Kira on 12-11-5.
//
//

#import <UIKit/UIKit.h>


@class MoneyTree;
@protocol MoneyTreeDelegate <NSObject>
 @optional
- (void)moneyTreeNotMature:(MoneyTree*)tree;
- (void)getMoney:(int)money fromTree:(MoneyTree*)tree;
- (void)coinDidRaiseUp:(MoneyTree*)tree;
- (void)treeDidMature:(MoneyTree*)tree;

- (void)treeFullCoins:(MoneyTree*)tree;

@end

@interface MoneyTree : UIButton {
    NSTimer* _treeTimer;
    UILabel* _rewardCoinLabel;
    UIView* _rewardView;
    UIImageView* _rewardCoinView;
    NSMutableArray*  _layerQueue;
}
@property (assign, nonatomic) CFTimeInterval growthTime;
@property (assign, nonatomic) CFTimeInterval gainTime;
@property (assign, nonatomic) BOOL isMature;
@property (assign, nonatomic) id<MoneyTreeDelegate> delegate;
@property (assign, nonatomic) NSInteger coinsOnTree;
@property (assign, nonatomic) NSInteger coinValue;

- (void)startGrow;
- (void)kill;

@end
