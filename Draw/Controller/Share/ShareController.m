//
//  ShareController.m
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareController.h"
#import "LocaleUtils.h"
#import "ShareEditController.h"
#import "MyPaint.h"
#import "DrawAction.h"
#import "ShareCell.h"
#import "UserManager.h"
#import "GifView.h"
#import "PPDebug.h"
#import "ShareImageManager.h"
#import "CommonDialog.h"
#import "PPConfigManager.h"
#import "FileUtil.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "OfflineDrawViewController.h"
#import "TableTab.h"
#import "TableTabManager.h"
#import "UIImageExt.h"
#import "DrawPlayer.h"
#import "GameSNSService.h"
#import "PurchaseVipController.h"

#define BUTTON_INDEX_OFFSET 20120229
#define IMAGE_WIDTH 93

#define IMAGE_OPTION            20120407
#define FROM_WEIXIN_OPTION      20130116

#define DREAM_AVATAR_OPTION     20130506
#define DREAM_LOCKSCREEN_OPTION 20130509

#define LOAD_PAINT_LIMIT 20


typedef enum{
    TabTypeMine = 100,
    TabTypeAll = 101,
    TabTypeDraft = 102,
}TabType;

@interface ShareController ()
{
    
    MyPaintManager *_myPaintManager;
    MyPaint *_selectedPaint;
    NSMutableArray *_gifImages;


}
@property (retain, nonatomic) IBOutlet MyPaint *selectedPaint;
//@property (retain, nonatomic) SaveToContactPickerView *saveToContactPickerView;
- (void)loadPaintsOnlyMine:(BOOL)onlyMine;
- (NSArray *)paints;
- (void)reloadView;
- (void)updateActionSheetIndexs;
- (BOOL)isMineTab;
- (BOOL)isAllTab;
- (BOOL)isDraftTab;
@end

@implementation ShareController
@synthesize clearButton;
@synthesize titleLabel;
@synthesize shareAction = _shareAction;
@synthesize awardCoinTips;
@synthesize backButton;
@synthesize selectedPaint = _selectedPaint;
@synthesize fromWeiXin = _fromWeiXin;

- (void)dealloc {
//    PPRelease(_titleView);
    self.shareAction = nil;
    PPRelease(_shareAction);
    PPRelease(_gifImages);
    PPRelease(_selectedPaint);
    PPRelease(clearButton);
    PPRelease(awardCoinTips);
    PPRelease(backButton);
//    PPRelease(_saveToContactPickerView);
    [super dealloc];
}


- (void)reloadView
{
    [self.dataTableView reloadData];
    if ([self.paints count] != 0) {
        self.awardCoinTips.text = @"";
        [self.clearButton setHidden:NO];
        [self.titleView showRightButton];
    }else{
        self.awardCoinTips.text = NSLS(@"kNoDrawings");
        [self.clearButton setHidden:YES];
        [self.titleView hideRightButton];
    }
}

- (void)updateTab:(NSArray *)paints
{
    if ([paints count] < self.currentTab.limit) {
        self.currentTab.hasMoreData = NO;
    }
    isLoading = NO;   
}

#pragma mark - MyPaintManager Delegate
- (void)didGetAllPaints:(NSArray *)paints
{
    [self finishLoadDataForTabID:TabTypeAll resultList:paints];
    
    [self hideActivity];
    [self reloadView];
    [self updateTab:paints];
}
- (void)didGetMyPaints:(NSArray *)paints
{
    [self finishLoadDataForTabID:TabTypeMine resultList:paints];
    
    [self hideActivity];
    [self reloadView];
    [self updateTab:paints];
}

- (void)didGetAllDrafts:(NSArray *)paints
{
    [self finishLoadDataForTabID:TabTypeDraft resultList:paints];
    
    [self hideActivity];
    [self reloadView];
    [self updateTab:paints];
}

- (void)didGetAllPaintCount:(NSInteger)allPaintCount
               myPaintCount:(NSInteger)myPaintCount
                 draftCount:(NSInteger)draftCount
{    
    [self setTab:TabTypeMine titleNumber:myPaintCount];
    [self setTab:TabTypeAll titleNumber:allPaintCount];
    [self setTab:TabTypeDraft titleNumber:draftCount];
}

