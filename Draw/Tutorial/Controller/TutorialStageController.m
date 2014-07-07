//
//  TutorialStageController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "TutorialStageController.h"
#import "StageCell.h"
#import "UIViewController+BGImage.h"
#import "UserTutorialMainController.h"
#import "UIImageView+Extend.h"
#import "PBTutorial+Extend.h"


@interface TutorialStageController ()
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UIImage *image; // TODO dealloc方法释放
@property (nonatomic,retain)PBUserTutorial* pbUserTutorial;
@end

@implementation TutorialStageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(void)viewDidLoad{
    
    NSString *title = [[self.pbUserTutorial tutorial] name]; // TODO 国际化
    
    [super viewDidLoad];
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:title];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease]; // TODO release
    [flowLayout setItemSize:CGSizeMake(140, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
   
    [self.collectionView setCollectionViewLayout:flowLayout];
    
//    [self.collectionView registerClass:[StageCell class] forCellWithReuseIdentifier:@"StageCell"];
    UINib *nib = [UINib nibWithNibName:@"StageCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"StageCell"];
//    self.collectionView.frame = self.view.bounds;
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:[CommonTitleView titleView:self.view]
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0
                                   constant:5.0];
    [self.view addConstraint:constraint];
    
    
    [self setDefaultBGImage];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    


    
}


//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return [[[self.pbUserTutorial tutorial] stagesList] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StageCell *cell = (StageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"StageCell" forIndexPath:indexPath];
    //更新cell
    [cell updateStageCellInfo:self.pbUserTutorial withRow:indexPath.row];
    
    return cell;
}
#pragma mark -- UICollectionViewDataSource

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 8, 5, 8);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor brownColor];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    [cell setBackgroundColor:[UIColor clearColor]];
    NSLog(@"click task");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入新数据" message:nil delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"添加", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].placeholder = @"请输入新数据";
    [alert show];
    [alert release];
}
//返回这个UICollectionView是否可以被选择
//-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

- (void)dealloc {
     PPRelease(_pbUserTutorial);
    [_collectionView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}
+(TutorialStageController *)enter:(PPViewController *)superViewController pbTutorial:(PBUserTutorial *)pbUserTutorial{
    TutorialStageController *tc = [[TutorialStageController alloc] init];
    tc.pbUserTutorial = pbUserTutorial;
    [superViewController.navigationController pushViewController:tc animated:YES];
    [tc release];
    return tc;
}


@end
