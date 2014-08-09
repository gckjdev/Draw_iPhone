//
//  BrickView.h
//  Draw
//
//  Created by ChaoSo on 14-8-7.
//
//

#import <UIKit/UIKit.h>

@interface BrickView : UIView

@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) UIImage* image;
@property (nonatomic,retain) NSString* imageTitle;

//style
@property (nonatomic,retain) UIFont *titleFont;
@property (nonatomic,retain) UIFont *imageTitleFont;
@property (nonatomic,retain) UIColor *titleColor;
@property (nonatomic,retain) UIColor *imageTitleColor;

- (void)setBottomLabelText:(NSString*)text;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title imageTitle:(NSString *)imageTitle image:(UIImage*)image;
@end
