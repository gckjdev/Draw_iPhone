//
//  PickPenView.h
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PickView.h"
#import "PickEraserView.h"
@class DrawColor;
@class ColorView;


@interface PickColorView : PickEraserView
{
    NSMutableArray *colorViewArray;
//    NSMutableArray *widthButtonArray;
//    NSInteger _currentWidth;
    
}

//- (void)resetWidth;
//- (NSInteger)currentWidth;
//- (void)setLineWidths:(NSArray *)widthArray; // the list should be NSNumber list
- (void)setColorViews:(NSArray *)colorViews;
- (NSArray *)colorViews;
- (NSInteger)indexOfColorView:(ColorView *)colorView;
- (void)updatePickColorView:(ColorView *)lastUsedColorView;
@end
