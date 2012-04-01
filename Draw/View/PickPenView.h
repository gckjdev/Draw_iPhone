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

@protocol PickPenDelegate <NSObject>

@optional
- (void)didPickedColorView:(ColorView *)colorView;
- (void)didPickedLineWidth:(NSInteger)width;
- (void)didPickedMoreColor;
@end

@interface PickPenView : UIImageView
{
    id<PickPenDelegate> _delegate;
    NSArray *colorViewArray;
    NSMutableArray *widthButtonArray;
    NSInteger _currentWidth;
    
}
@property(nonatomic, retain)UIImageView *backgroudView;
@property(nonatomic, retain)id<PickPenDelegate>delegate;


- (void)setLineWidths:(NSArray *)widthArray; // the list should be NSNumber list
- (void)setColorViews:(NSArray *)colorViews;
- (NSInteger)currentWidth;
@end
