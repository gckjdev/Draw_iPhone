    //
//  UserTutorialMainController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "UserTutorialMainController.h"
#import "UIViewController+BGImage.h"
#import "UserTutorialMainCell.h"
#import "UserTutorialManager.h"
#import "UserTutorialService.h"
#import "Tutorial.pb.h"
#import "AllTutorialController.h"
#import "TutorialStageController.h"
#import "TutorialCoreManager.h"
#import "SpotHelpView.h"
#import "AllTutorialCell.h"

#import "Tutorial.pb.h"
#import "TutorialInfoController.h"


@interface UserTutorialMainController ()
@property (nonatomic,retain) NSArray *pbTutorialList;
@property (nonatomic,retain) NSArray *pbUserTutorialList;
@property (nonatomic,retain) NSMutableArray *tutorialIdList;
@end


#define HEIGHT_FOR_ROW ISIPAD ? 250.0f : 120.0f
#define LEFT_RIGHT_MARGIN 15
#define TOP_MARGIN (ISIPAD?180+STATUSBAR_DELTA:80+STATUSBAR_DELTA)
@implementation UserTutorialMainController

- (id)initWithDefaultTabIndex:(NSInteger)index
{
    self = [super initWithDefaultTabIndex:index];
    return self;
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
    [self setPullRefreshType:PullRefreshTypeNone];
    
    [super viewDidLoad];
    
    [self initTabButtons];
    
    
    [self.view setBackgroundColor:COLOR_GRAY];
    // set title view
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kUserTutorialMainTitle")];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];

    // Do any additional setup after loading the view.
    // set background
    [self setCanDragBack:NO];
    [[TutorialCoreManager defaultManager] autoUpdate];
    [self showHelpView];
}

- (void)showHelpView
{
//    CGRect frame1 = [CommonTitleView titleView:self.view].frame;
    //    frame1.origin.x += self.submitButton.superview.frame.origin.x;
    //    frame1.origin.y += self.submitButton.superview.frame.origin.y;
//    SpotHelpObject* obj1 = [SpotHelpObject objectWithRect:frame1
//                                                     text:NSLS(@"kHelpAddTutorial")
//                                                      dir:(ISIPAD? CRArrowPositionTopRight:CRArrowPositionTopRight)];
//    
//    CGRect frame2 = self.pagesContainer.topBarBackgroundColor.frame;
    //    frame2.origin.x += self.helpButton.superview.frame.origin.x;
    //    frame2.origin.y += self.helpButton.superview.frame.origin.y;
//    SpotHelpObject* obj2 = [SpotHelpObject objectWithRect:frame2
//                                                     text:NSLS(@"kHelpViewInOfflineDrawHelpButtonGuide")
//                                                      dir:(ISIPAD? CRArrowPositionTopRight:CRArrowPositionTopRight)];
    
    //本来spotlight是对targetview内接圆打光，为了改成对外切圆打光，通过几何计算得出调整
    //临摹框
//    CGRect frame = self.copyView.frame;
    //    frame.origin.x += self.copyView.superview.frame.origin.x - 0.2*self.copyView.frame.size.width;
    //    frame.origin.y += self.copyView.superview.frame.origin.y - 0.2*self.copyView.frame.size.height;
    //    frame.size.width += 2*0.2*self.copyView.frame.size.width;
    //    frame.size.height += 2*0.2*self.copyView.frame.size.height;
    //    SpotHelpObject* obj3 = [SpotHelpObject objectWithRect:frame
    //                                                     text:NSLS(@"kHelpViewInOfflineDrawCopyViewGuide")
    //                                                      dir:(ISIPAD?CRArrowPositionTopLeft:CRArrowPositionTopLeft)];
    //
//    [SpotHelpView show:self.view
//          spotHelpList:@[obj1, obj2, obj3]
//                   key:KEY_LEARN_DRAW_HELP
//               perUser:YES
//              callback:callback];
    
}

- (void)reloadData
{
    [[UserTutorialService defaultService] getAllUserTutorials:^(int resultCode, NSArray* retList) {
        if(resultCode==0){
            PPDebug(@"<reloadData resultCode=%d>",resultCode);
            self.pbUserTutorialList = retList;
            self.dataList = retList;
            //返回所有教程
            NSArray *allTutorials = [[TutorialCoreManager defaultManager] allTutorials];
            self.pbTutorialList = allTutorials;
            [self.dataTableView reloadData];
        }else{
            PPDebug(@"<reloadData has error resultCode=%d>",resultCode);
        }
       
    }];
    
   

}


