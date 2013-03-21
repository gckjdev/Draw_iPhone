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

@end


@interface ToolHandler(Online)



@end