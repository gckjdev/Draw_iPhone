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

- (void)widthBox:(WidthBox *)widthBox didSelectWidth:(NSInteger)width;

@end

@interface WidthBox : UIView

+ (id)widthBoxWithWidthList:(NSInteger *)list;
+ (id)widthBox; //user default list
- (void)setWidthSelected:(NSInteger)width;

@end