- (void)viewDidAppear:(BOOL)animated
{
    [self reloadData];
    [super viewDidAppear:animated];
    [self updateAllBadge];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickAdd:(id)sender
{
    AllTutorialController* vc = [[AllTutorialController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

//取出每一行的数据
-(PBUserTutorial *)getDataListAtRow:(NSInteger)row {
    if(row>[self.dataList count]){
        return nil;
    }
    else return [self.dataList objectAtIndex:row];
}

-(PBUserTutorial *)getTutorialByRow:(NSInteger)row{
    if (row >= [self.pbUserTutorialList count]){
        return nil;
    }
    return [self.pbUserTutorialList objectAtIndex:row];
}
#pragma mark -
#pragma mark Table Data Source Methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([[self currentTab] tabID]) {
        case TutorialTypeMine:
            return ;
            break;
            
        case TutorialTypeAll:
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = COLOR_GRAY;
            }else{
                cell.backgroundColor = COLOR_WHITE;
            }            break;
            break;
        default:
            return;
            break;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch ([[self currentTab] tabID]) {
        case TutorialTypeMine:
            return [self sorterTutorialCellWithTypeTag:TutorialTypeMine WithTableView:tableView WithRow:indexPath.row];
            break;
            
        case TutorialTypeAll:

            return [self sorterTutorialCellWithTypeTag:TutorialTypeAll WithTableView:tableView WithRow:indexPath.row];
            break;
            
        default:
            return nil;
            break;
    }
}



#pragma mark 当点击cell 时候的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch ([[self currentTab] tabID]) {
        case TutorialTypeMine:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            PBUserTutorial *pbUserTutorial = [self getTutorialByRow:indexPath.row];
            [TutorialStageController enter:self pbTutorial:pbUserTutorial];
            break;
            
        case TutorialTypeAll:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            PBTutorial* pbTutorial = [self getAllTutorialByRow:indexPath.row];
            if(nil!=pbTutorial){
                
                [TutorialInfoController show:self
                                    tutorial:pbTutorial
                                    infoOnly:NO];
            }
            break;
            
        default:
            return;
            break;
    }

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch ([[self currentTab] tabID]) {
        case TutorialTypeMine:
            return [_pbUserTutorialList count];
            break;
            
        case TutorialTypeAll:
            return [_pbTutorialList count];
            break;
            
        default:
            return 0;
            break;
    }


}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([[self currentTab] tabID]) {
        case TutorialTypeMine:
            return  HEIGHT_FOR_ROW;
            break;
            
        case TutorialTypeAll:
            return  PPSIZE(160.f, 75.0f); //  ISIPAD ? 160.0f : 75.0f;
            break;
            
        default:
            return HEIGHT_FOR_ROW;
            break;
    }

    
}

//删除tableviewcell
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([[self currentTab] tabID]) {
        case TutorialTypeMine:
            return UITableViewCellEditingStyleDelete;
            break;
            
        case TutorialTypeAll:
            return nil;
            break;
            
        default:
             return nil;
            break;
    }
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSString *msg = NSLS(@"kRequierDelete");
        CommonDialog *deleteDialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:msg style:CommonDialogStyleDoubleButtonWithCross];
        
        [deleteDialog setClickOkBlock:^(id infoView){
            
            UserTutorialService* userTutorialService = [UserTutorialService defaultService];
            
            [userTutorialService deleteUserTutorial:[self getDataListAtRow:indexPath.row]
                                        resultBlock:^(int resultCode) {
                                            
                                            [self reloadData];
                                        }];

        }];
        [deleteDialog showInView:self.view];
    }
}

-(void)dealloc{
    PPRelease(_tutorialIdList);
    PPRelease(_pbTutorialList);
    PPRelease(_pbUserTutorialList);
    [super dealloc];
    
}


#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 2;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 200;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {TutorialTypeMine,TutorialTypeAll};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    NSString *tabDesc[] = {NSLS(@"kTutorialTypeMine"),NSLS(@"kTutorialTypeAll")};
    //    NSString *tabDesc[] = {NSLS(@"kNoMyFeed"),NSLS(@"kNoTimelineGuess"),NSLS(@"kNoMyComment"),NSLS(@"kNoDrawToMe")};
    
    return tabDesc[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kTutorialTypeMine"),NSLS(@"kTutorialTypeAll")};
    return tabTitle[index];
}

