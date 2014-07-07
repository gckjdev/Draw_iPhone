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
    self.sectionTitle = @[NSLS(@"kTutorialDesc"), NSLS(@"kTutorialStageList")];
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
    
    self.dataList = self.pbTutorial.stagesList;
   
    
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
        
        [cell updateCellInfo:_pbTutorial];
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
        return HEIGHT_FOR_ROW_IN_SECTION_ONE;
    }
    return HEIGHT_FOR_ROW;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickAdd:(id)sender
{
    [[UserTutorialService defaultService] addTutorial:_pbTutorial resultBlock:^(int resultCode) {
        [self updateRightButton];
        
    }];
}

- (void)clickOpen:(id)sender
{
    PBUserTutorial* ut = [[UserTutorialManager defaultManager] getUserTutorialByTutorialId:_pbTutorial.tutorialId];
    if (ut != nil){
        [TutorialStageController enter:self pbTutorial:ut];
    }
}


@end
