//
//  BBSPopupSelectionView.h
//  Draw
//
//  Created by gamy on 12-11-30.
//
//

#import <UIKit/UIKit.h>

@class BBSPopupSelectionView;
@protocol BBSPopupSelectionViewDelegate <NSObject>

@optional
- (void)selectionView:(BBSPopupSelectionView *)selectionView didSelectedButtonIndex:(NSInteger)index;

@end

@interface BBSPopupSelectionView : UIView

- (id)initWithTitles:(NSArray *)titles
            delegate:(id<BBSPopupSelectionViewDelegate>)delegate;
- (void)showInView:(UIView *)view showAbovePoint:(CGPoint )point animated:(BOOL)animated;
@end
