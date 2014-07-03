//
//  UserTutorialMainController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "UserTutorialMainController.h"
#import "UIViewController+BGImage.h"
#import "UserTutorialMainCell.h"
#import "UserTutorialManager.h"
#import "Tutorial.pb.h"
#import "AllTutorialController.h"
#import "TutorialStageController.h"

@interface UserTutorialMainController ()

@end

@implementation UserTutorialMainController

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
    // set title view
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kUserTutorialMainTitle")];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    [[CommonTitleView titleView:self.view] setRightButtonSelector:@selector(clickAdd:)];
    [[CommonTitleView titleView:self.view] setRightButtonTitle:NSLS(@"kAddTutorial")];
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.dataTableView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[CommonTitleView titleView:self.view]
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    [self.view addConstraint:constraint];

    
    
    
	// Do any additional setup after loading the view.
    
    // set background
    [self setDefaultBGImage];
    
    self.dataList = [[UserTutorialManager defaultManager] allUserTutorials];
    
   

}

- (void)viewDidAppear:(BOOL)animated
{
    self.dataList = [[UserTutorialManager defaultManager] allUserTutorials];
    [self.dataTableView reloadData];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickAdd:(id)sender
{
    AllTutorialController* vc = [[AllTutorialController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark -
#pragma mark Table Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CustomCellIdentifier = @"UserTutorialMainCell";
    UserTutorialMainCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (cell == nil){
        //类名
        UINib *nib = [UINib nibWithNibName:CustomCellIdentifier bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    
    
    PBUserTutorial* ut = [self.dataList objectAtIndex:row];
    [cell updateCellInfo:ut];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

#pragma mark 当点击cell 时候的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click了 %i",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TutorialStageController* vc = [[TutorialStageController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}


#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ISIPAD ? 230.0f : 150.0f;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView
//  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    return nil;
//}

@end
