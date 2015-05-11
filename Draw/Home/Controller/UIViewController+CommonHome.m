//
//  UIViewController+CommonHome.m
//  Draw
//
//  Created by qqn_pipi on 14-7-9.
//
//

#import "UIViewController+CommonHome.h"
#import "HomeMenuView.h"
#import "ChargeController.h"
#import "StatisticManager.h"
#import "UserManager.h"
#import "UserSettingController.h"
#import "UIUtils.h"
#import "BulletinView.h"
#import "AnalyticsManager.h"
#import "BulletinService.h"
#import "NotificationName.h"
#import "CommonGameNetworkService.h"
#import "AudioManager.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"
#import "HomeMenuView.h"
#import "DrawImageManager.h"
#import "DrawHomeHeaderPanel.h"
#import "DrawMainMenuPanel.h"
#import "MyFeedController.h"
#import "StoreController.h"
#import "BBSBoardController.h"
#import "FeedbackController.h"
#import "HotController.h"
#import "ChatListController.h"
#import "FriendController.h"
#import "TaskController.h"
#import "DrawImageManager.h"
#import "ContestController.h"
#import "PainterController.h"
#import "GroupHomeController.h"
#import "FreeIngotController.h"
#import "ShowOpusClassListController.h"
#import "UserTutorialMainController.h"
#import "FeedListController.h"
#import "NewHotController.h"
#import "MetroHomeController.h"
#import "ShareController.h"
#import "OnlineGuessDrawController.h"
#import "GuessModesController.h"
#import "DrawRoomListController.h"
#import "ICETutorialController.h"
#import "GuidePageManager.h"
#import "ResultSharePageViewController.h"
#import "AudioManager.h"
#import "BBSPostDetailController.h"
#import "ContestOpusController.h"
#import "ContestManager.h"
#import "PurchaseVipController.h"
#import "TaoBaoController.h"
#import "OpusClassInfoManager.h"
#import "TutorialInfoController.h"
#import "TutorialCoreManager.h"
#import "MKBlockActionSheet.h"
#import "ChangeAvatar.h"
#import "PhotoDrawSheet.h"
#import "FeedListController.h"
#import "UIImageExt.h"

@implementation UIViewController (CommonHome)

- (void)enterUserTimeline
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TIMELINE];
    [MyFeedController enterControllerWithIndex:0 fromController:self animated:YES];
    [[StatisticManager defaultManager] setTimelineOpusCount:0];
}

- (void)enterShop
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_SHOP];
    StoreController *vc = [[[StoreController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterGroup
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_GROUP];
    GroupHomeController *grp = [[GroupHomeController alloc] init];
    [self.navigationController pushViewController:grp animated:YES];
    [grp release];
}

- (void)enterBBS
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_BBS];
    BBSBoardController *bbs = [[BBSBoardController alloc] init];
    [self.navigationController pushViewController:bbs animated:YES];
    [bbs release];
}

- (void)enterTask{
    TaskController *vc = [[[TaskController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterLearnDraw{
    UserTutorialMainController* ut = [[UserTutorialMainController alloc] init];
    [self.navigationController pushViewController:ut animated:YES];
    [ut release];
    return;
}

- (void)enterOfflineDraw
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_DRAW];
    [OfflineDrawViewController startDraw:[Word cusWordWithText:@""] fromController:self startController:self targetUid:nil];
}

- (void)enterTimeline
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TIMELINE];
    
    [MyFeedController enterControllerWithIndex:0 fromController:self animated:YES];
    [[StatisticManager defaultManager] setTimelineOpusCount:0];    
}

- (void)enterOpusClass
{
    NewHotController* vc = [[NewHotController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    return;
}

- (void)enterMore
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_MORE];
    
    FeedbackController* feedBack = [[FeedbackController alloc] init];
    [self.navigationController pushViewController:feedBack animated:YES];
    [feedBack release];
}

- (void)enterTopOpus
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TOP];
    HotController *hc = [[HotController alloc] init];
    [self.navigationController pushViewController:hc animated:YES];
    [hc release];
}

- (void)enterContest{
    
//#ifdef DEBUG
//    MetroHomeController *mc = [[MetroHomeController alloc] init];
//    [self.navigationController pushViewController:mc animated:YES];
//    [mc release];
//    return;
//#endif
    
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_CONTEST];
    
    ContestController *cc = [[ContestController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
    [cc release];
}


- (void)enterChat
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_CHAT];
    
    ChatListController *controller = [[ChatListController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)enterFriend
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_FRIEND];
    FriendController *mfc = [[FriendController alloc] init];
    if ([[StatisticManager defaultManager] fanCount] > 0) {
        [mfc setDefaultTabIndex:FriendTabIndexFan];
    }
    [self.navigationController pushViewController:mfc animated:YES];
    [mfc release];
}

