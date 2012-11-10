//
//  DealerView.h
//  Draw
//
//  Created by Kira on 12-11-1.
//
//

#import <UIKit/UIKit.h>

@class DealerView;

@interface DealPoint : NSObject {
    
}

@property (assign, nonatomic) float x;
@property (assign, nonatomic) float y;

+ (DealPoint*)pointWithCGPoint:(CGPoint)point;

@end

@protocol DealerViewDelegate <NSObject>

- (void)didDealFinish:(DealerView*)view;

@end

@interface DealerView : UIView {
    int _remainCards;
}
@property (assign, nonatomic) id<DealerViewDelegate> delegate;
@property (readonly, assign, nonatomic) BOOL isDealing;

- (void)dealWithPositionArray:(NSArray*)array
                        times:(int)times;


@end
