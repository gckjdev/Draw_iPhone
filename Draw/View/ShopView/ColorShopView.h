//
//  ColorShopView.h
//  Draw
//
//  Created by  on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorGroup;

@interface ColorShopView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *colorGroups;
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *coinCountLabel;
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;

//- (id)initWithFrame:(CGRect)frame colorGroups:(NSArray *)colorGroups;

@end
