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

- (PBTutorial*)getTutorialByRow:(NSUInteger)row
{
    if (row >= [self.dataList count]){
        return nil;
    }
    
    return [self.dataList objectAtIndex:row];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CustomCellIdentifier = @"AllTutorialCell";
    
    AllTutorialCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:CustomCellIdentifier bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    cell.backgroundColor = [UIColor brownColor];
    NSUInteger row = [indexPath row];

    PBTutorial* pbTutorial = [self getTutorialByRow:row];
    [cell updateCellInfo:pbTutorial];
    
//        cell.tutorialName.text =[NSString stringWithFormat:@"表格的文件哦亲降低我全家都ijwqodi-%i",section];
//        cell.tutorialDesc.text=[NSString stringWithFormat:@"你好吗奇偶到家哦我去叫都叫我去的加我旗舰店"];
    
    //图片名称
//    NSString *imageToLoad = [NSString stringWithFormat:@"dialogue@2x"];
//    cell.tutorialImage.image = [UIImage imageNamed:imageToLoad];
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   return ISIPAD ? 160.0f : 80.0f;
}
#pragma mark 当点击cell 时候的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click了 %i",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TutorialInfoController* vc = [[TutorialInfoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}
@end
