//
//  ToolCommand.h
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import <Foundation/Foundation.h>
#import "ItemType.h"

@interface ToolCommand : NSObject

@property(nonatomic, assign)UIControl *control;

- (BOOL)canUseItem:(ItemType)type;

- (id)initWithButton:(UIControl *)control;
- (void)showPopTipView;
- (void)hidePopTipView;


//need to be override by the sub classes
- (UIView *)contentView;
- (void)excute;
- (void)finish;

@end
