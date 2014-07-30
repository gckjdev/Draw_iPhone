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
#import "OfflineDrawViewController.h"
#import "UserTutorialService.h"
#import "TutorialInfoController.h"
#import "TutorialCoreManager.h"
#import "UserTutorialManager.h"

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
    
    // set title view
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:title];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    [[CommonTitleView titleView:self.view] setRightButtonSelector:@selector(clickEnterInfo:)];
    [[CommonTitleView titleView:self.view] setRightButtonTitle:NSLS(@"kUserTutorialInfo")];
    
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

- (void)reload
{
    self.pbUserTutorial = [[UserTutorialManager defaultManager] findUserTutorialByLocalId:self.pbUserTutorial.localId];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reload];
    [super viewDidAppear:animated];
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
    if ([self.pbUserTutorial isStageLock:row] == NO){
        [self askPracticeOrPass:row];
    }
    else{
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)askPracticeOrPass:(NSUInteger)stageIndex
{
    NSArray  *stageList = [[_pbUserTutorial tutorial] stagesList];
    PBStage* pbStage = [stageList objectAtIndex:stageIndex];
    NSString* stageId = pbStage.stageId;
    
    NSString* title = nil;
    NSString* message = nil;
    
    title = pbStage.name;
    message = [NSString stringWithFormat:NSLS(@"%@"), pbStage.desc];
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:title // NSLS(@"kAskPracticeOrPassTitle")
                                                       message:message // NSLS(@"kAskPracticeOrPassMsg")
                                                         style:CommonDialogStyleDoubleButtonWithCross];
    
    [dialog.oKButton setTitle:NSLS(@"kPass") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kPractice") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(id view){
        // Conquer
//        PBUserTutorial* newUT = [[UserTutorialService defaultService] startConquerTutorialStage:self.pbUserTutorial.localId
//                                                                                         stageId:stageId
//                                                                                      stageIndex:stageIndex];
//        
//        if (newUT){
//            
//            self.pbUserTutorial = newUT;
//            PBUserStage* userStage = [_pbUserTutorial.userStagesList objectAtIndex:stageIndex];
//            
//            // enter offline draw view controller
//            [OfflineDrawViewController conquer:self userStage:userStage userTutorial:newUT];
//        }

        [[UserTutorialService defaultService] enterConquerDraw:self
                                                userTutorial:_pbUserTutorial
                                                     stageId:stageId
                                                  stageIndex:stageIndex];
        
    }];

    [dialog setClickCancelBlock:^(id view){
//        // Practice
//        PBUserTutorial* newUT = [[UserTutorialService defaultService] startPracticeTutorialStage:self.pbUserTutorial.localId
//                                                                                         stageId:stageId
//                                                                                      stageIndex:stageIndex];
//
//        if (newUT){
//
//            self.pbUserTutorial = newUT;
//            PBUserStage* userStage = [_pbUserTutorial.userStagesList objectAtIndex:stageIndex];
//            
//            // enter offline draw view controller
//            [OfflineDrawViewController practice:self userStage:userStage userTutorial:newUT];
//        }
        
        [[UserTutorialService defaultService] enterPracticeDraw:self
                                                 userTutorial:_pbUserTutorial
                                                      stageId:stageId
                                                   stageIndex:stageIndex];

    }];
    
    [dialog showInView:self.view];
}

- (void)dealloc {
    PPRelease(_pbUserTutorial);
    PPRelease(_image);
    PPRelease(_infoController);
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
    
    // update tutorial in pb user tutorial here
    PBUserTutorial* newUT = [[UserTutorialManager defaultManager] updateLatestTutorial:pbUserTutorial];
    tc.pbUserTutorial = newUT;
    [superViewController.navigationController pushViewController:tc animated:YES];
    [tc release];
    return tc;
}


-(void)clickEnterInfo:(id)sender{
    
    PBTutorial *pbTutorial = [[TutorialCoreManager defaultManager]findTutorialByUserTutorialId:self.pbUserTutorial];
    
    self.infoController = [TutorialInfoController createController:pbTutorial infoOnly:YES];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:pbTutorial.cnName
                                                    customView:_infoController.view
                                                         style:CommonDialogStyleCross];
    
    [dialog showInView:self.view];

}


@end
