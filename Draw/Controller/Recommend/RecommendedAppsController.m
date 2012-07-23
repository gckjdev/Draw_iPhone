//
//  RecommendedAppsControllerViewController.m
//  Travel
//
//  Created by 小涛 王 on 12-5-5.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "RecommendedAppsController.h"
#import "RecommendedAppCell.h"
#import "PPDebug.h"
#import "UIUtils.h"
#import "RecommendAppManager.h"
#import "RecommendApp.h"
#import "LocaleUtils.h"


@implementation RecommendedAppsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:RECOMMENDED_APP];
    RecommendApp* app = [[RecommendApp alloc] initWithAppName:NSLS(@"猜猜画画") description:NSLS(@"猜猜畫畫,又叫做你畫我猜,是一款多人一起玩的畫畫和猜詞的趣味小游戏") iconUrl:@"http://img.you100.me:8080/upload/20120722/1fc73af0-d3b4-11e1-83de-00163e0174e8_pp" appUrl:@"http://itunes.apple.com/cn/app/ni-hua-wo-cai/id513819630?l=en&mt=8"];
    [[RecommendAppManager defaultManager].appList addObject:app];
    [app release];
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

- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
