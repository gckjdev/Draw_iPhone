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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[FreeIngotCell getCellIdentifier]];
    cell = [FreeIngotCell createCell:self];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
