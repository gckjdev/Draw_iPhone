//
//  PickColorView.h
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DrawColor;
@protocol PickColorViewDelegate <NSObject>

@optional
- (void)didPickedColor:(DrawColor *)color;
@end

@interface PickColorView : UIView
{
    UIImageView *_backgroundView;
    NSMutableArray *buttonArray;
    id<PickColorViewDelegate> _delegate;
    NSArray *_colorList;
}

@property(nonatomic, retain)UIImageView *backgroudView;
@property(nonatomic, retain)id<PickColorViewDelegate>delegate;

- (void)setColorList:(NSArray *)colorList; // the list should be DrawColor list, not the UIColor array

@end
