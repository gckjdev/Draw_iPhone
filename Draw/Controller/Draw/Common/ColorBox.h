//
//  ColorBox.h
//  Draw
//
//  Created by gamy on 12-12-28.
//
//

#import <UIKit/UIKit.h>
#import "ColorPoint.h"

@class ColorBox;
@class DrawColor;

@protocol ColorBoxDelegate <NSObject>

@optional
- (void)colorBox:(ColorBox *)colorBox didSelectColor:(DrawColor *)color;
- (void)didClickCloseButtonOnColorBox:(ColorBox *)colorBox;
- (void)didClickMoreButtonOnColorBox:(ColorBox *)colorBox;

@end

@interface ColorBox : UIView<UITableViewDataSource, UITableViewDelegate, ColorPointDelegate>
{
    
}

+ (id)createViewWithdelegate:(id)delegate;

@property(nonatomic, assign)id<ColorBoxDelegate> delegate;

@end
