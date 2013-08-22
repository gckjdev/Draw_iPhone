//
//  WordSelectCell.h
//  Draw
//
//  Created by 王 小涛 on 13-1-3.
//
//

#import <UIKit/UIKit.h>
#import "Word.h"

@protocol WordSelectCellDelegate <NSObject>

@required
- (void)didSelectWord:(Word *)word;

@end

@interface WordSelectCell : UIView

@property (retain, nonatomic) UIColor *textColor;
@property (assign, nonatomic) int style; // 0表示内红外黄，1表示内黄外红
@property (assign, nonatomic) id<WordSelectCellDelegate> delegate;

+ (WordSelectCell *)createViewWithFrame:(CGRect)frame;
- (void)setWords:(NSArray *)words;

@end