- (void)performLoadMyPaints
{
    TableTab *tab = [_tabManager tabForID:TabTypeMine];
    [_myPaintManager findMyPaintsFrom:tab.offset limit:tab.limit delegate:self];
    [self hideActivity];
}

- (void)performLoadAllPaints
{
    TableTab *tab = [_tabManager tabForID:TabTypeAll];
    [_myPaintManager findAllPaintsFrom:tab.offset limit:tab.limit delegate:self];
    [self hideActivity];
}

- (void)loadPaintsOnlyMine:(BOOL)onlyMine
{
    [self showActivityWithText:NSLS(@"kLoading")];
    if (onlyMine) {
        [self performSelector:@selector(performLoadMyPaints) withObject:nil afterDelay:0.3f];
    } else {
        [self performSelector:@selector(performLoadAllPaints) withObject:nil afterDelay:0.3f];
    }
}

- (void)performLoadDrafts
{
    TableTab *tab = [_tabManager tabForID:TabTypeDraft];
    [_myPaintManager findAllDraftsFrom:tab.offset limit:tab.limit delegate:self];
    [self hideActivity];
}

// db.bulletin.insert({"date":new Date(), "type":0, "game_id":"Draw","function":"","content":"[公告] 近期发现部分用户反复使用草稿发同一幅作品，影响画榜。先明令禁止此种行为，发现一律直接删除，严重违反者直接封号"});

- (void)loadDrafts
{
//    TableTab *tab = [_tabManager tabForID:TabTypeDraft];
//    if (tab.status == TableTabStatusLoading) {
//        return;
//    }
    [self showActivityWithText:NSLS(@"kLoading")];
    [self performSelector:@selector(performLoadDrafts) withObject:nil afterDelay:0.3f];
}

//- (void)loadDrafts
//{
//    [self loadDraftsShouldShowLoading:YES];
//}

#define TITLE_RECOVERY        NSLS(@"kRecovery")
#define TITLE_EDIT            NSLS(@"kEdit")
#define TITLE_SAVE_TO_ALBUM   NSLS(@"kDreamAvatarSaveToAlbum")
#define TITLE_SAVE_TO_CONTACT NSLS(@"kDreamAvatarSaveToContact")
#define TITLE_DELETE          NSLS(@"kDelete")

