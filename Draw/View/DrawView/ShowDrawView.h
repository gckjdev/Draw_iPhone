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


//@property(nonatomic, assign) double playSpeed; //default is 1/30.0;
@property(nonatomic, assign) id<ShowDrawViewDelegate>delegate;
@property(nonatomic, assign) DrawViewStatus status;
@property(nonatomic, assign) double playSpeed;
@property(nonatomic, assign) double maxPlaySpeed;

- (void)resetView;
- (void)play;
- (void)stop;
- (void)pause;
- (void)resume;
- (BOOL)playFromDrawActionIndex:(NSInteger)index;
- (void)showToIndex:(NSInteger)index; //not include the index

- (void)addDrawAction:(DrawAction *)action play:(BOOL)play;

- (void)setShowPenHidden:(BOOL)showPenHidden;

- (void)resetFrameSize:(CGSize)size;

+ (ShowDrawView *)showView;
+ (ShowDrawView *)showViewWithFrame:(CGRect)frame
                drawActionList:(NSArray *)actionList
                      delegate:(id<ShowDrawViewDelegate>)delegate;


+ (BOOL)canPlayDrawVersion:(NSInteger)version;


+ (void) createGIF:(NSInteger)frameNumber
         delayTime:(double) delayTime
    drawActionList:(NSMutableArray*)drawActionList
           bgImage:(UIImage*)bgImage
            layers:(NSArray*)layers
        canvasSize:(CGSize)canvasSize
        outputPath:(NSString*)outputPath;

@end



@interface ShowDrawView (PressAction) <UIGestureRecognizerDelegate>

- (void)setPressEnable:(BOOL)enable; //default is disable.

@end