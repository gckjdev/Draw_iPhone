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


#define COLLECTION_CELL_WIDTH (ISIPAD ? 220 : 140)
#define COLLECTION_CELL_HEIGHT (ISIPAD ? 200 : 100)
-(void)viewDidLoad{
    
    NSString *title = [[self.pbUserTutorial tutorial] name]; // 实现 国际化
    [super viewDidLoad];
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:title];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    
    //流布局
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    [flowLayout setItemSize:CGSizeMake(COLLECTION_CELL_WIDTH,COLLECTION_CELL_HEIGHT)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumLineSpacing:20];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    //指定xib文件
    UINib *nib = [UINib nibWithNibName:@"StageCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"StageCell"];
    
    //autolayout
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:[CommonTitleView titleView:self.view]
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0
                                   constant:5.0];
    [self.view addConstraint:constraint];
    
    //背景
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

#define UI_EDGE_INSERTS_MAKE (ISIPAD ? 20 : 8)
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE);
}


#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    if (row <= self.pbUserTutorial.currentStageIndex){
        POSTMSG(@"闯关修炼正在开发中");
    }
    else{
    }
    
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入新数据" message:nil delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"添加", nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alert textFieldAtIndex:0].placeholder = @"请输入新数据";
//    [alert show];
//    [alert release];
}


- (void)dealloc {
     PPRelease(_pbUserTutorial);
     PPRelease(_image);
     [_collectionView release];
     [super dealloc];
}
- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}
//跳转
+(TutorialStageController *)enter:(PPViewController *)superViewController pbTutorial:(PBUserTutorial *)pbUserTutorial{
    TutorialStageController *tc = [[TutorialStageController alloc] init];
    tc.pbUserTutorial = pbUserTutorial;
    [superViewController.navigationController pushViewController:tc animated:YES];
    [tc release];
    return tc;
}


@end