//
//  DealerView.h
//  Draw
//
//  Created by Kira on 12-11-1.
//
//

#import <UIKit/UIKit.h>

@class DealerView;

@protocol DealerViewDelegate <NSObject>

- (void)didDealFinish:(DealerView*)view;

@end

@interface DealerView : UIView
@property (assign, nonatomic) id<DealerViewDelegate> delegate;

- (void)dealToDestinationPoints:(CGPoint[])points
                          count:(int)pointsCount
                          times:(int)times;


@end
