//
//  PickEraserView.h
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickView.h"

@interface PickEraserView : PickView
{
    NSMutableArray *widthArray;
    NSInteger _currentWidth;
}

//- (void)resetWidth;
- (NSInteger)currentWidth;
//- (void)setLineWidths:(NSArray *)widthArray; // the list should be NSNumber list
- (void)setLineWidthHidden:(BOOL)hidden;
- (void)updateLineViews;
@end
