//
//  MoneyTreeView.h
//  Draw
//
//  Created by Kira on 12-11-16.
//
//

#import <UIKit/UIKit.h>
#import "MoneyTree.h"
@class MoneyTreeView;

@protocol MoneyTreeViewDelegate <NSObject>

- (void)didGainMoney:(int)money
            fromTree:(MoneyTreeView*)treeView;
@optional
- (void)moneyTreeDidMature:(MoneyTreeView*)treeView;
- (void)moneyTreeFullCoins:(MoneyTreeView*)treeView;
- (void)moneyTreeUpdateRemainSeconds:(CFTimeInterval)remainSec;
@end

@interface MoneyTreeView : UIView <MoneyTreeDelegate>{
    NSTimer* _timer;
}
@property (retain, nonatomic) IBOutlet MoneyTree *moneyTree;
@property (retain, nonatomic) IBOutlet UILabel *popMessageLabel;
@property (retain, nonatomic) IBOutlet UIImageView *popMessageBackgroundImageView;
@property (retain, nonatomic) IBOutlet UIView *popMessageBody;

@property (assign, nonatomic) CFTimeInterval growthTime;
@property (assign, nonatomic) CFTimeInterval gainTime;
@property (assign, nonatomic) NSInteger      coinValue;
@property (assign, nonatomic) id<MoneyTreeViewDelegate> delegate;
@property (assign, nonatomic) BOOL isAlwaysShowMessage;
@property (readonly, assign, nonatomic) int remainTime;

+ (MoneyTreeView*)createMoneyTreeView;
- (void)showInView:(UIView *)view;

- (void)startGrowing;
- (void)killMoneyTree;

@end
