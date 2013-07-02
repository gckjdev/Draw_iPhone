//
//  ToolHandler.h
//  Draw
//
//  Created by gamy on 13-3-21.
//
//

#import <Foundation/Foundation.h>
#import "DrawToolPanel.h"
#import "OfflineDrawViewController.h"
#import "OnlineDrawViewController.h"
#import "DrawView.h"
#import "PPViewController.h"

typedef enum{
    ToolEventRedo = 1,
}ToolEvent;

@class ToolHandler;
@class PBDrawBg;
@class MyFriend;
@class CanvasRect;
@class PBUserPhoto;

@protocol ToolHandlerDelegate <NSObject>

@optional
- (void)toolHandler:(ToolHandler *)toolHandler
didHandledToolEvent:(ToolEvent)toolEvent
               args:(NSDictionary *)args;

@end

@interface ToolHandler : NSObject

@property(nonatomic, assign)DrawView *drawView;
@property(nonatomic, assign)DrawToolPanel *drawToolPanel;
@property(nonatomic, assign)PPViewController *controller;


@property (retain, nonatomic) CanvasRect *canvasRect;
@property (retain, nonatomic) DrawColor *penColor;

@property(nonatomic, assign) ItemType penType;
@property(nonatomic, assign) Shadow *shadow;


//method from draw view
- (CGFloat)width;
- (BOOL)grid;
- (DrawColor *)eraserColor;

- (void)changePenColor:(DrawColor *)color;
- (void)changeDrawBG:(PBDrawBg *)drawBG;
- (void)changeInPenType:(ItemType)type;
- (BOOL)changeCanvasRect:(CanvasRect *)canvasRect;
- (void)changeWidth:(CGFloat)width;
- (void)changeAlpha:(CGFloat)alpha;
- (void)changeShape:(ShapeType)shape isStroke:(BOOL)isStroke;
- (void)changeShapeStroke:(BOOL)isStroke;
- (void)changeDesc:(NSString *)desc;
- (void)changeDrawToFriend:(MyFriend *)aFriend;
- (void)changeCopyPaint:(UIImage*)aPhoto;
- (void)changeShadow:(Shadow *)shadow;

- (void)usePaintBucket;
- (void)enterDrawMode;
- (void)enterStrawMode;
- (void)enterShapeMode;
- (void)enterEraserMode;
- (void)useGid:(BOOL)flag;
- (void)handleRedo;
- (void)handleUndo;
- (void)handleChat;
- (void)handleShowCopyPaint;

//for test
- (void)addGradient;

//only use for little gee
- (void)changeDrawWord:(NSString*)wordText;

- (TouchActionType)setTouchActionType:(TouchActionType)type;
- (TouchActionType)touchActionType;

@end

