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
#import "UserTutorialService.h"
#import "Tutorial.pb.h"
#import "AllTutorialController.h"
#import "TutorialStageController.h"


@interface UserTutorialMainController ()

@end


#define HEIGHT_FOR_ROW ISIPAD ? 250.0f : 120.0f
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
    
    int TOP_LEADING = (ISIPAD ? 25.0 : 15.0);
    int LEFT_RIGHT_LEADING = (ISIPAD ? 15.0 : 15.0);
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.dataTableView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[CommonTitleView titleView:self.view]
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:TOP_LEADING];
    
    NSLayoutConstraint* leftConstraint = [NSLayoutConstraint constraintWithItem:self.dataTableView
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:LEFT_RIGHT_LEADING];
    
    [self.view addConstraint:constraint];
    [self.view addConstraint:leftConstraint];
    
	// Do any additional setup after loading the view.
    // set background

    self.view.backgroundColor = COLOR_GRAY;
    [self setCanDragBack:NO];
    
}

- (void)reloadData
{
    [[UserTutorialService defaultService] getAllUserTutorials:^(int resultCode, NSArray* retList) {
        if(resultCode==0){
            PPDebug(@"<reloadData resultCode=%d>",resultCode);
            self.dataList = retList;
            [self.dataTableView reloadData];
        }else{
            PPDebug(@"<reloadData has error resultCode=%d>",resultCode);
        }
       
    }];

}


- (void)viewDidAppear:(BOOL)animated
{
    [self reloadData];
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

//取出每一行的数据
-(PBUserTutorial *)getDataListAtRow:(NSInteger)row {
    if(row>[self.dataList count]){
        return nil;
    }
    else return [self.dataList objectAtIndex:row];
}

-(NSInteger)getTutorialByRow:(NSInteger)row{
    if (row >= [self.dataList count]){
        return nil;
    }
    return [self.dataList objectAtIndex:row];
}
#pragma mark -
#pragma mark Table Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"UserTutorialMainCell";
    UserTutorialMainCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    //cell
    if (cell == nil){
        //类名
        UINib *nib = [UINib nibWithNibName:CustomCellIdentifier bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    //行数
    NSUInteger row = [indexPath row];
    PBUserTutorial* ut = [self getTutorialByRow:row];
    if(ut!=nil){
        [cell updateCellInfo:ut WithRow:indexPath.row];
        return cell;

    }
    else{
        return nil;
    }
    
}



#pragma mark 当点击cell 时候的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PBUserTutorial *pbUserTutorial = [self getTutorialByRow:indexPath.row];
    [TutorialStageController enter:self pbTutorial:pbUserTutorial];
    
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  HEIGHT_FOR_ROW;
}

//删除tableviewcell
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        UserTutorialService* userTutorialService = [UserTutorialService defaultService];
        
        [userTutorialService deleteUserTutorial:[self getDataListAtRow:indexPath.row]
                             resultBlock:^(int resultCode) {
                                 
                                 [self reloadData];
                                }];
    }
}

-(void)dealloc{
   
    [super dealloc];
    
}

@end
