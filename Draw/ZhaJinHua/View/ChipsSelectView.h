//
//  ChipsSelectView.h
//  Draw
//
//  Created by 王 小涛 on 12-11-1.
//
//

#import <UIKit/UIKit.h>
#import "ChipView.h"

@protocol ChipsSelectViewProtocol <NSObject>

@optional
- (void)didSelectChip:(int)chipValue;

@end


@interface ChipsSelectView : UIView <ChipViewProtocol>

+ (void)popupAtView:(UIView *)atView
             inView:(UIView *)inView
          aboveView:(UIView *)aboveView
           delegate:(id<ChipsSelectViewProtocol>)delegate;

@end