#define DREAM_AVATAR_TITLES  TITLE_SAVE_TO_ALBUM, TITLE_SAVE_TO_CONTACT, TITLE_DELETE, nil
- (void)didSelectPaintInDreamAvatar
{
    NSString* editString = ([[self.selectedPaint isRecovery] boolValue]? TITLE_RECOVERY : TITLE_EDIT);
    
    UIActionSheet *sheet;
    if (self.isDraftTab) {
        sheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                                           delegate:self
                                                  cancelButtonTitle:NSLS(@"kCancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:editString, DREAM_AVATAR_TITLES];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                                           delegate:self
                                                  cancelButtonTitle:NSLS(@"kCancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:DREAM_AVATAR_TITLES];
    }

    sheet.tag = DREAM_AVATAR_OPTION;
    [sheet showInView:self.view];
    [sheet release];
}

- (void)didSelectPaintInDreamLockscreen
{    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                                       delegate:self
                                              cancelButtonTitle:NSLS(@"kCancel")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:TITLE_SAVE_TO_ALBUM, TITLE_DELETE, nil];
    sheet.tag = DREAM_LOCKSCREEN_OPTION;
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark - Share Cell Delegate
- (void)didSelectPaint:(MyPaint *)paint
{
    
    if (self.isFromWeiXin) {
        WXMediaMessage *message = [WXMediaMessage message];
        [message setThumbImage:paint.thumbImage];
        WXImageObject *ext = [WXImageObject object];
        message.title = [NSString stringWithFormat:NSLS(@"kWXShareImageName"), [UIUtils getAppName]];
        ext.imageData = [paint.paintImage data] ;
        message.mediaObject = ext;
        
        GetMessageFromWXResp* resp = [[[GetMessageFromWXResp alloc] init] autorelease];
        resp.message = message;
        resp.bText = NO;
        BOOL flag = [WXApi sendResp:resp];
        if (flag) {
            [self.navigationController popViewControllerAnimated:NO];
        }
        paint.paintImage = nil;
        return;
    }
    self.selectedPaint = paint;
    
    /*
    if (isDreamAvatarApp() || isDreamAvatarFreeApp()) {
        [self didSelectPaintInDreamAvatar];
        return;
    } else if (isDreamLockscreenApp() || isDreamLockscreenFreeApp()){
        [self didSelectPaintInDreamLockscreen];
        return;
    }
    */
    
    UIActionSheet* tips = nil;
    
    NSString* editString = [[self.selectedPaint isRecovery] boolValue]?NSLS(@"kRecovery"):NSLS(@"kEdit");
    
    
        if (self.isDraftTab) {
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                               delegate:self 
                                      cancelButtonTitle:NSLS(@"kCancel") 
                                 destructiveButtonTitle:editString 
                                      otherButtonTitles:NSLS(@"kReplay"), NSLS(@"kDelete"),
                    NSLS(@"kSaveAsPhoto"), NSLS(@"kShareSinaWeibo"),  // NSLS(@"kShareQQSpace"),
                    NSLS(@"kShareWeixinSession"), NSLS(@"kShareWeixinTimeline"),
                    NSLS(@"kShareQQWeibo"), NSLS(@"kShareFacebook"),
                    nil];
        }else{
//#if DEBUG
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                               delegate:self
                                      cancelButtonTitle:NSLS(@"kCancel")
                                 destructiveButtonTitle:NSLS(@"kReplay")
                                      otherButtonTitles:
                     NSLS(@"kDelete"), NSLS(@"kEdit"),
                    NSLS(@"kSaveAsPhoto"), NSLS(@"kShareSinaWeibo"),  // NSLS(@"kShareQQSpace"),
                    NSLS(@"kShareWeixinSession"), NSLS(@"kShareWeixinTimeline"),
                    NSLS(@"kShareQQWeibo"), NSLS(@"kShareFacebook"),

                    nil];
            
//#else
//            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
//                                                          delegate:self 
//                                                 cancelButtonTitle:NSLS(@"kCancel") 
//                                            destructiveButtonTitle:NSLS(@"kReplay") 
//                                                 otherButtonTitles:
//                                                         NSLS(@"kDelete"),
//                    NSLS(@"kSaveAsPhoto"), NSLS(@"kShareSinaWeibo"),  // NSLS(@"kShareQQSpace"),
//                    NSLS(@"kShareWeixinSession"), NSLS(@"kShareWeixinTimeline"),
//                    NSLS(@"kShareQQWeibo"), NSLS(@"kShareFacebook"),
//
//                    nil];
//#endif
        }

    tips.tag = IMAGE_OPTION;
    [tips showInView:self.view];
    [tips release];
    
}

#pragma mark - UIActionSheetDelegate

- (void)showViewController:(UIViewController*)controller
{
    [self.navigationController presentModalViewController:controller animated:YES];
}



#pragma mark - offline draw delegate
- (void)didControllerClickBack:(OfflineDrawViewController *)controller
{
    ShowMessageFromWXResp* resp = [[[ShowMessageFromWXResp alloc] init] autorelease];
    [WXApi sendResp:resp];
    [self.navigationController popToRootViewControllerAnimated:NO];
    return;
}
- (void)didController:(OfflineDrawViewController *)controller
     submitActionList:(NSMutableArray*)drawActionList
           canvasSize:(CGSize)size
            drawImage:(UIImage *)drawImage
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:drawImage];
    WXImageObject *ext = [WXImageObject object];
    message.title = [NSString stringWithFormat:NSLS(@"kWXShareImageName"), [UIUtils getAppName]];
    ext.imageData = [drawImage data] ;
    message.mediaObject = ext;
    
    GetMessageFromWXResp* resp = [[[GetMessageFromWXResp alloc] init] autorelease];
    resp.message = message;
    resp.bText = NO;
    BOOL flag = [WXApi sendResp:resp];
    if (flag) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    return;
}

