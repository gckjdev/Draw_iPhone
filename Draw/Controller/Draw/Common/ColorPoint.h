//
//  ColorPoint.h
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import <UIKit/UIKit.h>
#import "DrawColor.h"

@interface ColorPoint : UIControl
{
    
}

@property(nonatomic, retain)DrawColor *color;

- (id)initWithColor:(DrawColor *)color;
+ (id)pointWithColor:(DrawColor *)color;



@end
