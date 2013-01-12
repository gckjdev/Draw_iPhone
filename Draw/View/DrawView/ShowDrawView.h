//
//  DrawView.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperDrawView.h"

typedef enum{
    Stop = 0x1,
    Playing = 0x1 << 1 
}DrawViewStatus;

@class ShowDrawView;
@protocol ShowDrawViewDelegate <NSObject>

@optional
- (void)didPlayDrawView:(ShowDrawView *)showDrawView;
- (void)didPlayDrawView:(ShowDrawView *)showDrawView
          AtActionIndex:(NSInteger)actionIndex 
             pointIndex:(NSInteger)pointIndex;
- (void)didClickShowDrawView:(ShowDrawView *)showDrawView;
- (void)didLongClickShowDrawView:(ShowDrawView *)showDrawView;
@end

//@class DrawColor;
//@class DrawAction;
@class PenView;

@interface ShowDrawView : SuperDrawView<UIGestureRecognizerDelegate>
{
    
    NSInteger _playingActionIndex;
    NSInteger _playingPointIndex;
    
    BOOL _showPenHidden;
    PenView *pen;


}

@property(nonatomic, assign) double playSpeed; //default is 1/30.0;
@property(nonatomic, assign) id<ShowDrawViewDelegate>delegate;
@property(nonatomic, assign) DrawViewStatus status;


- (void)play;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)addDrawAction:(DrawAction *)action play:(BOOL)play;

- (void)setShowPenHidden:(BOOL)showPenHidden;
- (BOOL)isShowPenHidden;

+ (ShowDrawView *)showView;
- (void)resetFrameSize:(CGSize)size;
@end
