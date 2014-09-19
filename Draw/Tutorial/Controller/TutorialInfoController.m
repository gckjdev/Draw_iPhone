//
//  TutorialInfoController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "TutorialInfoController.h"
#import "TutorialInfoCell.h"
#import "StageBasicInfoCell.h"
#import "UIViewController+BGImage.h"
#import "PBTutorial+Extend.h"
#import "UserTutorialService.h"
#import "UserTutorialManager.h"
#import "TutorialStageController.h"
#import "TutorialStageController.h"

enum{
    SECTION_BASIC_INFO = 0,
    SECTION_STAGE_INFO,
    SECTION_NUM
};

@interface TutorialInfoController ()

@property (nonatomic, retain) PBTutorial* pbTutorial;
@property (nonatomic, assign) BOOL infoOnly;

@end

@implementation TutorialInfoController
@synthesize tutorialCellInfoHeight;

//unable click yes为不可点击，no为可以点击
+ (TutorialInfoController*)enter:(PPViewController*)superViewController
                      pbTutorial:(PBTutorial*)pbTutorial infoOnly:(BOOL)infoOnly
{
    TutorialInfoController* vc = [[TutorialInfoController alloc] init];
    vc.pbTutorial = pbTutorial;
    [superViewController.navigationController pushViewController:vc animated:YES];
    vc.infoOnly = infoOnly;
    [vc release];
    return vc;
}

+(TutorialInfoController *)createController:(PBTutorial*)pbTutorial infoOnly:(BOOL)infoOnly
{
    TutorialInfoController* vc = [[[TutorialInfoController alloc] init] autorelease];
    vc.pbTutorial = pbTutorial;
    vc.infoOnly = infoOnly;
    return vc;
}

+ (TutorialInfoController *)show:(PPViewController*)superController
                        tutorial:(PBTutorial*)pbTutorial
                        infoOnly:(BOOL)infoOnly
{
    TutorialInfoController* infoController = [TutorialInfoController createController:pbTutorial infoOnly:NO];
    UserTutorialManager *um = [UserTutorialManager defaultManager];
    
    //打开自定义对话框
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:pbTutorial.name
                                                    customView:infoController.view
                                                         style:CommonDialogStyleSingleButtonWithCross];
    
    // manual close by caller
    dialog.manualClose = YES;
    
    // dialog button title
    if([um isTutorialLearned:pbTutorial.tutorialId]){
        //如果该课程已经添加（正在学习）
        [dialog.oKButton setTitle:NSLS(@"kStartLearnTutorial") forState:UIControlStateNormal];
    }else{
        //没有添加的时候，添加课程，弹出提示，变更按钮文字
        [dialog.oKButton setTitle:NSLS(@"kAddTutorialToLearn") forState:UIControlStateNormal];
    }
    
    [dialog setClickOkBlock:^(id infoView){
        
        if([um isTutorialLearned:pbTutorial.tutorialId]){
            
            // enter learning
            PBUserTutorial* ut = [[UserTutorialManager defaultManager] getUserTutorialByTutorialId:pbTutorial.tutorialId];
            if (ut != nil){
                [TutorialStageController enter:superController pbTutorial:ut];
            }
            
            // close dialog
            [infoController close:dialog];
            
        }
        else{
            [[UserTutorialService defaultService] addTutorial:pbTutorial resultBlock:^(int resultCode) {
                if (resultCode == 0){
                    POSTMSG(NSLS(@"kAddSuccess"));
                    [dialog.oKButton setTitle:NSLS(@"kStartLearnTutorial") forState:UIControlStateNormal];
                }
            }];
        }
    }];
    
    [dialog setClickCloseBlock:^(id infoView){
        // close dialog
        [infoController close:dialog];
    }];
    
    [dialog showInView:superController.view];
    [superController addChildViewController:infoController];
    return infoController;
}

- (void)close:(CommonDialog*)dialog
{
//    if (self.parentViewController){
//        [self removeFromParentViewController];
//    }
    
    [dialog disappear];    
}

- (void)dealloc
{
//    if (self.parentViewController){
//        [self removeFromParentViewController];
//    }
    PPRelease(_pbTutorial);
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
    self.sectionTitle = @[NSLS(@"kTutorialDesc"), NSLS(@"kTutorialStageList")];
        //加载标题
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:_pbTutorial.name];
    [titleView setTarget:self];
    
    //autolayout
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.dataTableView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[CommonTitleView titleView:self.view]
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    [self.view addConstraint:constraint];
//    [self setDefaultBGImage];
    [super viewDidLoad];
    self.tutorialCellInfoHeight = [self insertTheCellHeight];
    self.dataList = self.pbTutorial.stagesList;
    
}
-(void)viewWillAppear:(BOOL)animated{
//        self.tutorialCellInfoHeight = [self insertTheCellHeight];
    
}

