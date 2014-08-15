//
//  TipsPageViewController.h
//  Draw
//
//  Created by ChaoSo on 14-7-25.
//
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"
#import "PPViewController.h"

@interface TipsPageViewController : PPViewController<SGFocusImageFrameDelegate>

+ (void)show:(PPViewController*)superController
       title:(NSString*)title
imagePathArray:(NSArray*)imagePathArray     // 图片路径数组
defaultIndex:(int)defaultIndex              // 默认开始页
 returnIndex:(int*)returnIndex;             // 返回当前选中

@end