- (void)weixinActionSheet:(UIActionSheet *)actionSheet
     clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case FromWeixinOptionShareOpus: {
        } break;
        case FromWeixinOptionDrawAPicture: {
            OfflineDrawViewController *odc = [[OfflineDrawViewController alloc] initWithTargetType:TypeGraffiti delegate:self];
            odc.startController = self;
            [self.navigationController pushViewController:odc animated:YES];
            [odc release];
        } break;
        default:
            break;
    }
}

- (void)performReplay
{
    [self performLoadOpus:@selector(gotoReplayView)];
    return;
}

- (void)gotoReplayView
{    
    MyPaint* currentPaint = _selectedPaint;
    
    BOOL isNewVersion = [PPConfigManager currentDrawDataVersion] < [currentPaint drawDataVersion];
    
    ReplayObject *obj = [ReplayObject obj];
    obj.actionList = [currentPaint drawActionList];
    obj.isNewVersion = isNewVersion;
    obj.bgImage = [[MyPaintManager defaultManager] bgImageForPaint:currentPaint];
    obj.layers = currentPaint.layers;
    obj.canvasSize = [currentPaint canvasSize];
    
    DrawPlayer *player =[DrawPlayer playerWithReplayObj:obj];
    [player showInController:self];
}

- (void)gotoEditConroller
{
    MyPaint* currentPaint = _selectedPaint;    
    
    [UIApplication sharedApplication].idleTimerDisabled = YES; // disable lock screen while in drawing
    
    OfflineDrawViewController *od = [[OfflineDrawViewController alloc] initWithDraft:currentPaint];
    od.startController = self;
    [self.navigationController pushViewController:od animated:YES];
    [od release];
   
}

- (void)performLoadOpus:(SEL)selector
{
    MyPaint* currentPaint = _selectedPaint;
    
    [self registerNotificationWithName:NOTIFICATION_DATA_PARSING usingBlock:^(NSNotification *note) {
        float progress = [[[note userInfo] objectForKey:KEY_DATA_PARSING_PROGRESS] floatValue];
        //        PPDebug(@"handle data parsing notification, progress = %f", progress);
        NSString* progressText = @"";
        if (progress == 1.0f){
            progress = 0.99f;
            progressText = [NSString stringWithFormat:NSLS(@"kDisplayProgress"), progress*100];
        }
        else{
            progressText = [NSString stringWithFormat:NSLS(@"kParsingProgress"), progress*100];
        }
        [self showProgressViewWithMessage:progressText progress:progress];
    }];
    
    dispatch_async(workingQueue, ^{
        
        [currentPaint drawActionList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self performSelector:selector];
            
            [self hideActivity];
            [self unregisterNotificationWithName:KEY_DATA_PARSING_PROGRESS];
            
            // clear draw action list
            currentPaint.drawActionList = nil;
        });
    });
}

- (void)performEdit
{
    [self performLoadOpus:@selector(gotoEditConroller)];
    return;
}

