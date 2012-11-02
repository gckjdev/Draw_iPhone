//
//  PopupViewManager.h
//  Draw
//
//  Created by 王 小涛 on 12-11-2.
//
//

#import <Foundation/Foundation.h>
#import "ChipsSelectView.h"

@interface PopupViewManager : NSObject

+ (PopupViewManager *)defaultManager;

- (void)popupChipsSelectViewAtView:(UIView *)atView
                            inView:(UIView *)inView
                         aboveView:(UIView *)aboveView
                          delegate:(id<ChipsSelectViewProtocol>)delegate;

- (void)dismissChipsSelectView;

@end
