//
//  BBSOptionView.h
//  Draw
//
//  Created by gamy on 12-12-3.
//
//

#import <UIKit/UIKit.h>

@class BBSOptionView;
@protocol BBSOptionViewDelegate <NSObject>

@optional
- (void)optionView:(BBSOptionView *)optionView didSelectedButtonIndex:(NSInteger)index;

@end


typedef void (^ BBSOptionViewCallback) (NSInteger index);

@interface BBSOptionView : UIView


@property(nonatomic, retain)NSArray *titles;
@property(nonatomic, retain)UIView *contentView;
@property(nonatomic, assign)id<BBSOptionViewDelegate>delegate;
@property(nonatomic, retain)UIButton *mask;
@property(nonatomic, retain)UIImageView *bgImageView;
@property(nonatomic, copy)BBSOptionViewCallback callback;

- (id)initWithTitles:(NSArray *)titles
            delegate:(id<BBSOptionViewDelegate>)delegate;

- (id)initWithTitles:(NSArray *)titles
            callback:(BBSOptionViewCallback)callback;


- (void)setMaskViewColor:(UIColor *)color;
- (void)dismiss:(BOOL)animated;


//methods used for sub class...
//- (void)show:(BOOL)animated;
- (void)showInView:(UIView *)view animated:(BOOL)animated;
@end