- (void)share:(PPSNSType)type
{
    MyPaint* currentPaint = _selectedPaint;    
    
    NSString* text = [ShareAction createShareText:currentPaint.drawWord
                                             desc:nil
                                       opusUserId:currentPaint.drawUserId
                                       userGender:[UserManager defaultManager].pbUser.gender
                                          snsType:type
                                           opusId:nil];
    
    [[GameSNSService defaultService] publishWeibo:type
                                             text:text
                                    imageFilePath:currentPaint.imageFilePath
                                           inView:self.view
                                       awardCoins:[PPConfigManager getShareWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")];
    
}

- (void)imageActionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MyPaint* currentPaint = _selectedPaint;
    
    if (buttonIndex == SHARE_AS_PHOTO) {
        
        if (![GameApp canShareViaSNS]) {
            
            [self showActivityWithText:NSLS(@"kSaving")];
            [[MyPaintManager defaultManager] savePhoto:currentPaint.imageFilePath delegate:nil];
            [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.5];
            
        }else{
            self.shareAction = [[[ShareAction alloc]
                                 initWithDrawImageFile:currentPaint.imageFilePath
                                 isGIF:NO
                                 drawWord:currentPaint.drawWord
                                 drawUserId:currentPaint.drawUserId] autorelease];
            
            [_shareAction displayWithViewController:self];
        }
    }
    else if (buttonIndex == REPLAY){
        [self showActivityWithText:NSLS(@"kLoading")];
        [self performSelector:@selector(performReplay) withObject:nil afterDelay:0.1f];
    }
    else if (buttonIndex ==  DELETE) {
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete")
                                                           message:NSLS(@"kAre_you_sure")
                                                             style:CommonDialogStyleDoubleButton
                                                          delegate:self];
        
        dialog.tag = DELETE;
        
        [dialog showInView:self.view];
    }
    else if (buttonIndex == SAVE_INTO_PHOTO){
        [self saveAlbum];
    }
    else if (buttonIndex == SHARE_SINA_WEIBO){
        [self share:TYPE_SINA];
    }
    else if (buttonIndex == SHARE_QQ_ZONE){
        [self share:TYPE_QQSPACE];
    }
    else if (buttonIndex == SHARE_WEIXIN_SESSION){
        [self share:TYPE_WEIXIN_SESSION];
    }
    else if (buttonIndex == SHARE_WEIXIN_TIMELINE){
        [self share:TYPE_WEIXIN_TIMELINE];
    }
    else if (buttonIndex == SHARE_QQ_WEIBO){
        [self share:TYPE_QQ];
    }
    else if (buttonIndex == SHARE_FACEBOOK){
        [self share:TYPE_FACEBOOK];
    }
    else if (buttonIndex == DELETE_ALL){
        
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete")
                                                           message:NSLS(@"kAre_you_sure")
                                                             style:CommonDialogStyleDoubleButton
                                                          delegate:self];
        dialog.tag = DELETE_ALL;
        [dialog showInView:self.view];
    }else if(buttonIndex == EDIT){
        if ([[UserManager defaultManager] isSuperUser] == NO && self.currentTab.tabID == TabTypeAll){
            POSTMSG(NSLS(@"kCannotEditThisTab"));
            return;
        }
        else if (self.currentTab.tabID == TabTypeMine){
            // VIP only
            if ([[UserManager defaultManager] isVip] == NO){
                CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotVip") message:NSLS(@"kEditDraftButNotVip") style:CommonDialogStyleDoubleButton];
                [dialog setClickOkBlock:^(id view){
                    [PurchaseVipController enter:self];
                }];
                [dialog showInView:self.view];
                return;
            }
            else{
                // change state to draft
                [self.selectedPaint setDraft:@(1)];
                [self.selectedPaint setCreateDate:[NSDate date]];
                [[MyPaintManager defaultManager] save];
            }
        }

        [self showActivityWithText:NSLS(@"kLoading")];
        [self performSelector:@selector(performEdit) withObject:nil afterDelay:0.1f];
    }
}

- (void)dreamAvatarActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:TITLE_RECOVERY] ||
        [buttonTitle isEqualToString:TITLE_EDIT]) {
        [self showActivityWithText:NSLS(@"kLoading")];
        [self performSelector:@selector(performEdit) withObject:nil afterDelay:0.1f];
        
    } else if ([buttonTitle isEqualToString:TITLE_SAVE_TO_ALBUM]) {
        [self showActivityWithText:NSLS(@"kSaving")];
        [[MyPaintManager defaultManager] savePhoto:_selectedPaint.imageFilePath delegate:nil];
        [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.5];
        
    } else if ([buttonTitle isEqualToString:TITLE_DELETE]) {
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete")
                                                           message:NSLS(@"kAre_you_sure")
                                                             style:CommonDialogStyleDoubleButton
                                                          delegate:self];
        
        dialog.tag = DELETE;
        
        [dialog showInView:self.view];
    }
}


