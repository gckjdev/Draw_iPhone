//
//  WidthBox.h
//  Draw
//
//  Created by gamy on 13-2-1.
//
//

#import <UIKit/UIKit.h>

@class WidthBox;

@protocol WidthBoxDelegate <NSObject>

- (void)widthBox:(WidthBox *)widthBox didSelectWidth:(CGFloat)width;

@end

@interface WidthBox : UIView

@property(nonatomic, assign)id<WidthBoxDelegate>delegate;

+ (id)widthBoxWithWidthList:(NSInteger *)list;
+ (id)widthBox; //user default list
- (void)setWidthSelected:(CGFloat)width;

@end
