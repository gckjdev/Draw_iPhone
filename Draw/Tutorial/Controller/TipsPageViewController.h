//
//  TipsPageViewController.h
//  Draw
//
//  Created by ChaoSo on 14-7-25.
//
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"

@interface TipsPageViewController : UIViewController<SGFocusImageFrameDelegate>

+ (void)show:(PPViewController*)superController title:(NSString*)title imagePathArray:(NSArray*)imagePathArray;

@end
