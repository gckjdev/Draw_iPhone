//
//  ToolCommand.h
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import <Foundation/Foundation.h>
#import "ItemType.h"
#import "ToolHandler.h"

@class PPViewController;

@interface ToolCommand : NSObject

@property(nonatomic, assign)UIControl *control;
@property(nonatomic, assign)ToolHandler *toolHandler;
@property(nonatomic, assign)PPViewController *controller;
@property(nonatomic, assign)ItemType itemType;

- (BOOL)canUseItem:(ItemType)type;
- (UIView *)thePPTopView;


- (id)initWithButton:(UIControl *)control itemType:(ItemType)itemType;
- (void)showPopTipView;
- (void)hidePopTipView;


//need to be override by the sub classes
- (UIView *)contentView;
- (BOOL)excute;
- (void)finish;


@end