- (void)clickTab:(NSInteger)tabID
{
    TutorialCoreManager *core = [TutorialCoreManager defaultManager];
    switch (tabID) {
        case TutorialTypeMine:
            [self updateAllBadge];
            if(self.dataTableView.frame.size.width != [[UIScreen mainScreen] bounds].size.width-2*LEFT_RIGHT_MARGIN){
                self.dataTableView.frame = CGRectMake(LEFT_RIGHT_MARGIN, TOP_MARGIN, [[UIScreen mainScreen] bounds].size.width-2*LEFT_RIGHT_MARGIN, [[UIScreen mainScreen] bounds].size.height-TOP_MARGIN);
                
            }
            [self reloadData];
            break;
            
        case TutorialTypeAll:
            if(self.dataTableView.frame.size.width != [[UIScreen mainScreen] bounds].size.width){
                self.dataTableView.frame = CGRectMake(0, TOP_MARGIN, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-TOP_MARGIN);
                PPDebug(@"<cellForRowAtIndexPath> width = %f",self.dataTableView.frame.size.width);
            }
 
            [core setTutorialIdIntoUserDefault:_tutorialIdList];
            break;
            
        default:
            return;
            break;
    }
    [super clickTab:tabID];

}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self reloadData];
    [self finishLoadDataForTabID:tabID resultList:self.pbUserTutorialList];
}
//
//
- (void)updateAllBadge
{
    [_tutorialIdList removeAllObjects];
    TutorialCoreManager *core = [TutorialCoreManager defaultManager];
     _tutorialIdList = [core getTutorialNewList:_pbTutorialList];
    [self setBadge:[_tutorialIdList count] onTab:TutorialTypeAll];
}


-(UITableViewCell *)sorterTutorialCellWithTypeTag:(int)tag WithTableView:(UITableView *)tableView WithRow:(int)row{
    NSDictionary *tabDictionary = @{@(TutorialTypeMine):@"UserTutorialMainCell",
                                    @(TutorialTypeAll):@"AllTutorialCell"};
   
    
    
    if(tag == TutorialTypeMine){
        
        NSString *nibName =  [tabDictionary objectForKey:@(tag)];
        
        UIView *view = [self getTableViewCellWithDef:nibName WithTableView:tableView];
        UserTutorialMainCell *viewCell = nil;
        if([view isKindOfClass:[UserTutorialMainCell class]]){
            viewCell = (UserTutorialMainCell *)view;
        }

        PBUserTutorial* ut = [self getTutorialByRow:row];
        if(ut==nil){
            PPDebug(@"<sorterTutorialCellWithTypeTag> PBuserTutorial is nil");
            return nil;
        }
        if(nil != ut){
            [viewCell updateCellInfo:ut WithRow:row];
        }

        return viewCell;
    }
    if(tag == TutorialTypeAll){
        NSString *nibName =  [tabDictionary objectForKey:@(tag)];
        
        UIView *view = [self getTableViewCellWithDef:nibName WithTableView:tableView];
        AllTutorialCell *allTutorialCell = nil;
        if([view isKindOfClass:[AllTutorialCell class]]){
             allTutorialCell = (AllTutorialCell *)view;
        }
        
        PBTutorial* ut = [self getAllTutorialByRow:row];
        if(ut==nil){
            PPDebug(@"<sorterTutorialCellWithTypeTag> PBuserTutorial is nil");
            return nil;
        }
        if(nil != ut){
           [allTutorialCell updateCellInfo:ut];
        }
        return allTutorialCell;
    }
    
    
    return nil;
}
-(UITableViewCell *)getTableViewCellWithDef:(NSString*)nibName WithTableView:(UITableView *)tableView {
    
    NSString *CustomCellIdentifier = nibName;
    UserTutorialMainCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    //cell
    if (cell == nil){
        //类名
        UINib *nib = [UINib nibWithNibName:CustomCellIdentifier bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    return cell;
}

- (PBTutorial*)getAllTutorialByRow:(NSUInteger)row
{
    if (row >= [self.pbTutorialList count]){
        return nil;
    }
    return [self.pbTutorialList objectAtIndex:row];
}


@end
