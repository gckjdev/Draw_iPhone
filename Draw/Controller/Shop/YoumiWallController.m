//
//  YoumiWallController.m
//  Draw
//
//  Created by  on 12-6-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YoumiWallController.h"
#import "AccountService.h"
#import "UserManager.h"
#import "AccountManager.h"
#import "DrawConstants.h"
#import "HJManagedImageV.h"
#import "YoumiWallCell.h"
#import "HJObjManager.h"
#import "PPApplication.h"
#import "ShareImageManager.h"
#import "CommonDialog.h"
#import "YoumiWallService.h"

@implementation YoumiWallController
@synthesize helpButton;
@synthesize queryButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // 假设你用户账户的积分默认是100
        point = [[AccountManager defaultManager] getBalance];
        openApps = [[NSMutableArray alloc] init];
        [YouMiWall setShouldGetLocation:NO];
        
        //
        wall = [[YouMiWall alloc] initWithAppID:YOUMI_APP_ID withAppSecret:YOUMI_APP_KEY];
        // or
        // wall = [[YouMiWall alloc] init];
        // wall.appID = kDefaultAppID_iOS;
        // wall.appSecret = kDefaultAppSecret_iOS;
        
        // set delegate
        // wall.delegate = self;
        
        //#warning 设置相应用户的账户名称，只能是邮件格式的字符串
        wall.userID = [[UserManager defaultManager] userId];                // 设置你用户的账户名称
        
        // 添加应用列表开放源观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestOffersOpenDataSuccess:) name:YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestOffersOpenDataFail:) name:YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION_ERROR object:nil];
        
//        // 添加请求Web应用列表观察者
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestOffersSuccess:) name:YOUMI_OFFERS_RESPONSE_NOTIFICATION object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestOffersFail:) name:YOUMI_OFFERS_RESPONSE_NOTIFICATION_ERROR object:nil];
                
        // 关于积分查询观察者
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFullScreen:) name:YOUMI_WALL_VIEW_CLOSED_NOTIFICATION object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestPointSuccess:) name:YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YOUMI_OFFERS_RESPONSE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YOUMI_OFFERS_RESPONSE_NOTIFICATION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YOUMI_WALL_VIEW_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION object:nil];
    
    [wall release];
    [openApps release];
    
    [helpButton release];
    [queryButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Actions

- (void)queryPoints {
    [wall requestEarnedPointsWithTimeInterval:10.0 repeatCount:10];
}

- (void)showOffersAction:(id)sender {
    [wall showOffers:YouMiWallAnimationTransitionPushFromBottom];
}

#pragma mark - View lifecycle

- (void)updateTitle
{
    
}

- (void)viewDidLoad {
    
    [self.helpButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] forState:UIControlStateNormal];
    
    [self.queryButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];

    [super viewDidLoad];    
}

