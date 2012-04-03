//
//  ColorShopController.h
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"

@interface ColorShopController : PPTableViewController
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *coinNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)clickBackButton:(id)sender;

+(ColorShopController *)instance;

@end
