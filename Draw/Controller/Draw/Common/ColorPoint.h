//
//  ColorPoint.h
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import <UIKit/UIKit.h>
#import "DrawColor.h"


@class ColorPoint;

@protocol ColorPointDelegate <NSObject>

@optional
- (void)didSelectColorPoint:(ColorPoint *)colorPoint;

@end

@interface ColorPoint : UIControl
{
    
}

@property(nonatomic, retain)DrawColor *color;
@property(nonatomic, assign)id<ColorPointDelegate>delegate;

- (id)initWithColor:(DrawColor *)color;
+ (id)pointWithColor:(DrawColor *)color;



@end
