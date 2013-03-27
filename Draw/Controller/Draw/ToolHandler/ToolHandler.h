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

@protocol ToolHandlerDelegate <NSObject>

@optional
- (void)toolHandler:(ToolHandler *)toolHandler
didHandledToolEvent:(ToolEvent)toolEvent
               args:(NSDictionary *)args;

@end

@interface ToolHandler : NSObject

@property(nonatomic, assign)DrawView *drawView;
@property(nonatomic, assign)DrawToolPanel *drawToolPanel;
@property(nonatomic, assign)PPTableViewController<ToolHandlerDelegate> *controller;

@property (retain, nonatomic) CanvasRect *canvasRect;
@property (retain, nonatomic) DrawColor* eraserColor;
@property (retain, nonatomic) DrawColor *tempColor;



//method from draw view
- (CGFloat)width;
- (PBDrawBg *)drawBG;
- (ItemType)penType;
- (DrawColor *)penColor;
- (BOOL)grid;

- (void)changePenColor:(DrawColor *)color;
- (void)changeDrawBG:(PBDrawBg *)drawBG;
- (void)changeInPenType:(ItemType)type;
- (BOOL)changeCanvasRect:(CanvasRect *)canvasRect;
- (void)changeWidth:(CGFloat)width;
- (void)changeAlpha:(CGFloat)alpha;
- (void)changeShape:(ShapeType)shape;
- (void)changeDesc:(NSString *)desc;
- (void)changeDrawToFriend:(MyFriend *)aFriend;
- (void)usePaintBucket;
- (void)enterDrawMode;
- (void)enterStrawMode;
- (void)useGid:(BOOL)flag;



@end


@interface ToolHandler(Online)

- (void)handleChat:(NSString *)message;

@end