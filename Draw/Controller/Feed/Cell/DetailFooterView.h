//
//  DetailFooterView.h
//  Draw
//
//  Created by gamy on 13-8-24.
//
//

#import <UIKit/UIKit.h>

typedef enum{
    FooterTypeNo = 0,
    FooterTypeGuess = 1,
    FooterTypeReplay,
    FooterTypeComment,
    FooterTypeShare,
    FooterTypeFlower,
    FooterTypeTomato,
    FooterTypeReport,
    FooterTypeJudge
    
}FooterType;

@class DetailFooterView;

@protocol DetailFooterViewDelegate <NSObject>

- (void)detailFooterView:(DetailFooterView *)footer
        didClickAtButton:(UIButton *)button
                    type:(FooterType)type;

@end

@interface DetailFooterView : UIView

@property(nonatomic, assign)id<DetailFooterViewDelegate>delegate;

- (void)setButtonsWithTypes:(NSArray *)types;
- (void)setButton:(FooterType)type enabled:(BOOL)enabled;
- (UIButton *)buttonWithType:(FooterType)type;
+ (DetailFooterView *)footerViewWithDelegate:(id<DetailFooterViewDelegate>)delegate;

@end
