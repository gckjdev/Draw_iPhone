//
//  DrawView.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperDrawView.h"
#import "MyPaint.h"

@protocol DrawViewDelegate <NSObject>

@optional
- (void)didDrawedPaint:(Paint *)paint;
- (void)didStartedTouch:(Paint *)paint;

@end


@interface DrawView : SuperDrawView
{
    CGMutablePathRef tempPath;
    
}

//@property (nonatomic, retain) NSMutableArray *drawActionList;
@property(nonatomic, assign) CGFloat lineWidth; //default is 5.0
@property(nonatomic, retain) DrawColor* lineColor; //default is black
@property(nonatomic, assign) ItemType penType;
@property(nonatomic, assign) id<DrawViewDelegate>delegate;


//@property(nonatomic, assign, getter = isRevocationSupported) BOOL revocationSupported;

//- (void)addCleanAction;
//- (DrawAction *)addChangeBackAction:(DrawColor *)color;



- (void)clearScreen;
- (void)changeBackWithColor:(DrawColor *)color;

- (void)setDrawEnabled:(BOOL)enabled;

- (BOOL)canRevoke;
- (void)revoke; //undo
- (BOOL)canRedo;
- (void)redo;

- (void)showDraft:(MyPaint *)draft;
@end
