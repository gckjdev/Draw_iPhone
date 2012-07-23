//
//  RecommendedAppsControllerViewController.m
//  Travel
//
//  Created by 小涛 王 on 12-5-5.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "RecommendedAppsControllerViewController.h"
#import "RecommendedAppCell.h"
#import "PPDebug.h"
#import "UIUtils.h"
#import "RecommendAppManager.h"
#import "RecommendApp.h"
#import "LocaleUtils.h"


@implementation RecommendedAppsControllerViewController

- (void)viewDidLoad
{
    [self setBackgroundImageName:@"all_page_bg2.jpg"];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationLeftButton:@"返回"
                        imageName:@"ss.png"
                           action:@selector(clickBack:)];
    
    [self.navigationItem setTitle:RECOMMENDED_APP];
    self.dataList = [RecommendAppManager defaultManager].appList;
//    self.dataList = [[[AppManager defaultManager] app] recommendedAppsList];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
}

#pragma mark Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 75;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;		// default implementation
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [theTableView dequeueReusableCellWithIdentifier:[RecommendedAppCell getCellIdentifier]];
    if (cell == nil) {
        cell = [RecommendedAppCell creatCell];				
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // Customize the appearance of table view cells at first time
        UIImageView *view = [[UIImageView alloc] init];
        [view setImage:[UIImage imageNamed:@"hotapp.png"]];
        [cell setBackgroundView:view];
        [view release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    int row = [indexPath row];	
    int count = [dataList count];
    if (row >= count){
    //    PPDebug(@"[WARN] cellForRowAtIndexPath, row(%d) > data list total number(%d)", row, count);
        return cell;
    }
    RecommendedAppCell* appCell = (RecommendedAppCell*)cell;
    [appCell setCellData:[dataList objectAtIndex:row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendApp *app = [dataList objectAtIndex:indexPath.row];
    [UIUtils openApp:app.appUrl];
}


@end
