//
//  DrawToolPanel.h
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import <UIKit/UIKit.h>
#import "ColorPoint.h"
#import "DrawSlider.h"

@protocol DrawToolPanelDelegate <NSObject>

@optional

@end

@interface DrawToolPanel : UIView<ColorPointDelegate, DrawSliderDelegate>
{
    
}
@property(nonatomic, assign)id<DrawToolPanelDelegate>delegate;
+ (id)createViewWithdelegate:(id)delegate;
@end
