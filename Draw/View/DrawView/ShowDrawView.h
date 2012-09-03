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
- (void)didPlayDrawView:(ShowDrawView *)showDrawView AtActionIndex:(NSInteger)actionIndex pointIndex:(NSInteger)pointIndex;
- (void)didClickShowDrawView:(ShowDrawView *)showDrawView;

@end

//@class DrawColor;
//@class DrawAction;
@class PenView;

@interface ShowDrawView : SuperDrawView<UIGestureRecognizerDelegate>
{
    NSTimer *_playTimer;
    NSInteger _playingActionIndex;
    NSInteger _playingPointIndex;
    NSInteger _startPlayIndex;
    BOOL _showPenHidden;
    PenView *pen;
    BOOL _showDraw;
}

@property(nonatomic, assign) double playSpeed; //default is 1/30.0;
@property(nonatomic, assign) id<ShowDrawViewDelegate>delegate;
@property(nonatomic, assign) NSInteger status;
@property(nonatomic, retain) NSTimer *playTimer;    // Add By Benson

- (void)playFromDrawActionIndex:(NSInteger)index;
- (void)addDrawAction:(DrawAction *)action play:(BOOL)play;
- (void)setShowPenHidden:(BOOL)showPenHidden;

- (BOOL)isShowPenHidden;

@end
