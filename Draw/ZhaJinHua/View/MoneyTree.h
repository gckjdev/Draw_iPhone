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

- (void)moneyTreeNotMature:(MoneyTree*)tree;
- (void)getMoney:(int)money fromTree:(MoneyTree*)tree;

@end

@interface MoneyTree : UIButton {
    NSTimer* _treeTimer;
}
@property (assign, nonatomic) CFTimeInterval growthTime;
@property (assign, nonatomic) BOOL isMature;

- (void)startGrowth;
- (void)kill;

@end
