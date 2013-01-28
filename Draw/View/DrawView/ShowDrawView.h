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
    Playing = 0x1 << 1,
    Pause = 0x1 << 2,
}DrawViewStatus;

typedef enum {
    PlaySpeedTypeLow = 0, // 1/30.0
    PlaySpeedTypeNormal = 1, // x2
    PlaySpeedTypeHigh = 4, //x3
    PlaySpeedTypeSuper= 8,//x4
}PlaySpeedType;

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


@class PenView;

@interface ShowDrawView : SuperDrawView<UIGestureRecognizerDelegate>
{
    
    double _playFrameTime;

}

@property(nonatomic, assign) PlaySpeedType speed; //default is Normal;
//@property(nonatomic, assign) double playSpeed; //default is 1/30.0;
@property(nonatomic, assign) id<ShowDrawViewDelegate>delegate;
@property(nonatomic, assign) DrawViewStatus status;
@property(nonatomic, assign) double playSpeed;

- (void)play;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)playFromDrawActionIndex:(NSInteger)index;
- (void)showToIndex:(NSInteger)index; //not include the index

- (void)addDrawAction:(DrawAction *)action play:(BOOL)play;

- (void)setShowPenHidden:(BOOL)showPenHidden;

- (void)resetFrameSize:(CGSize)size;

+ (ShowDrawView *)showView;
+ (ShowDrawView *)showViewWithFrame:(CGRect)frame
                drawActionList:(NSArray *)actionList
                      delegate:(id<ShowDrawViewDelegate>)delegate;

+ (BOOL)canPlayDrawVersion:(NSInteger)version;

@end



@interface ShowDrawView (PressAction) <UIGestureRecognizerDelegate>

- (void)setPressEnable:(BOOL)enable; //default is disable.

@end