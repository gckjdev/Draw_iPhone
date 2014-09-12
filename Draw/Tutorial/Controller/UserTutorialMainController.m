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
#import "TutorialCoreManager.h"
#import "SpotHelpView.h"

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
    
    [[TutorialCoreManager defaultManager] autoUpdate];

    [self showHelpView];
}

- (void)showHelpView
{
//    CGRect frame1 = [CommonTitleView titleView:self.view].frame;
    //    frame1.origin.x += self.submitButton.superview.frame.origin.x;
    //    frame1.origin.y += self.submitButton.superview.frame.origin.y;
//    SpotHelpObject* obj1 = [SpotHelpObject objectWithRect:frame1
//                                                     text:NSLS(@"kHelpAddTutorial")
//                                                      dir:(ISIPAD? CRArrowPositionTopRight:CRArrowPositionTopRight)];
//    
//    CGRect frame2 = self.pagesContainer.topBarBackgroundColor.frame;
    //    frame2.origin.x += self.helpButton.superview.frame.origin.x;
    //    frame2.origin.y += self.helpButton.superview.frame.origin.y;
//    SpotHelpObject* obj2 = [SpotHelpObject objectWithRect:frame2
//                                                     text:NSLS(@"kHelpViewInOfflineDrawHelpButtonGuide")
//                                                      dir:(ISIPAD? CRArrowPositionTopRight:CRArrowPositionTopRight)];
    
    //本来spotlight是对targetview内接圆打光，为了改成对外切圆打光，通过几何计算得出调整
    //临摹框
//    CGRect frame = self.copyView.frame;
    //    frame.origin.x += self.copyView.superview.frame.origin.x - 0.2*self.copyView.frame.size.width;
    //    frame.origin.y += self.copyView.superview.frame.origin.y - 0.2*self.copyView.frame.size.height;
    //    frame.size.width += 2*0.2*self.copyView.frame.size.width;
    //    frame.size.height += 2*0.2*self.copyView.frame.size.height;
    //    SpotHelpObject* obj3 = [SpotHelpObject objectWithRect:frame
    //                                                     text:NSLS(@"kHelpViewInOfflineDrawCopyViewGuide")
    //                                                      dir:(ISIPAD?CRArrowPositionTopLeft:CRArrowPositionTopLeft)];
    //
//    [SpotHelpView show:self.view
//          spotHelpList:@[obj1, obj2, obj3]
//                   key:KEY_LEARN_DRAW_HELP
//               perUser:YES
//              callback:callback];
    
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
        NSString *msg = NSLS(@"kRequierDelete");
        CommonDialog *deleteDialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:msg style:CommonDialogStyleDoubleButtonWithCross];
        
        [deleteDialog setClickOkBlock:^(id infoView){
            
            UserTutorialService* userTutorialService = [UserTutorialService defaultService];
            
            [userTutorialService deleteUserTutorial:[self getDataListAtRow:indexPath.row]
                                        resultBlock:^(int resultCode) {
                                            
                                            [self reloadData];
                                        }];

        }];
        [deleteDialog showInView:self.view];
    }
}

-(void)dealloc{
   
    [super dealloc];
    
}

@end
