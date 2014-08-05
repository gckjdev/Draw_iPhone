//
//  AllTutorialController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "AllTutorialController.h"
#import "UIViewController+BGImage.h"
#import "AllTutorialCell.h"
#import "TutorialInfoController.h"
#import "TutorialCoreManager.h"
#import "UserTutorialService.h"
#import "UserTutorialManager.h"
#import "TutorialStageController.h"
@interface AllTutorialController ()
@end

@implementation AllTutorialController


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

    [CommonTitleView createTitleView:self.view];
    id titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:NSLS(@"AllTutorial")];
    [titleView setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.dataTableView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[CommonTitleView titleView:self.view]
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    [self.view addConstraint:constraint];
    
    // set background
    [self setDefaultBGImage];
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.

#ifdef DEBUG
    [[TutorialCoreManager defaultManager] createTestData];
#endif
   
    //返回所有教程
    NSArray *allTutorials = [[TutorialCoreManager defaultManager] allTutorials];
    self.dataList = allTutorials;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (PBTutorial*)getTutorialByRow:(NSUInteger)row
{
    if (row >= [self.dataList count]){
        return nil;
    }
    
    return [self.dataList objectAtIndex:row];
}

#pragma mark - table view delegate

SET_CELL_BG_IN_VIEW

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CustomCellIdentifier = @"AllTutorialCell";
    
    AllTutorialCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:CustomCellIdentifier bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    PBTutorial* pbTutorial = [self getTutorialByRow:row];
    if(nil != pbTutorial){
        [cell updateCellInfo:pbTutorial];
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PPSIZE(160.f, 75.0f); //  ISIPAD ? 160.0f : 75.0f;
}



// 当点击cell 时候的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PBTutorial* pbTutorial = [self getTutorialByRow:indexPath.row];

    if(nil!=pbTutorial){

        [TutorialInfoController show:self
                            tutorial:pbTutorial
                            infoOnly:NO];
        
//        self.infoController = [TutorialInfoController createController:pbTutorial infoOnly:NO];
//        
//        //打开自定义对话框
//        CommonDialog *dialog = [CommonDialog createDialogWithTitle:pbTutorial.cnName
//                                                        customView:_infoController.view
//                                                             style:CommonDialogStyleSingleButtonWithCross];
//        
//        //如果该课程已经添加
//        if([um isTutorialLearned:pbTutorial.tutorialId]){
//            [dialog.oKButton setTitle:@"打开" forState:UIControlStateNormal];
//            [dialog setClickOkBlock:^(id infoView){
//                [self addTutorial:pbTutorial];
//            }];
//            [dialog setClickOkBlock:^(id infoView){
//                PBUserTutorial* ut = [[UserTutorialManager defaultManager] getUserTutorialByTutorialId:pbTutorial.tutorialId];
//                if (ut != nil){
//                    [TutorialStageController enter:self pbTutorial:ut];
//                }
//            }];
//           
//        //没有添加的时候
//        }else{
//            
//            [dialog.oKButton setTitle:@"添加" forState:UIControlStateNormal];
//            [dialog setClickOkBlock:^(id infoView){
//                [self addTutorial:pbTutorial];
//            }];
//        }
//        
//        [dialog showInView:self.view];
    }
}



- (void)addTutorial:(PBTutorial*)tutorial
{
    [[UserTutorialService defaultService] addTutorial:tutorial resultBlock:^(int resultCode) {
        POSTMSG(NSLS(@"kAddSuccess"));
    }];
    
}

@end
