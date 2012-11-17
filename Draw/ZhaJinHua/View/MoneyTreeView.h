//
//  MoneyTreeView.h
//  Draw
//
//  Created by Kira on 12-11-16.
//
//

#import <UIKit/UIKit.h>
#import "MoneyTree.h"


@interface MoneyTreeView : UIView <MoneyTreeDelegate>{
    NSTimer* _timer;
    int _remainTime;
}
@property (retain, nonatomic) IBOutlet MoneyTree *moneyTree;
@property (retain, nonatomic) IBOutlet UILabel *popMessageLabel;
@property (retain, nonatomic) IBOutlet UIImageView *popMessageBackgroundImageView;
@property (retain, nonatomic) IBOutlet UIView *popMessageBody;

@property (assign, nonatomic) CFTimeInterval growthTime;

+ (MoneyTreeView*)createMoneyTreeView;
- (void)showInView:(UIView *)view;

- (void)startGrowing;

@end
