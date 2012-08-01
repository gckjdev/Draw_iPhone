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
    NSMutableArray *colorViewArray;
    PickColorViewType _type;
    UIButton *addColorButton;
}

- (void)setColorViews:(NSArray *)colorViews;
- (NSArray *)colorViews;
- (void)setType:(PickColorViewType)type;
- (PickColorViewType)type;
- (NSInteger)indexOfColorView:(ColorView *)colorView;
- (void)updatePickColorView:(ColorView *)lastUsedColorView;
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
