//
//  ResultSeal.h
//  Draw
//
//  Created by ChaoSo on 14-8-6.
//
//

#import <UIKit/UIKit.h>

@interface ResultSeal : UIView

@property (nonatomic,assign)CGFloat borderWidth;
@property (nonatomic,retain)UIColor *borderColor;
@property (nonatomic,retain)NSString *context;
@property (nonatomic,retain)UIFont *textFont;

- (id)initWithFrame:(CGRect)frame borderColor:(UIColor *)color;
- (id)initWithFrame:(CGRect)frame borderColor:(UIColor *)color font:(UIFont *)font text:(NSString *)text;
@end
