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

enum{
    SECTION_BASIC_INFO = 0,
    SECTION_STAGE_INFO,
    SECTION_NUM
};

@interface TutorialInfoController ()

@property (nonatomic, retain) PBTutorial* pbTutorial;

@end

@implementation TutorialInfoController

+ (TutorialInfoController*)enter:(PPViewController*)superViewController
                      pbTutorial:(PBTutorial*)pbTutorial
{
    TutorialInfoController* vc = [[TutorialInfoController alloc] init];
    vc.pbTutorial = pbTutorial;
    [superViewController.navigationController pushViewController:vc animated:YES];
    [vc release];
    return vc;
}

- (void)dealloc
{
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

- (void)updateRightButton
{
    id titleView = [CommonTitleView titleView:self.view];
    if ([[UserTutorialManager defaultManager] isTutorialLearned:_pbTutorial.tutorialId]){
        [titleView setRightButtonTitle:NSLS(@"kOpenToLearn")];
        [titleView setRightButtonSelector:@selector(clickOpen:)];
    }
    else{
        [titleView setRightButtonTitle:NSLS(@"kAddToLearn")];
        [titleView setRightButtonSelector:@selector(clickAdd:)];
    }
}

- (void)viewDidLoad
{
    self.sectionTitle = @[@"简介",@"关卡列表"];
    self.numberRowsSection = @[@1,@4];
    [CommonTitleView createTitleView:self.view];
    
    id titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:_pbTutorial.name]; //NSLS(@"kTutorialInfoTitle")];
    [titleView setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    [self updateRightButton];
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.dataTableView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[CommonTitleView titleView:self.view]
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    [self.view addConstraint:constraint];
    [self setDefaultBGImage];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    // TODO
//    self.dataList = self.pbTutorial.
   
    
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
        
        [cell updateCellInfo:_pbTutorial];
        return cell;
        
    }else{
        StageBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier2];
        if(cell == nil){
            UINib *nib = [UINib nibWithNibName:CustomCellIdentifier2 bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier2];
            cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier2];
        }
        cell.taskNumber.text=@"1";
        cell.taskName.text = @"2";
        cell.taskDesc.text = @"3";
        cell.userInteractionEnabled = NO;
        return cell;

    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"简介";
    }
    else
        return @"关卡说明";
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 25;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    if(section==0){
        return 150;
    }
        return 60;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"你好你好！");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark addTutorial

-(void)clickButton{
    NSLog(@"test");
}

- (void)clickAdd:(id)sender
{
    [[UserTutorialService defaultService] addTutorial:_pbTutorial resultBlock:^(int resultCode) {
        [self updateRightButton];
    }];
}

- (void)clickOpen:(id)sender
{
    // TODO goto Tutorial Stage Controller
}


@end
