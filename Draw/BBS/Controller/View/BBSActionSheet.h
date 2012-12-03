//
//  BBSActionSheet.h
//  Draw
//
//  Created by gamy on 12-12-3.
//
//

#import <UIKit/UIKit.h>


@class BBSActionSheet;

@protocol BBSActionSheetDelegate <NSObject>

@optional
- (void)actionSheet:(BBSActionSheet *)actionSheet didSelectedButtonIndex:(NSInteger)index;

@end


@interface BBSActionSheet : UIView

- (id)initWithTitles:(NSArray *)titles
            delegate:(id<BBSActionSheetDelegate>)delegate;
- (void)showInView:(UIView *)view showAtPoint:(CGPoint )point animated:(BOOL)animated;

@end
