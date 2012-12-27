//
//  TestViewController.h
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import <UIKit/UIKit.h>
#import "DrawSlider.h"
#import "CMPopTipView.h"

@interface DrawTestViewController : UIViewController<DrawSliderDelegate>
{
    DrawSlider *slider1;
    DrawSlider *slider2;
    
    CMPopTipView *pop1;
    CMPopTipView *pop2;
}
+ (DrawTestViewController *)enterWithController:(UIViewController *)controller;
@property (retain, nonatomic) IBOutlet UISlider *slider;

@end
