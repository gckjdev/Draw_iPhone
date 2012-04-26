//
//  WidthView.h
//  DrawViewTest
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WidthView : UIButton
{
    
}
- (id)initWithWidth:(CGFloat)width;
+ (id)viewWithWidth:(CGFloat)width;
+ (CGFloat)height;

@property(nonatomic, assign) CGFloat width;
@end