- (void)enterUserSetting
{
    UserSettingController *settings = [[UserSettingController alloc] init];
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
}

- (void)enterPainter
{
    PainterController *pc = [[PainterController alloc] init];
    [self.navigationController pushViewController:pc animated:YES];
    [pc release];
}

- (void)enterDraftBox
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_OPUS];
    ShareController* share = [[ShareController alloc] init];
    int count = [[StatisticManager defaultManager] recoveryCount];
    if (count > 0) {
        [share setDefaultTabIndex:2];
        [[StatisticManager defaultManager] setRecoveryCount:0];
    }
    [self.navigationController pushViewController:share animated:YES];
    [share release];
}

- (BOOL)isRegistered
{
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        return YES;
    }
    
    if ([[UserManager defaultManager] isOldUserWithoutXiaoji]){
        return YES;
    }
    
    return NO;
}

- (BOOL)toRegister
{
    // change by Benson for new xiaoji number login and logout
    return [[UserService defaultService] checkAndAskLogin:self.view];
}

- (void)enterUserDetail
{
    if ([self toRegister]){
        return;
    }
    if ([[UserManager defaultManager] isOldUserWithoutXiaoji]){
        [self askShake];
        return;
    }
    
    UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
    [self.navigationController pushViewController:us animated:YES];
    [us release];
}

- (void)enterFreeCoins
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_FREE_COINS];
    FreeIngotController* fc = [[[FreeIngotController alloc] init] autorelease];
    [self.navigationController pushViewController:fc animated:YES];
}

-(void)enterGuess{
    
    GuessModesController *vc =[[[GuessModesController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)enterOnlineDraw{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_ONLINE];
    UIViewController* rc = [[[DrawRoomListController alloc] init] autorelease];
    [self.navigationController pushViewController:rc animated:YES];
}

- (void)askShake
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage")
                                                       message:NSLS(@"kTryShakeXiaoji")
                                                         style:CommonDialogStyleDoubleButtonWithCross];
    
    [dialog.oKButton setTitle:NSLS(@"kTryTakeNumber") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kViewMyProfile") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(id infoView){
        [[UserService defaultService] showXiaojiNumberView:self.view];
    }];
    
    [dialog setClickCancelBlock:^(id infoView){
        [self gotoMyDetail];
    }];
    
    [dialog showInView:self.view];
}

- (void)gotoMyDetail
{
    UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
    [self.navigationController pushViewController:us animated:YES];
    [us release];
}

- (void)showBulletinView
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_BULLETIN];
    
    BulletinView *v = [BulletinView createWithSuperController:(PPViewController*)self];
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBulletin") customView:v style:CommonDialogStyleCross];
    [dialog showInView:self.view];
}

//ChaoSo 7.21 2014
//test
-(void)goToGuidePage
{
    [GuidePageManager showGuidePage:self];
}

-(void)enterMetroHome{
    MetroHomeController *mc = [[MetroHomeController alloc] init];
    [self.navigationController pushViewController:mc animated:YES];
    [mc release];
    
}
-(void)enterResultSharePage{
    ResultSharePageViewController *rspc = [[ResultSharePageViewController alloc] init];
    [self.navigationController pushViewController:rspc
                                         animated:YES];
    [rspc release];
}

- (void)startAudioManager
{
    [[AudioManager defaultManager] setBackGroundMusicWithName:[GameApp getBackgroundMusicName]];
    [[AudioManager defaultManager] setVolume:[PPConfigManager getBGMVolume]];
    if ([[AudioManager defaultManager] isMusicOn]) {
        [[AudioManager defaultManager] backgroundMusicPlay];
    }
}

- (void)enterBBSWithPostId:(NSString*)postId
{
    [BBSPostDetailController enterPostDetailControllerWithPostID:postId
                                                  fromController:self
                                                        animated:YES];
}

- (void)enterContestWithContestId:(NSString*)contestId
{    
    __block Contest* contest = [[ContestManager defaultManager] ongoingContestById:contestId];
    if (contest == nil){
        return;
    }
    
    ContestOpusController* vc = [[ContestOpusController alloc] initWithContest:contest];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)enterLearnDrawTutorialId:(NSString*)tutorialId
{
    PBTutorial* pbTutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:tutorialId];
    if (pbTutorial == nil){
        return;
    }

    [TutorialInfoController show:(PPViewController*)self
                        tutorial:pbTutorial
                        infoOnly:NO];
    
}

- (void)enterHotByOpusClass:(NSString*)opusClassId
{
    OpusClassInfo* opusClassInfo = [[OpusClassInfoManager defaultManager] findOpusClassInfo:opusClassId];
    HotController* vc = [[HotController alloc] initWithOpusClass:opusClassInfo];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)openWebURL:(NSString*)url title:(NSString*)title
{
    TaoBaoController *controller = [[TaoBaoController alloc] initWithURL:url title:title];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)enterVIP
{
    [PurchaseVipController enter:(PPViewController*)self];
}

