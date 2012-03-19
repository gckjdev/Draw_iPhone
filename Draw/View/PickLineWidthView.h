//
//  PickLineWidthView.h
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PickLineWidthViewDelegate <NSObject>

@optional
- (void)didPickedLineWidth:(NSInteger)width;

@end

@interface PickLineWidthView : UIView
{
    UIImageView *_backgroundView;
    NSMutableArray *buttonArray;
    id<PickLineWidthViewDelegate> _delegate;
}

@property(nonatomic, retain)UIImageView *backgroudView;
@property(nonatomic, retain)id<PickLineWidthViewDelegate>delegate;

- (void)setLineWidths:(NSArray *)widthArray;


@end
