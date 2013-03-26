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

@protocol ToolHandlerDelegate <NSObject>

@optional
- (void)toolHandler:(ToolHandler *)toolHandler
didHandledToolEvent:(ToolEvent)toolEvent
               args:(NSDictionary *)args;

@end

@interface ToolHandler : NSObject<DrawToolPanelDelegate>

@property(nonatomic, assign)DrawView *drawView;
@property(nonatomic, assign)DrawToolPanel *drawToolPanel;
@property(nonatomic, assign)PPTableViewController<ToolHandlerDelegate> *controller;

@property (retain, nonatomic) DrawColor* eraserColor;
@property (retain, nonatomic) DrawColor* penColor;
@property (retain, nonatomic) DrawColor *tempColor;

- (void)changePenColor:(DrawColor *)color;
- (void)changeDrawBG:(PBDrawBg *)drawBG;
- (void)changeInPenType:(ItemType)type;
- (void)changeCanvasRect:(CGRect)rect;
- (void)changeWidth:(CGFloat)width;
- (void)changeAlpha:(CGFloat)alpha;
- (void)changeShape:(ShapeType)shape;
- (void)changeDesc:(NSString *)desc;
- (void)changeDrawToFriend:(MyFriend *)aFriend;
- (void)usePaintBucket;
- (void)enterDrawMode;
- (void)enterStrawMode;
@end


@interface ToolHandler(Online)

- (void)handleChat:(NSString *)message;

@end