//
//  DrawLayerPanel.h
//  Draw
//
//  Created by gamy on 13-8-5.
//
//

#import <UIKit/UIKit.h>
#import "DrawLayerManager.h"

@class DrawLayerPanelCell;

@protocol DrawLayerPanelCellDelegate <NSObject>

-(void)drawLayerPanelCell:(DrawLayerPanelCell *)cell
             didClickName:(NSString *)name
              onDrawLayer:(DrawLayer *)layer;

-(void)drawLayerPanelCell:(DrawLayerPanelCell *)cell
    didClickRemoveAtDrawLayer:(DrawLayer *)layer;


-(void)didClickHelpAtCell:(DrawLayerPanelCell *)cell;
-(void)didClickAddAtCell:(DrawLayerPanelCell *)cell;
-(void)didClickSwapAtCell:(DrawLayerPanelCell *)cell;

@end

@interface DrawLayerPanelCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIButton *showFlag;
@property (retain, nonatomic) IBOutlet UIButton *help;
@property (retain, nonatomic) IBOutlet UIButton *add;
@property (retain, nonatomic) IBOutlet UIButton *layerName;
@property (retain, nonatomic) IBOutlet UIButton *remove;
@property (retain, nonatomic) IBOutlet UIButton *swap;


@property (assign, nonatomic) id<DrawLayerPanelCellDelegate> delegate;
@property (assign, nonatomic) DrawLayer *drawLayer;

- (IBAction)clickShowFlag:(id)sender;
- (IBAction)clickRemove:(id)sender;
- (IBAction)clickName:(id)sender;
- (IBAction)clickAdd:(id)sender;
- (IBAction)clickHelp:(id)sender;
- (IBAction)clickSwap:(id)sender;


@end




@interface DrawLayerPanel : UIView<UITableViewDataSource, UITableViewDelegate, DrawLayerPanelCellDelegate>


+ (id)drawLayerPanelWithDrawLayerManager:(DrawLayerManager *)dlManager;

@property(nonatomic, assign)DrawLayerManager *dlManager;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
