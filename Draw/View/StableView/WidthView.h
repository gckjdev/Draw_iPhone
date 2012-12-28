//
//  WidthView.h
//  DrawViewTest
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WidthView : UIControl
{
    
}
- (id)initWithWidth:(CGFloat)width;
+ (id)viewWithWidth:(CGFloat)width;
+ (CGFloat)height;
+ (CGFloat)width;
+ (NSMutableArray *)widthArray;
+ (NSInteger)defaultWidth;
@property(nonatomic, assign) CGFloat width;
@end
