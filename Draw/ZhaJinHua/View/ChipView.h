//
//  ChipView.h
//  Draw
//
//  Created by 王 小涛 on 12-11-1.
//
//

#import <UIKit/UIKit.h>

#define CHIP_VIEW_WIDTH 32
#define CHIP_VIEW_HEIGHT 32

@class ChipView;

@protocol ChipViewProtocol <NSObject>

@optional
- (void)didClickChipView:(ChipView *)chipView;

@end

@interface ChipView : UIButton

@property (readonly, nonatomic, assign) id<ChipViewProtocol> delegate;
@property (readonly, nonatomic, assign) int chipValue;

+ (ChipView *)chipViewWithFrame:(CGRect)frame
                      chipValue:(int)chipValue
                       delegate:(id<ChipViewProtocol>)delegate;

@end
