//
//  PickPenView.h
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DrawColor;
@protocol PickPenDelegate <NSObject>

@optional
- (void)didPickedColor:(DrawColor *)color;
- (void)didPickedLineWidth:(NSInteger)width;
@end

@interface PickPenView : UIView
{
    UIImageView *_backgroundView;
    id<PickPenDelegate> _delegate;
    NSArray *_colorList;
    NSMutableArray *colorButtonArray;
    NSMutableArray *widthButtonArray;

}
@property(nonatomic, retain)UIImageView *backgroudView;
@property(nonatomic, retain)id<PickPenDelegate>delegate;

- (void)setColorList:(NSArray *)colorList; // the list should be DrawColor list, not the UIColor array
- (void)setLineWidths:(NSArray *)widthArray; // the list should be NSNumber list


@end
