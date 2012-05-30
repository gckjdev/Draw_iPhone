//
//  PickPenView.h
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawColor;
@class ColorView;

@protocol PickColorDelegate <NSObject>

@optional
- (void)didPickedColorView:(ColorView *)colorView;
- (void)didPickedLineWidth:(NSInteger)width;
- (void)didPickedMoreColor;
@end

@interface PickColorView : UIImageView
{
    id<PickColorDelegate> _delegate;
    NSMutableArray *colorViewArray;
    NSMutableArray *widthButtonArray;
    NSInteger _currentWidth;
    
}
@property(nonatomic, retain)UIImageView *backgroudView;
@property(nonatomic, assign)id<PickColorDelegate>delegate;

- (void)resetWidth;
- (void)setLineWidths:(NSArray *)widthArray; // the list should be NSNumber list
- (void)setColorViews:(NSArray *)colorViews;
- (NSArray *)colorViews;
- (NSInteger)currentWidth;
//- (void)showInView:(UIView *)view;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
- (NSInteger)indexOfColorView:(ColorView *)colorView;
- (void)updatePickPenView:(ColorView *)lastUsedColorView;
@end
