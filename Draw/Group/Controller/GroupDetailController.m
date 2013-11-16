//
//  GroupDetailController.m
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "GroupDetailController.h"
#import "CommonTitleView.h"

@interface GroupDetailController ()

@property(nonatomic, retain) PBGroup *group;
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;

@end

@implementation GroupDetailController


+ (GroupDetailController *)enterWithGroup:(PBGroup *)group
                           fromController:(PPViewController *)controller
{
    GroupDetailController *gd = [[GroupDetailController alloc] init];
    gd.group = group;
    [controller.navigationController pushViewController:gd animated:YES];
    return [gd autorelease];
}

- (void)dealloc
{
    PPRelease(_group);
    [_titleView release];
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
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBack:)];
    [self.titleView setRightButtonTitle:NSLS(@"kEdit")];
    [self.titleView setTransparentStyle];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleView:nil];
    [super viewDidUnload];
}

#define SECTION_NUMBER 2
#define SECTION_BASE_INDEX 0
#define SECTION_MEMBER_INDEX 1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return <#expression#>
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
