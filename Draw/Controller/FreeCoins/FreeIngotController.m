//
//  FreeIngotController.m
//  Draw
//
//  Created by Kira on 13-3-11.
//
//

#import "FreeIngotController.h"
#import "GameBasic.pb.h"
#import "FreeIngotCell.h"
#import "GameConfigDataManager.h"
#import "ShareImageManager.h"
#import "Config.pb.h"
#import "LmWallService.h"
#import "BBSBoardController.h"
#import "GameAdWallService.h"
#import "ConfigManager.h"
#import "CommonDialog.h"
#import "BBSPostDetailController.h"
#import "CommonTitleView.h"
//#import "UIViewController+UIViewController_StoreProductViewController.h"

//#define SECTION_COUNT 2

enum {
    SECTION_FRIEND_APP = 0,
    SECTION_WALL    = 1,    
};

@interface FreeIngotController ()
{
    int _sectionCount;
}

@property (retain, nonatomic) NSArray* friendAppArray;
@property (retain, nonatomic) NSArray* wallArray;

@end

@implementation FreeIngotController

- (void)dealloc
{
    [_friendAppArray release];
    [_wallArray release];
    [_toBBSHolderView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([ConfigManager wallEnabled]){
            _sectionCount = 2;
        }
        else{
            _sectionCount = 0;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendAppArray = [GameConfigDataManager defaultManager].appRewardList;
    self.wallArray = [GameConfigDataManager defaultManager].rewardWallList;
    
    self.toBBSHolderView.hidden = ![GameApp hasBBS];

    
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    NSString * title = [GameApp wallRewardCurrencyType] == PBGameCurrencyIngot ? NSLS(@"kFreeIngots") : NSLS(@"kFreeCoins");
    
    [titleView setTitle:title];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FreeIngotCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_FRIEND_APP:
            return [self.friendAppArray count];
        case SECTION_WALL:
            return [self.wallArray count];
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FreeIngotCell *cell = [tableView dequeueReusableCellWithIdentifier:[FreeIngotCell getCellIdentifier]];
    if(cell == nil){
        cell = [FreeIngotCell createCell:self];
    }
    if (indexPath.section == SECTION_FRIEND_APP && indexPath.row < self.friendAppArray.count) {
        PBAppReward* appReward = [self.friendAppArray objectAtIndex:indexPath.row];
        [cell setCellWithPBAppReward:appReward];
    } else if (indexPath.section == SECTION_WALL && indexPath.row < self.wallArray.count) {
        PBRewardWall* rewardWall = [self.wallArray objectAtIndex:indexPath.row];
        [cell setCellWithPBRewardWall:rewardWall];
    }
    
    return cell;
}

- (NSString*)titleForSection:(int)section
{
    if (section == SECTION_FRIEND_APP) {
        return ([GameApp wallRewardCurrencyType] == PBGameCurrencyIngot ?NSLS(@"kDownloadRewardIngotAppTips") : NSLS(@"kDownloadRewardCoinAppTips"));
    }
    if (section == SECTION_WALL) {
        return ([GameApp wallRewardCurrencyType] == PBGameCurrencyIngot ?NSLS(@"kRewardIngotWallTips") : NSLS(@"kRewardCoinWallTips"));
    }
    return nil;
}

#define HEADER_FRAME ([DeviceDetection isIPAD]?CGRectMake(0,0,768,61):CGRectMake(0,0,320,36))
#define HEADER_FONT ([DeviceDetection isIPAD]?26:12)

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton* btn = [[[UIButton alloc] initWithFrame:HEADER_FRAME] autorelease];
    [btn setBackgroundImage:[[ShareImageManager defaultManager] freeIngotHeaderBg] forState:UIControlStateNormal];
    [btn setTitle:[self titleForSection:section] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:HEADER_FONT]];
    [btn setTitleColor:[UIColor colorWithRed:81/255.0 green:45/255.0 blue:7/255.0 alpha:1] forState:UIControlStateNormal];
    return btn;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_FRAME.size.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionCount;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_FRIEND_APP && indexPath.row < self.friendAppArray.count) {
        

        PBAppReward* appReward = [self.friendAppArray objectAtIndex:indexPath.row];            
        [self openApp:appReward.app.appId];
        
    } else if (indexPath.section == SECTION_WALL && indexPath.row < self.wallArray.count) {
        PBRewardWall* rewardWall = [self.wallArray objectAtIndex:indexPath.row];
        [[GameAdWallService defaultService] showWall:self wallType:rewardWall.type forceShowWall:YES];
    }
}

- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickToBBS:(id)sender
{

    [BBSPostDetailController enterFreeIngotPostController:self animated:YES];
    
//    BBSBoardController *bbs = [[BBSBoardController alloc] init];
//    [self.navigationController pushViewController:bbs animated:YES];
//    [bbs release];
}

- (void)viewDidUnload {
    [self setToBBSHolderView:nil];
    [super viewDidUnload];
}
@end