- (void)enterShopWithItemId:(NSString*)itemId
{
    
}

- (void)enterOfflineDrawWithMenu
{
    ChangeAvatar* imagePicker = [[ChangeAvatar alloc] init];
    imagePicker.autoRoundRect = NO;
    [imagePicker showSelectionView:self
                             title:NSLS(@"kDrawMode")
                       otherTitles:@[NSLS(@"kBlankDraw")]
                           handler:^(NSInteger index) {
                               
        if (index == 2) {
            // blank draw
            [self enterOfflineDraw];
        }
        else if(index == 3){
            // not used yet
        }
                               
       [imagePicker release];
                               
                               
    } selectImageHanlder:^(UIImage *image) {

        int MAX_WIDTH = 1024;
        int MAX_HEIGHT = 1024;
        
        if (image.size.width >= MAX_WIDTH || image.size.height >= MAX_HEIGHT){
            
            NSString* msg = [NSString stringWithFormat:NSLS(@"当前图片尺寸过大（%.0fX%.0f），请选择是否使用原始尺寸，使用原始尺寸性能可能受影响"),
                             image.size.width, image.size.height];
            
            // ask
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"图片尺寸过大")
                                                               message:msg
                                                                 style:CommonDialogStyleDoubleButtonWithCross];
            
            [dialog.oKButton setTitle:NSLS(@"原始尺寸") forState:UIControlStateNormal];
            [dialog.cancelButton setTitle:NSLS(@"优化尺寸") forState:UIControlStateNormal];
            
            [dialog setClickOkBlock:^(UIView *view){
                
                PPDebug(@"<startDrawOnPhoto> size big (%@)", NSStringFromCGSize(image.size));
                
                // enter with bg image
                [OfflineDrawViewController startDrawOnPhoto:self
                                                    bgImage:image];
            }];
            
            [dialog setClickCancelBlock:^(UIView *view){
                
                CGFloat newWidth = image.size.width;
                CGFloat newHeight = image.size.height;
                
                if (newWidth > MAX_WIDTH){
                    CGFloat ratio = MAX_WIDTH / newWidth;
                    newWidth = MAX_WIDTH;
                    newHeight = newHeight * ratio;
                }
                else{
                    CGFloat ratio = MAX_HEIGHT / newHeight;
                    newHeight = MAX_HEIGHT;
                    newWidth = newWidth * ratio;
                }
                
                CGSize newSize = CGSizeMake(newWidth, newHeight);
                PPDebug(@"<startDrawOnPhoto> from size (%@) to  size (%@)", NSStringFromCGSize(image.size), NSStringFromCGSize(newSize));
                UIImage* newImage = [image imageByScalingAndCroppingForSize:newSize];
                
                // enter with bg image
                [OfflineDrawViewController startDrawOnPhoto:self
                                                    bgImage:newImage];
            }];

            [dialog showInView:self.view];
        }
        else{
        
            // enter with bg image
            [OfflineDrawViewController startDrawOnPhoto:self
                                                bgImage:image];
        }
        
        [imagePicker release];
        
        
    } canTakePhoto:YES userOriginalImage:YES];
    return;
}

/*
- (void)enterOfflineDrawWithMenu
{
    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:@"请选择画画模式"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"取消"
                                                         destructiveButtonTitle:@"空白"
                                                              otherButtonTitles:@"选择背景图片", nil];
    
    [actionSheet setActionBlock:^(int buttonIndex){
        switch (buttonIndex) {
            case 0:
                [self enterOfflineDraw];
                break;
                
            case 1:
                [self enterOfflineDrawWithPhoto];
                break;

            case 2:
                // cancel
                break;
                
            default:
                break;
        }
    }];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}
*/

- (void)showGuidePage
{
    if ([[UserManager defaultManager] isOldUserWithoutXiaoji] || [[UserManager defaultManager] hasXiaojiNumber]){
        // has user, do nothing
        return;
    }

    [self performSelector:@selector(goToGuidePage) withObject:nil afterDelay:0.0];
}

- (void)enterTutorialTopOpus:(NSString*)tutorialId stageId:(NSString*)stageId title:(NSString*)title
{
    FeedListType feedListType = FeedListTypeConquerDrawStageTop;
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:tutorialId];
    if (tutorial && tutorial.topRankType > 0){
        feedListType = FeedListTypeConquerDrawStageTopHot;
    }
    
    FeedListController* vc = [[[FeedListController alloc] initWithFeedType:feedListType
                                                                  tutorialId:tutorialId //@"tutorialId-2"
                                                                     stageId:stageId    //@"stageId-0-0"
                                                                displayStyle:FEED_DISPLAY_PRIZE
                                                         superViewController:self
                                                                       title:title] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    return;
}


@end
