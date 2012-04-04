//
//  ColorShopController.h
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "ColorShopCell.h"


@protocol ColorShopControllerDelegate <NSObject>

@optional
- (void)didPickedColorView:(ColorView *)colorView;
@end

@interface ColorShopController : PPTableViewController<ColorShopCellDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *coinNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)clickBackButton:(id)sender;
@property(nonatomic, assign)id<ColorShopControllerDelegate> colorShopControllerDelegate;
+(ColorShopController *)instance;
+(ColorShopController *)instanceWithDelegate:(id<ColorShopControllerDelegate>)delegate;
@end