- (void)viewDidUnload {
    [self setHelpButton:nil];
    [self setQueryButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

    self.dataTableView.separatorColor = [UIColor clearColor];    
    
    // 请求开源数据
    [openApps removeAllObjects];
    [[self dataTableView] reloadData];
    
    // request data
    [self showActivityWithText:NSLS(@"请求数据中...")];
    [wall requestOffersAppData:YES pageCount:15];

    // query user earn points
    [[YoumiWallService defaultService] queryPoints];        

    [super viewDidAppear:animated];        
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self hideActivity];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [openApps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [YoumiWallCell getCellIdentifier];
    
    YoumiWallCell *cell = (YoumiWallCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [YoumiWallCell createCell:self];
    }
    
    // Configure the cell...
    if (indexPath.row >= [openApps count]) 
        return cell;
    
    YouMiWallAppModel *model = [openApps objectAtIndex:indexPath.row];
    
    cell.appNameLabel.text = model.name;
    cell.rewardDescLabel.text = model.desc;
    cell.rewardCoinsLabel.text = [NSString stringWithFormat:@"+%d金币", model.points];

    [cell.appImageView clear];
    if ([model.smallIconURL length] > 0)
    {
        [cell.appImageView setUrl:[NSURL URLWithString:model.smallIconURL]];
        [GlobalGetImageCache() manage:cell.appImageView];
    }

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [YoumiWallCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // deselect cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 
    if (indexPath.row >= [openApps count]) 
        return;
    
    YouMiWallAppModel *model = [openApps objectAtIndex:indexPath.row];
    [wall userInstallOffersApp:model];
    
    // 查询积分
    [[YoumiWallService defaultService] queryPoints];
}

#pragma mark - YouMiWall delegate

- (void)requestOffersOpenDataSuccess:(NSNotification *)note {
    
    [self hideActivity];
    
    self.dataTableView.separatorColor = [UIColor orangeColor];
        
    NSDictionary *info = [note userInfo];
    NSArray *apps = [info valueForKey:YOUMI_WALL_NOTIFICATION_USER_INFO_OFFERS_APP_KEY];
    [openApps addObjectsFromArray:apps];
    [[self dataTableView] reloadData];
}

- (void)requestOffersOpenDataFail:(NSNotification *)note {
    [self hideActivity];

    NSLog(@"--*-2--[Rewarded]requestOffersOpenDataFail:-*-- note = %@", [note description]);
    
    [UIUtils alert:@"无法获取积分墙数据，请检查网络是否可用？"];
    
//    [UIUtils alert:[note description]];
    // do nothing
}

//- (void)requestOffersSuccess:(NSNotification *)note {
//    NSLog(@"--*-3--[Rewarded]requestOffersSuccess:-*--");
//    
//    UIBarButtonItem *showOffersItem = [[UIBarButtonItem alloc] initWithTitle:@"显示Web列表" style:UIBarButtonItemStyleBordered target:self action:@selector(showOffersAction:)];
//    self.navigationItem.rightBarButtonItem = showOffersItem;
//    [showOffersItem release];
//}
//
//- (void)requestOffersFail:(NSNotification *)note {
//    NSLog(@"--*-4--[Rewarded]requestOffersFail:-*--");
//    // do nothing
//    
//}
//
//- (void)dismissFullScreen:(NSNotification *)note {
//    NSLog(@"--*-5--[Rewarded]dismissFullScreen:-*--");
//    
//    // 查询积分
//    [self queryPoints];
//}

//- (void)requestPointSuccess:(NSNotification *)note {
//    NSLog(@"--*-6--[Rewarded]requestPointSuccess:-*--");
//    
//    NSDictionary *info = [note userInfo];
//    NSArray *records = [info valueForKey:YOUMI_WALL_NOTIFICATION_USER_INFO_EARNED_POINTS_KEY];    
//    for (NSDictionary *oneRecord in records) {
////        NSString *userID = (NSString *)[oneRecord objectForKey:kOneAccountRecordUserIDOpenKey];
//        NSString *name = (NSString *)[oneRecord objectForKey:kOneAccountRecordNameOpenKey];
//        NSInteger earnedPoint = [(NSNumber *)[oneRecord objectForKey:kOneAccountRecordPoinstsOpenKey] integerValue];
//                
//        point += earnedPoint;
//        [[AccountService defaultService] chargeAccount:earnedPoint source:YoumiAppReward];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"已经成功新增%d金币",earnedPoint] message:[NSString stringWithFormat:@"来源于安装了应用[%@]", name] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        
//        [alert show];
//        [alert release];
//    }
//    
//    
//    self.title = [NSString stringWithFormat:@"金币:%d", point];    
//}

- (IBAction)clickHelp:(id)sender {

    CommonDialog* dialog = [CommonDialog createDialogWithTitle:@"免费获取金币说明" 
                                                       message:@"首先请点击并且下载应用；然后安装使用应用；最后返回本游戏，即可获得金币。［注：首次下载和安装应用才能获得金币］" 
                                                         style:CommonDialogStyleSingleButton delegate:nil];
    
    [dialog showInView:self.view];    
}

- (IBAction)clickQueryPoints:(id)sender{
    
    NSArray* orderList = [[YoumiWallService defaultService] getOrderList];
    NSString* str = @"";
    int count = [orderList count];
    int index = 0;
    for (int i=count-1; i>=0; i--){        
        if (index == 3) // max 3 records
            break;
        
        index ++;
        
        NSDictionary* order = [orderList objectAtIndex:i];
        NSString* appName = [order objectForKey:kOneAccountRecordNameOpenKey];
        NSNumber* earnPoints = [order objectForKey:kOneAccountRecordPoinstsOpenKey];
        str = [str stringByAppendingFormat:@"下载[%@]获取了%d金币;", appName, [earnPoints intValue]];
    }
    
    if ([str length] == 0){
        str = @"暂时没有查询到成功获取金币记录，请确认已经成功安装应用，并且使用了应用。";
    }
            
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:@"查询结果（最近三次）" 
                                                       message:str 
                                                         style:CommonDialogStyleSingleButton delegate:nil];
    
    [dialog showInView:self.view];    

}


@end