#pragma mark 分区个数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return SECTION_NUM;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == SECTION_BASIC_INFO){
        return 1;
    }
    else{
        return [self.dataList count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_STAGE_INFO){
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = COLOR_WHITE;
        }else{
            cell.backgroundColor = COLOR_GRAY;
        }
    }
    else{
        cell.backgroundColor = COLOR_WHITE;
    }
}


#pragma mark 初始化每一行要显示内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //行数
    NSUInteger row = [indexPath row];
    //section数
    NSUInteger section = [indexPath section];
    
    //新建Infocell
    static NSString *CustomCellIdentifier = @"TutorialInfoCell";
    static NSString *CustomCellIdentifier2 = @"StageBasicInfoCell";
    
    //当section等于0时候出现简介
    if (section == SECTION_BASIC_INFO){
        TutorialInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        if(cell == nil){
            UINib *nib = [UINib nibWithNibName:CustomCellIdentifier bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        }
        if(_pbTutorial!=nil){
            [cell updateCellInfo:_pbTutorial];
        }
        return cell;
        
    }else{
        StageBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier2];
        if(cell == nil){
            UINib *nib = [UINib nibWithNibName:CustomCellIdentifier2 bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier2];
            cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier2];
        }
        
        if(_pbTutorial!=nil){
              NSArray* pbStageList = _pbTutorial.stagesList;
        
        //数组越界保护
        if(pbStageList!=nil && row<[pbStageList count] && row >= 0.00){
            [cell updateStageCellInfo:[pbStageList objectAtIndex:row] WithRow:row];
            
            cell.userInteractionEnabled = NO;
        }
        }
        
        
        return cell;

       

    }
}

- (NSString*)getSectionTitle:(NSUInteger)section
{
    if (section < [self.sectionTitle count]){
        NSString* title = [self.sectionTitle objectAtIndex:section];
        return title;
    }
    else{
        return @"";
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self getSectionTitle:section];
}

#define SECTION_HEADER_HEIGHT (ISIPAD ? 40 : 25)
#define SECTION_HEADER_LEADING (ISIPAD ? 20 : 10)
//重写表头
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* myView = [[[UIView alloc] init] autorelease];
    myView.backgroundColor = COLOR_GRAY;

    UILabel *titleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(SECTION_HEADER_LEADING, 0,
                                                                     tableView.bounds.size.width - SECTION_HEADER_LEADING, SECTION_HEADER_HEIGHT)];
    titleLabel.textColor = COLOR_BROWN;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = [self getSectionTitle:section];
    titleLabel.font = AD_BOLD_FONT(24, 13);

    [myView addSubview:titleLabel];
    [titleLabel release];
    
    return myView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return SECTION_HEADER_HEIGHT;
}

#define HEIGHT_FOR_ROW_IN_SECTION_ONE (ISIPAD ? 300 : 150)
#define HEIGHT_FOR_ROW (ISIPAD ? 100.0f : 50.0f)
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    if(section==0){
        return self.tutorialCellInfoHeight;
    }
    return HEIGHT_FOR_ROW;
    
}
-(CGFloat)insertTheCellHeight{
    static NSString *CustomCellIdentifier = @"TutorialInfoCell";
    UINib *nib = [UINib nibWithNibName:CustomCellIdentifier bundle:nil];
    [self.dataTableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
    TutorialInfoCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if(cell==nil){
        PPDebug(@"<insertTheCellHeight> but the cell is nil");
        return 100;
    }
    return [cell autoContentViewHeight];
 
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//protocol
-(void)clickAddButton:(UIButton *)button{
    [[UserTutorialService defaultService] addTutorial:_pbTutorial resultBlock:^(int resultCode) {
        [self updateRightButton:button];

    }];
}
//点击之后更新添加控件
-(void)updateRightButton:(UIButton *)button
{
    
    if ([[UserTutorialManager defaultManager] isTutorialLearned:_pbTutorial.tutorialId]){
        [button setTitle:NSLS(@"kAddToOpen") forState:UIControlStateNormal];
    }
    else{
        [button setTitle:NSLS(@"kAddToLearning") forState:UIControlStateNormal];

    }
}


//- (void)clickAdd:(id)sender
//{
//    [[UserTutorialService defaultService] addTutorial:_pbTutorial resultBlock:^(int resultCode) {
//        [self updateRightButton];
//        
//    }];
//}

- (void)clickOpen:(id)sender
{
    PBUserTutorial* ut = [[UserTutorialManager defaultManager] getUserTutorialByTutorialId:_pbTutorial.tutorialId];
    if (ut != nil){
        [TutorialStageController enter:self pbTutorial:ut];
    }
}


@end
