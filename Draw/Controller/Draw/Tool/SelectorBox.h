//
//  SelectorBox.h
//  Draw
//
//  Created by gamy on 13-7-9.
//
//

#import <UIKit/UIKit.h>


@class SelectorBox;

@protocol SelectorBoxDelegate <NSObject>



@end

@interface SelectorBox : UIView

@property(nonatomic, assign)id<SelectorBoxDelegate>delegate;

+ (id)selectorBoxWithDelegate:(id<SelectorBoxDelegate>)delegate;

- (IBAction)clickSelector:(UIButton *)sender;
- (IBAction)clickCancel:(id)sender;
- (IBAction)clickHelp:(id)sender;

@end
