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

#define SECTION_COUNT 2

enum {
    SECTION_FRIEND_APP = 0,
    SECTION_WALL    = 1,
};

@interface FreeIngotController ()

@property (retain, nonatomic) NSArray* friendAppArray;
@property (retain, nonatomic) NSArray* wallArray;

@end

@implementation FreeIngotController

- (void)dealloc
{
    [_friendAppArray release];
    [_wallArray release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendAppArray = [GameConfigDataManager defaultManager].appRewardList;
    self.wallArray = [GameConfigDataManager defaultManager].rewardWallList;
    // Do any additional setup after loading the view from its nib.
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
    cell = [FreeIngotCell createCell:self];
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
        return NSLS(@"kDownloadRewardAppTips");
    }
    if (section == SECTION_WALL) {
        return NSLS(@"kRewardWallTips");
    }
    return nil;
}

#define HEADER_FRAME ([DeviceDetection isIPAD]?CGRectMake(0,0,768,61):CGRectMake(0,0,320,36))
#define HEADER_FONT ([DeviceDetection isIPAD]?30:15)

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton* btn = [[UIButton alloc] initWithFrame:HEADER_FRAME];
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
    return SECTION_COUNT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_FRIEND_APP && indexPath.row < self.friendAppArray.count) {
        PBAppReward* appReward = [self.friendAppArray objectAtIndex:indexPath.row];
        [UIUtils openURL:appReward.app.downloadUrl];
    } else if (indexPath.section == SECTION_WALL && indexPath.row < self.wallArray.count) {
        PBRewardWall* rewardWall = [self.wallArray objectAtIndex:indexPath.row];
        if (rewardWall.type == 0) {
            [[LmWallService defaultService] show:self];
        }
    }
}

- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end