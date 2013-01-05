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

@property (assign, nonatomic) id<WordSelectCellDelegate> delegate;

+ (WordSelectCell *)createViewWithFrame:(CGRect)frame;
- (void)setWords:(NSArray *)words;

@end
