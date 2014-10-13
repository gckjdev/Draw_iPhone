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
#import "BBSBoardController.h"
#import "GameAdWallService.h"
#import "PPConfigManager.h"
#import "CommonDialog.h"
#import "BBSPostDetailController.h"
#import "CommonTitleView.h"
//#import "UIViewController+UIViewController_StoreProductViewController.h"

//#define SECTION_COUNT 2

//enum {
//    SECTION_FRIEND_APP = 0,
//    SECTION_WALL    = 1,    
//};

@interface FreeIngotController ()
{
    int _sectionCount;
    
}

@property (retain, nonatomic) NSArray* friendAppArray;
@property (retain, nonatomic) NSArray* wallArray;

@property (assign, nonatomic) int friendAppSection;
@property (assign, nonatomic) int wallSection;
@property (assign, nonatomic) int taskSection;

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
        self.friendAppArray = [GameConfigDataManager defaultManager].appRewardList;
        self.wallArray = [GameConfigDataManager defaultManager].rewardWallList;
        
        if ([PPConfigManager wallEnabled]){
            
            if ([self.friendAppArray count] > 0 && [self.wallArray count] > 0){
                self.friendAppSection = 0;
                self.wallSection = 1;
                _sectionCount = 2;
//                self.taskSection = 2;
//                _sectionCount = 3;
            }
            else if ([self.friendAppArray count] == 0 && [self.wallArray count] > 0){
                self.friendAppSection = -1;
                self.wallSection = 0;
                _sectionCount = 1;
//                self.taskSection = 1;
//                _sectionCount = 2;
            }
            else if ([self.friendAppArray count] > 0 && [self.wallArray count] == 0){
                self.friendAppSection = -1;
                self.wallSection = -1;
                _sectionCount = 0;
//                self.taskSection = 0;
//                _sectionCount = 1;
            }
            else{
                self.friendAppSection = -1;
                self.wallSection = -1;
                _sectionCount = 0;
//                self.taskSection = 0;
//                _sectionCount = 1;
            }
        }
        else{
            self.friendAppSection = -1;
            self.wallSection = -1;
            self.taskSection = 0;
            _sectionCount = 1;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toBBSHolderView.hidden = ![GameApp hasBBS];

    
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    NSString * title = [GameApp wallRewardCurrencyType] == PBGameCurrencyIngot ? NSLS(@"kFreeIngots") : NSLS(@"kFreeCoins");
    
    [titleView setTitle:title];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    self.view.backgroundColor = COLOR_WHITE;
    self.dataTableView.backgroundColor = COLOR_WHITE;
    self.toBBSHolderView.backgroundColor = COLOR_ORANGE;
    [self.toBBSHolderView enumSubviewsWithClass:[UILabel class] handler:^(id view) {
        [(UILabel *)view setTextColor:COLOR_WHITE];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath
{
    return [FreeIngotCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == self.friendAppSection){
        return [self.friendAppArray count];
    }
    else if (section == self.wallSection){
        return [self.wallArray count];
    }
    else if (section == self.taskSection){
        return 0; // TODO
    }
    else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FreeIngotCell *cell = [tableView dequeueReusableCellWithIdentifier:[FreeIngotCell getCellIdentifier]];
    if(cell == nil){
        cell = [FreeIngotCell createCell:self];
    }
    if (indexPath.section == _friendAppSection && indexPath.row < self.friendAppArray.count) {
        PBAppReward* appReward = [self.friendAppArray objectAtIndex:indexPath.row];
        [cell setCellWithPBAppReward:appReward];
    } else if (indexPath.section == _wallSection && indexPath.row < self.wallArray.count) {
        PBRewardWall* rewardWall = [self.wallArray objectAtIndex:indexPath.row];
        [cell setCellWithPBRewardWall:rewardWall];
    }
    else {
        // TODO
    }
    
    return cell;
}

- (NSString*)titleForSection:(int)section
{
    if (section == _friendAppSection) {
        return ([GameApp wallRewardCurrencyType] == PBGameCurrencyIngot ?NSLS(@"kDownloadRewardIngotAppTips") : NSLS(@"kDownloadRewardCoinAppTips"));
    }
    else if (section == _wallSection) {
        return ([GameApp wallRewardCurrencyType] == PBGameCurrencyIngot ?NSLS(@"kRewardIngotWallTips") : NSLS(@"kRewardCoinWallTips"));
    }
    else if (section == _wallSection) {
        return NSLS(@"kTask");  // TODO
    }

    return nil;
}

#define HEADER_FRAME ([DeviceDetection isIPAD]?CGRectMake(0,0,768,61):CGRectMake(0,0,320,36))
#define HEADER_FONT ([DeviceDetection isIPAD]?26:12)

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton* btn = [[[UIButton alloc] initWithFrame:HEADER_FRAME] autorelease];
    [btn setTitle:[self titleForSection:section] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:HEADER_FONT]];
    [btn setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    [btn setBackgroundColor:COLOR_ORANGE];
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
    if (indexPath.section == _friendAppSection && indexPath.row < self.friendAppArray.count) {
        

        PBAppReward* appReward = [self.friendAppArray objectAtIndex:indexPath.row];            
        [self openApp:appReward.app.appId];
        
    } else if (indexPath.section == _wallSection && indexPath.row < self.wallArray.count) {
        PBRewardWall* rewardWall = [self.wallArray objectAtIndex:indexPath.row];
        [[GameAdWallService defaultService] showWall:self wallType:rewardWall.type forceShowWall:YES];
    }
    else{
        // TODO
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
