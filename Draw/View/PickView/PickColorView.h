//
//  PickPenView.h
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickEraserView.h"
@class DrawColor;
@class ColorView;

typedef enum{
    PickColorViewTypePen = 1,
    PickColorViewTypeBackground = 2
}PickColorViewType;


@interface PickColorView : PickEraserView
{
}

- (id)initWithFrame:(CGRect)frame type:(PickColorViewType)type;
- (void)setColorViews:(NSMutableArray *)colorViews;
- (NSMutableArray *)colorViews;
- (PickColorViewType)type;
- (NSInteger)indexOfColorView:(ColorView *)colorView;
- (void)updatePickColorView:(ColorView *)lastUsedColorView;
- (void)updatePickColorView;
@end


//@interface PickBackgroundColorView : PickEraserView
//{
//    NSMutableArray *colorViewArray;
//}
//
//- (void)setColorViews:(NSArray *)colorViews;
//- (NSArray *)colorViews;
//- (void)updatePickColorView;
//@end
