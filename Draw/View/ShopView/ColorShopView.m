//
//  ColorShopView.m
//  Draw
//
//  Created by  on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorShopView.h"
#import "ShareImageManager.h"
#import "ColorShopCell.h"
#import "ColorGroup.h"

@implementation ColorShopView
@synthesize titleLabel;
@synthesize coinCountLabel;
@synthesize dataTableView;


+ (ColorShopView *)colorShopViewWithFrame:(CGRect)frame 
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ColorShopView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <ColorShopView> but cannot find cell object from Nib");
        return nil;
    }
    ColorShopView* view =  (ColorShopView*)[topLevelObjects objectAtIndex:0];
    
    //init the coin count and title 
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    UIImageView *tableBg = [[UIImageView alloc] 
                            initWithFrame:view.dataTableView.bounds];
    
    [tableBg setImage:[imageManager showcaseBackgroundImage]];
    [view.dataTableView setBackgroundView:tableBg];
    [tableBg release];
    [view.titleLabel setText:NSLS(@"kBuyColor")];
    view.dataTableView.delegate = view;
    view.dataTableView.dataSource = view;
    //get the datalist
    
    
    
    return view;
    
}


#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [colorGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [ColorShopCell getCellIdentifier];
    ColorShopCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ColorShopCell createCell:self];
    }
    cell.indexPath = indexPath;
    ColorGroup *group = [colorGroups objectAtIndex:indexPath.row];
//    group.price = 100;
    [cell setCellInfo:group hasBought:group.hasBought];
//    cell.colorShopCellDelegate = self;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ColorShopCell getCellHeight];
}


- (void)dealloc {
    [titleLabel release];
    [coinCountLabel release];
    [dataTableView release];
    [colorGroups release];
    [super dealloc];
}
@end
