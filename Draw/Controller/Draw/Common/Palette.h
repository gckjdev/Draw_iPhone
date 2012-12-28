//
//  ColorPickingBox.h
//  Draw
//
//  Created by gamy on 12-12-27.
//
//

#import <UIKit/UIKit.h>


#import "ILSaturationBrightnessPickerView.h"
#import "ILHuePickerView.h"

@class Palette;
@class DrawColor;

@protocol ColorPickingBoxDelegate <NSObject>

@optional
- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color;

@end


@interface Palette : UIView<ILSaturationBrightnessPickerViewDelegate>
{
    
}

@property(nonatomic, retain)DrawColor *currentColor;
@property(nonatomic, assign)id<ColorPickingBoxDelegate> delegate;

+ (id)createViewWithdelegate:(id)delegate;
@end
