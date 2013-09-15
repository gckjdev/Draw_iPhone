//
//  LineView.h
//  Draw
//
//  Created by Gamy on 13-9-12.
//
//

#import <UIKit/UIKit.h>

@interface LineView : UIView
@property(nonatomic, retain)UIColor *pointColor;


- (void)startAnimation;
- (void)stopAnimation;

@end
