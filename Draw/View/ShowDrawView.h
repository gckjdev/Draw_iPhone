//
//  DrawView.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawUtils.h"
#import "Paint.h"

typedef enum{
    Stop = 0x1,
    Playing = 0x1 << 1 
}DrawViewStatus;


@protocol ShowDrawViewDelegate <NSObject>

@optional
- (void)didPlayDrawView;
- (void)didPlayDrawView:(NSMutableArray*)gifFrameArray;


@end

@class DrawColor;
@class DrawAction;
@interface ShowDrawView : UIView
{
    NSMutableArray *_drawActionList;
    NSTimer *_playTimer;
    NSInteger playingActionIndex;
    NSInteger playingPointIndex;
    NSInteger startPlayIndex;
    NSMutableArray* _indexShouldSave;
}

@property (nonatomic, retain) NSMutableArray *drawActionList;
@property(nonatomic, assign) CGFloat playSpeed; //default is 1/40.0;
@property(nonatomic, assign) id<ShowDrawViewDelegate>delegate;
@property(nonatomic, assign) NSInteger status;
@property (nonatomic, retain) NSMutableArray* gifFrameArray;
@property (assign, nonatomic) BOOL shouldCreateGif;

- (void)play;
- (UIImage*)createImage;
- (void)addDrawAction:(DrawAction *)action play:(BOOL)play;
- (void)cleanAllActions;
@end