- (void)dreamLockscreenActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:TITLE_SAVE_TO_ALBUM]) {
        [self showActivityWithText:NSLS(@"kSaving")];
        [[MyPaintManager defaultManager] savePhoto:_selectedPaint.imageFilePath delegate:nil];
        [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.5];
        
    } else if ([buttonTitle isEqualToString:TITLE_DELETE]) {
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete")
                                                           message:NSLS(@"kAre_you_sure")
                                                             style:CommonDialogStyleDoubleButton
                                                          delegate:self];
        
        dialog.tag = DELETE;
        [dialog showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (actionSheet.tag == FROM_WEIXIN_OPTION) {
        [self weixinActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    if (actionSheet.tag == IMAGE_OPTION) {
        [self imageActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    if (actionSheet.tag == DREAM_AVATAR_OPTION) {
        [self dreamAvatarActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
    if (actionSheet.tag == DREAM_LOCKSCREEN_OPTION) {
        [self dreamLockscreenActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}


#pragma mark - Common Dialog Delegate
- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView
{
    
    TableTab *myTab = [_tabManager tabForID:TabTypeMine];
    TableTab *allTab = [_tabManager tabForID:TabTypeAll];
    TableTab *draftTab = [_tabManager tabForID:TabTypeDraft];
    
    MyPaint* currentPaint = self.selectedPaint;
    self.selectedPaint = nil;
    if (dialog.tag == DELETE){

        if (currentPaint == nil) {
            return;
        }
        if (currentPaint.draft.boolValue) {
            draftTab.offset -- ;
            [draftTab.dataList removeObject:currentPaint];
        }else{        
            if (currentPaint.drawByMe.boolValue) {
                myTab.offset -- ;
                [myTab.dataList removeObject:currentPaint];
            }       
            if ([allTab.dataList containsObject:currentPaint]) {
                allTab.offset --;
                [allTab.dataList removeObject:currentPaint];
            }
        }
        [[MyPaintManager defaultManager] deleteMyPaint:currentPaint];
        self.selectedPaint = nil;
    }
    else if (dialog.tag == DELETE_ALL){
        myTab.offset = allTab.offset = 0;
        [allTab.dataList removeAllObjects];
        [myTab.dataList removeAllObjects];
        [[MyPaintManager defaultManager] deleteAllPaints:NO];
        [self loadPaintsOnlyMine:NO];
    } else if (dialog.tag == DELETE_ALL_MINE) {
        myTab.offset = allTab.offset = 0;
        [allTab.dataList removeAllObjects];
        [myTab.dataList removeAllObjects];
        [[MyPaintManager defaultManager] deleteAllPaints:YES];
        [self loadPaintsOnlyMine:NO];
    }else if(dialog.tag == DELETE_ALL_DRAFT)
    {
        draftTab.offset = 0;
        [draftTab.dataList removeAllObjects];
        [[MyPaintManager defaultManager] deleteAllDrafts];
        [self loadDrafts];
    }
    [self reloadView];
}

#pragma mark - table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ShareCell getCellHeight];
        
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number = 0;
    if (self.paints.count % IMAGES_PER_LINE == 0){
        number = self.paints.count / IMAGES_PER_LINE;
    }
    else{
        number = self.paints.count / IMAGES_PER_LINE + 1;
    }
    return number;
}

- (NSArray *)paints
{
    return [self tabDataList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareCell* cell = [tableView dequeueReusableCellWithIdentifier:[ShareCell getIdentifier]];
    if (cell == nil) {
        cell = [ShareCell creatShareCellWithIndexPath:indexPath delegate:self];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSMutableArray* myPaintArray = [NSMutableArray array];

    NSAutoreleasePool* loopPool = [[NSAutoreleasePool alloc] init];
    for (int lineIndex = 0; lineIndex < IMAGES_PER_LINE; lineIndex++) {
        int paintIndex = indexPath.row*IMAGES_PER_LINE + lineIndex;
        if (paintIndex < self.paints.count) {
            MyPaint* paint  = [self.paints objectAtIndex:paintIndex]; 
            [myPaintArray addObject:paint];                
        }
    }
    [loopPool release];

    cell.indexPath = indexPath;
    [cell setPaints:myPaintArray];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    int number = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (row == number - 1) {
        TableTab *tab = self.currentTab;
        if (!isLoading && tab.hasMoreData && tab.status != TableTabStatusLoading) {
            [self serviceLoadDataForTabID:tab.tabID];
        }
    }
}


- (IBAction)deleteAll:(id)sender
{
    [self clickClearButton:sender];    
}

- (IBAction)clickClearButton:(id)sender
{
    if (self.isFromWeiXin) {
        
        ShowMessageFromWXResp* resp = [[[ShowMessageFromWXResp alloc] init] autorelease];
        [WXApi sendResp:resp];
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAttention")
                                                       message:NSLS(@"kDeleteAllWarning")
                                                         style:CommonDialogStyleDoubleButton
                                                      delegate:self];
    if ([self isMineTab]) {
        dialog.tag = DELETE_ALL_MINE;
    } else if([self isDraftTab]){
        dialog.tag = DELETE_ALL_DRAFT;
    }else{
        dialog.tag = DELETE_ALL;
    }
    [dialog showInView:self.view];
}

-(IBAction)clickBackButton:(id)sender
{
    self.shareAction = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isMineTab
{
    return self.currentTab.tabID == TabTypeMine;
}
- (BOOL)isAllTab
{
    return self.currentTab.tabID == TabTypeAll;    
}
- (BOOL)isDraftTab
{
    return self.currentTab.tabID == TabTypeDraft;
}


- (void)updateActionSheetIndexs
{
    SHARE_QQ_ZONE = -1;
    
    int index = 0;
    if (self.isDraftTab) {
        EDIT  = index++;
    }else{
        EDIT = -1;
    }
    
    SHARE_AS_PHOTO = -1;
    
    REPLAY = index++;
    DELETE = index++;
    
    if (![self isDraftTab]) {
        EDIT = index++;
    }
    
//#if DEBUG
//    if (![self isDraftTab]) {
//        // for super admin test
//        EDIT = index++;
//    }
//#endif
    
    SAVE_INTO_PHOTO = index++;
    SHARE_SINA_WEIBO = index++;
//    SHARE_QQ_ZONE = index++;
    SHARE_WEIXIN_SESSION = index++;
    SHARE_WEIXIN_TIMELINE = index++;
    SHARE_QQ_WEIBO = index++;
    SHARE_FACEBOOK = index++;
    
    DELETE_ALL = index++;
    DELETE_ALL_MINE = index++;
    DELETE_ALL_DRAFT = index++;
    CANCEL = index++;        
    
}


- (id)init
{
    self = [super init];
    if (self) {
        _defaultTabIndex = 2;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self setFromWeiXin:NO];
        
        _gifImages = [[NSMutableArray alloc] init];

        _myPaintManager = [MyPaintManager defaultManager];
    }
    return self;
}

- (void)showChooseWeixinOptionActionSheet
{
    UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:NSLS(@"kChoseWeixinOption")
                                                        delegate:self
                                               cancelButtonTitle:NSLS(@"kCancel")
                                          destructiveButtonTitle:NSLS(@"kShareOpus") otherButtonTitles:NSLS(@"kDrawAPicture"), nil] autorelease];
    sheet.tag = FROM_WEIXIN_OPTION;
    [sheet showInView:self.view];
}

- (void)initTabButtons
{
    [super initTabButtons];
    [[MyPaintManager defaultManager] countAllPaintsAndDrafts:self];
    if ([GameApp showPaintCategory] == NO){
        UIButton *mineButton = (UIButton *)[self.view viewWithTag:TabTypeMine];
        UIButton *allButton = (UIButton *)[self.view viewWithTag:TabTypeAll];
        UIButton *draftButton = (UIButton *)[self.view viewWithTag:TabTypeDraft];
        mineButton.hidden = YES;
        allButton.hidden = YES;
        draftButton.hidden = YES;
        
        [self.dataTableView updateOriginY:self.dataTableView.frame.origin.y - mineButton.frame.size.height];
        [self.dataTableView updateHeight:self.dataTableView.frame.size.height + mineButton.frame.size.height];
    }

}


- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeNone];
    [super viewDidLoad]; 

    [self initTabButtons];
    UIButton *allButton = [self tabButtonWithTabID:TabTypeAll];
    

    if (self.isFromWeiXin) {
        [self.clearButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];        
        self.backButton.hidden = YES;
        self.awardCoinTips.hidden = YES;
        self.titleLabel.text = NSLS(@"kShareToWeiXinTitle");

        [self.titleView setTitle:NSLS(@"kShareToWeiXinTitle")];
        [self.titleView setRightButtonTitle:NSLS(@"kCancel")];
        [self.titleView hideBackButton];
        
        //update the table view frame
        CGFloat x = self.dataTableView.frame.origin.x;
        CGFloat y = self.dataTableView.frame.origin.y;
        CGFloat width = self.dataTableView.frame.size.width;
        CGFloat height = self.dataTableView.frame.size.height;
        CGFloat ny = allButton.frame.origin.y  + allButton.frame.size.height * 1.2 ;
        CGFloat nHeight = height + (y - ny);
        
        [self.dataTableView setFrame:CGRectMake(x, ny, width, nHeight)];
        
        [self showChooseWeixinOptionActionSheet];
    }else{
        [self.clearButton setTitle:NSLS(@"kClear") forState:UIControlStateNormal];
        self.titleLabel.text = NSLS(@"kShareTitle");
        
        [self.titleView setTitle:NSLS(@"kShareTitle")];
        [self.titleView setRightButtonTitle:NSLS(@"kClear")];
    }
    
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self.titleView setRightButtonSelector:@selector(clickClearButton:)];

    SET_COMMON_TAB_TABLE_VIEW_Y(self.dataTableView);
    CGFloat height = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(self.dataTableView.frame);
    [self.dataTableView updateHeight:height];

}

- (void)viewDidUnload
{
    [self setClearButton:nil];
    [self setTitleLabel:nil];
    [self setAwardCoinTips:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self clickRefreshButton:nil];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_tabManager reset];
    [self.dataTableView reloadData];
}

#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 3;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 32;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {TabTypeMine,TabTypeAll,TabTypeDraft};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
//    NSString *tabDesc[] = {NSLS(@"kNoMyFeed"),NSLS(@"kNoMyOpus"),NSLS(@"kNoMyComment"),NSLS(@"kNoDrawToMe")};
    
    return NSLS(@"NoData");
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kMine"),NSLS(@"kAll"),NSLS(@"kDraft")};
    return tabTitle[index];
    
}

- (void)clickTabButton:(id)sender
{
    [super clickTabButton:sender];
    [self updateActionSheetIndexs];
    [self reloadView];
}


- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self reloadView];
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        isLoading = YES;
        switch (tabID) {
            case TabTypeMine:
                [self loadPaintsOnlyMine:YES];
                break;
            case TabTypeAll:
            {
                [self loadPaintsOnlyMine:NO];
                break;
            }
                
            case TabTypeDraft: //for test
            {
                [self loadDrafts];
                break;
            }
            default:
                
                [self hideActivity];
                break;
        }
        
    }
}

+ (void)shareFromWeiXin:(UIViewController *)superController
{
    ShareController* share = [[[ShareController alloc] init ] autorelease];
    [share setFromWeiXin:YES];
    [superController.navigationController pushViewController:share animated:YES];
}

- (void)saveAlbum
{
    [self showActivityWithText:NSLS(@"kSaving")];
    [[MyPaintManager defaultManager] savePhoto:_selectedPaint.imageFilePath delegate:self];
}

#pragma mark - MyPaintManager delegate
    
- (void)didSaveToAlbumSuccess:(BOOL)succ
{
    [self hideActivity];
    if (succ) {
        POSTMSG(NSLS(@"kSaveToAlbumSuccess"));
    }
}
    
@end
