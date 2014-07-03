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

@interface TutorialStageController ()
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UIImage *image;
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
    [super viewDidLoad];
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"tutorialName")];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(150, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 0);
   
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
                                   constant:0.0];
    [self.view addConstraint:constraint];
    
    
    [self setDefaultBGImage];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    


    
}


//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    StageCell *cell = (StageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"StageCell" forIndexPath:indexPath];
    
    //图片名称
    NSString *imageToLoad = [NSString stringWithFormat:@"disable_notice_on"];
    //加载图片
    cell.stageCellImage.image = [UIImage imageNamed:imageToLoad];
    //设置label文字
    cell.cellName.text = [NSString stringWithFormat:@"{%ld,%ld}",(long)indexPath.row,(long)indexPath.section];
    
    return cell;
}
#pragma mark -- UICollectionViewDataSource

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
#pragma mark --UICollectionViewDelegateFlowLayout
////定义每个UICollectionView 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat windowWidth = self.view.bounds.size.width;
////    CGFloat windowHeight = self.view.bounds.size.height;
//    return CGSizeMake(100,120);
//}
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
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return 4;
//}
- (void)dealloc {
    [_collectionView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}

@end
