//
//  SelectorBox.h
//  Draw
//
//  Created by gamy on 13-7-9.
//
//

#import <UIKit/UIKit.h>
#import "ClipAction.h"


@class SelectorBox;


@protocol SelectorBoxDelegate <NSObject>
- (void)selectorBox:(SelectorBox *)box didSelectClipType:(ClipType)clipType;
- (void)didClickCancelAtSelectorBox:(SelectorBox *)box;
- (void)didClickHelpAtSelectorBox:(SelectorBox *)box;

@end

@interface SelectorBox : UIView

@property(nonatomic, assign)id<SelectorBoxDelegate>delegate;

+ (id)selectorBoxWithDelegate:(id<SelectorBoxDelegate>)delegate;

- (IBAction)clickSelector:(UIButton *)sender;
- (IBAction)clickCancel:(id)sender;
- (IBAction)clickHelp:(id)sender;

@end