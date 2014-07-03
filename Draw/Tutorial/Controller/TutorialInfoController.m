//
//  TutorialInfoController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "TutorialInfoController.h"
#import "TutorialInfoCell.h"
#import "TaskInfoCell.h"
#import "UIViewController+BGImage.h"
@interface TutorialInfoController ()

@end

@implementation TutorialInfoController
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
    self.sectionTitle = @[@"简介",@"关卡列表"];
    self.numberRowsSection = @[@1,@4];
    [CommonTitleView createTitleView:self.view];
    
    id titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:NSLS(@"TaskName")];
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
    [self setDefaultBGImage];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.dataList = @[@"a",@"b",@"c",@"d"];
   
    
}

#pragma mark 分区个数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [[self.numberRowsSection objectAtIndex:section] intValue];
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
      static NSString *CustomCellIdentifier2 = @"TaskInfoCell";
    
    
    //当section等于0时候出现简介
    if(section==0){
        TutorialInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        if(cell == nil){
            UINib *nib = [UINib nibWithNibName:CustomCellIdentifier bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        }
        cell.tutorialDesc.text = @"test1";
        cell.tutorialDescInfo.text = @"test1";
        cell.userInteractionEnabled = YES;
       
        
        return cell;
    }else{
        TaskInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier2];
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
    return nil;

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

@end
