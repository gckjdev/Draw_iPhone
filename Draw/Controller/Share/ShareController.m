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
#import "ReplayController.h"
#import "GifView.h"
#import "PPDebug.h"
#import "ShareImageManager.h"
#import "CommonDialog.h"
#import "ConfigManager.h"
#import "FileUtil.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "OfflineDrawViewController.h"


#define BUTTON_INDEX_OFFSET 20120229
#define IMAGE_WIDTH 93

#define IMAGE_OPTION            20120407
#define SHARE_IMAGE_OPTION      120120407
#define SHARE_AS_PHOTO_OPTION   220120407

#define LOAD_PAINT_LIMIT 32

@interface ShareController ()
{
    NSMutableArray *_allPaints;
    NSMutableArray *_myPaints;
    NSMutableArray *_drafts;
    
    
    NSInteger _allOffset;
    NSInteger _myOffset;
    NSInteger _draftOffset;
    
    BOOL _allHasMoreData;
    BOOL _myHasMoreData;
    BOOL _drafHaseMoreData;
    
    MyPaintManager *_myPaintManager;
    MyPaint *_selectedPaint;
    NSMutableArray *_gifImages;


}
@property (retain, nonatomic) IBOutlet MyPaint *selectedPaint;
- (void)loadPaintsOnlyMine:(BOOL)onlyMine;
- (NSArray *)paints;
- (void)reloadView;
- (void)updateActionSheetIndexs;
@end

@implementation ShareController
@synthesize selectDraftButton;
@synthesize selectMineButton;
@synthesize selectAllButton;
@synthesize clearButton;
@synthesize titleLabel;
@synthesize shareAction = _shareAction;
@synthesize awardCoinTips;
@synthesize backButton;
@synthesize selectedPaint = _selectedPaint;
@synthesize fromWeiXin = _fromWeiXin;

- (void)dealloc {
    PPRelease(_shareAction);
    PPRelease(_myPaints);
    PPRelease(_allPaints);
    PPRelease(_gifImages);
    PPRelease(_selectedPaint);
    PPRelease(clearButton);
    PPRelease(titleLabel);
    PPRelease(selectAllButton);
    PPRelease(selectMineButton);
    PPRelease(selectDraftButton);
    PPRelease(awardCoinTips);
    PPRelease(backButton);

    [super dealloc];
}


- (void)reloadView
{
    [self.dataTableView reloadData];
    if ([self.paints count] != 0) {
        self.awardCoinTips.text = [NSString stringWithFormat:NSLS(@"kShareAwardCoinTips"),[ConfigManager getShareWeiboReward]];
        [self.clearButton setHidden:NO];
    }else{
        self.awardCoinTips.text = NSLS(@"kNoDrawings");
        [self.clearButton setHidden:YES];
    }
}

#pragma mark - MyPaintManager Delegate
- (void)didGetAllPaints:(NSArray *)paints
{
    [self hideActivity];
    if ([paints count] > 0) {
        
        if (_allPaints == nil) {
            _allPaints = [[NSMutableArray alloc] initWithArray:paints];
        }else{            
            [_allPaints addObjectsFromArray:paints];
        }        
        _allOffset += [paints count];
        if ([paints count] == LOAD_PAINT_LIMIT) {
            _allHasMoreData = YES;
        }else{
            _allHasMoreData = NO;
        }
    }
    if (self.selectAllButton.selected) {
        [self reloadView];
    }
}
- (void)didGetMyPaints:(NSArray *)paints
{
    [self hideActivity];
    if ([paints count] > 0) {
        if (_myPaints == nil) {
            _myPaints = [[NSMutableArray alloc] initWithArray:paints];
        }else{
            [_myPaints addObjectsFromArray:paints];
        }        
        _myOffset += [paints count];
        if ([paints count] == LOAD_PAINT_LIMIT) {
            _myHasMoreData = YES;
        }else{
            _myHasMoreData = NO;
        }
    }
    if (self.selectMineButton.selected) {
        [self reloadView];
    }
}

- (void)didGetAllDrafts:(NSArray *)paints
{
    [self hideActivity];
    if ([paints count] > 0) {
        if (_drafts == nil) {
            _drafts = [[NSMutableArray alloc] initWithArray:paints];
        }else{
            [_drafts addObjectsFromArray:paints];
        }        
        _draftOffset += [paints count];
        if ([paints count] == LOAD_PAINT_LIMIT) {
            _drafHaseMoreData = YES;
        }else{
            _drafHaseMoreData = NO;
        }
    }
    if (self.selectDraftButton.selected) {
        [self reloadView];
    }
    
}

- (void)performLoadMyPaints
{
    [_myPaintManager findMyPaintsFrom:_myOffset limit:LOAD_PAINT_LIMIT delegate:self];
}

- (void)performLoadAllPaints
{
    [_myPaintManager findAllPaintsFrom:_allOffset limit:LOAD_PAINT_LIMIT delegate:self];
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
    [_myPaintManager findAllDraftsFrom:_draftOffset limit:LOAD_PAINT_LIMIT delegate:self];
}

- (void)loadDrafts
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [self performSelector:@selector(performLoadDrafts) withObject:nil afterDelay:0.3f];
}


#pragma mark - Share Cell Delegate
- (void)didSelectPaint:(MyPaint *)paint
{
    
    if (self.isFromWeiXin) {
        WXMediaMessage *message = [WXMediaMessage message];
        [message setThumbImage:paint.thumbImage];
        WXImageObject *ext = [WXImageObject object];
        message.title = NSLS(@"kWXShareImageName");
        NSString* filePath = [MyPaintManager getMyPaintImagePathByCapacityPath:paint.image];
        ext.imageData = [NSData dataWithContentsOfFile:filePath] ;
        message.mediaObject = ext;
        
        GetMessageFromWXResp* resp = [[[GetMessageFromWXResp alloc] init] autorelease];
        resp.message = message;
        resp.bText = NO;
        BOOL flag = [WXApi sendResp:resp];
        if (flag) {
            [self.navigationController popViewControllerAnimated:NO];
        }
        return;
    }
    self.selectedPaint = paint;
    UIActionSheet* tips = nil;
    
    if ([LocaleUtils isChina]){
        
        if (self.selectDraftButton.selected) {
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                               delegate:self 
                                      cancelButtonTitle:NSLS(@"kCancel") 
                                 destructiveButtonTitle:NSLS(@"kEdit") 
                                      otherButtonTitles:NSLS(@"kShareAsPhoto"),
                    NSLS(@"kShareAsGif"),NSLS(@"kReplay"), NSLS(@"kDelete"), nil];            
        }else{        
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                                          delegate:self 
                                                 cancelButtonTitle:NSLS(@"kCancel") 
                                            destructiveButtonTitle:NSLS(@"kShareAsPhoto") 
                                                 otherButtonTitles:NSLS(@"kShareAsGif"),
                                                        NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
        }
    }
    else{
        if (self.selectDraftButton.selected) {
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                               delegate:self 
                                      cancelButtonTitle:NSLS(@"kCancel") 
                                 destructiveButtonTitle:NSLS(@"kEdit") 
                                      otherButtonTitles:NSLS(@"kShareAsPhoto"),
                    NSLS(@"kReplay"), NSLS(@"kDelete"), nil];            
        }else{           
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                               delegate:self 
                                      cancelButtonTitle:NSLS(@"kCancel") 
                                 destructiveButtonTitle:NSLS(@"kShareAsPhoto") 
                                      otherButtonTitles:NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
        }
        
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


#define SHARE_GIF_DRAW_VIEW_TAG 20120409
- (void)shareAsGif
{
    [_gifImages removeAllObjects];
    
    MyPaint* currentPaint = _selectedPaint;
    ReplayController* replayController = [[ReplayController alloc] initWithPaint:currentPaint];
    [replayController setReplayForCreateGif:YES];    
    [self.navigationController pushViewController:replayController animated:YES];
    [replayController release];        
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    MyPaint* currentPaint = _selectedPaint;
    
    if (buttonIndex == SHARE_AS_PHOTO) {                        
        self.shareAction = [[[ShareAction alloc] initWithDrawImageFile:currentPaint.image 
                                                                 isGIF:NO
                                                             drawWord:currentPaint.drawWord
                                                                 drawUserId:currentPaint.drawUserId] autorelease];
            
        [_shareAction displayWithViewController:self];                       
    }                            
    else if (buttonIndex == SHARE_AS_GIF)
    {
        [self shareAsGif];
    }
    else if (buttonIndex == REPLAY){                                        
        ReplayController* replayController = [[ReplayController alloc] initWithPaint:currentPaint];
        [self.navigationController pushViewController:replayController animated:YES];
        [replayController release];            
    }
    else if (buttonIndex ==  DELETE) {
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete") 
                                                           message:NSLS(@"kAre_you_sure") 
                                                             style:CommonDialogStyleDoubleButton 
                                                         delegate:self];  
        
        dialog.tag = DELETE;
        
        [dialog showInView:self.view];
    }
    else if (buttonIndex == DELETE_ALL){
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete") 
                                                           message:NSLS(@"kAre_you_sure") 
                                                             style:CommonDialogStyleDoubleButton 
                                                         delegate:self];            
        dialog.tag = DELETE_ALL;
        [dialog showInView:self.view];        
    }else if(buttonIndex == EDIT && currentPaint.draft.boolValue){
        OfflineDrawViewController *od = [[OfflineDrawViewController alloc] initWithDraft:currentPaint];
        [self.navigationController pushViewController:od animated:YES];
        [od release];
    }
    
}


#pragma mark - Common Dialog Delegate
- (void)clickOk:(CommonDialog *)dialog
{
    
    MyPaint* currentPaint = self.selectedPaint;
//    self.selectedPaint = nil;
    if (dialog.tag == DELETE){

        if (currentPaint == nil) {
            return;
        }

        if (currentPaint.draft.boolValue) {
            _draftOffset --;
            [_drafts removeObject:currentPaint];
        }else{        
            if (currentPaint.drawByMe.boolValue) {
                _myOffset --;
                [_myPaints removeObject:currentPaint];
            }       
            if ([_allPaints containsObject:currentPaint]) {
                _allOffset --;
                [_allPaints removeObject:currentPaint];
            }
        }
        [[MyPaintManager defaultManager] deleteMyPaint:currentPaint];
        self.selectedPaint = nil;
    }
    else if (dialog.tag == DELETE_ALL){
        _allOffset = 0;
        _myOffset = 0;
        [_allPaints removeAllObjects];
        [_myPaints removeAllObjects];
        [[MyPaintManager defaultManager] deleteAllPaints:NO];
        [self loadPaintsOnlyMine:NO];
        
    } else if (dialog.tag == DELETE_ALL_MINE) {
        _allOffset = 0;
        _myOffset = 0;
        [_allPaints removeAllObjects];
        [_myPaints removeAllObjects];
        [[MyPaintManager defaultManager] deleteAllPaints:YES];
        [self loadPaintsOnlyMine:NO];
    }else if(dialog.tag == DELETE_ALL_DRAFT)
    {
        _draftOffset = 0;
        [_drafts removeAllObjects];
        [[MyPaintManager defaultManager] deleteAllDrafts];
        [self loadDrafts];
    }
    [self reloadView];
}

- (void)clickBack:(CommonDialog *)dialog
{
    
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
    if ([DeviceDetection isIPAD]) {
        return 180;
    } else {
        return 90;
    }
        
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
    if (self.selectAllButton.selected) {
        return _allPaints;
    }else if(self.selectMineButton.selected){
        return _myPaints;
    }else{
        return _drafts;
    }
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
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    int number = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (row == number - 1) {
        if (self.selectAllButton.selected && _allHasMoreData) {
            [self loadPaintsOnlyMine:NO];            
        }else if(self.selectMineButton.selected && _myHasMoreData){
            [self loadPaintsOnlyMine:YES];            
        }else if(self.selectDraftButton.selected && _drafHaseMoreData){
            [self loadDrafts];
        }
    }
}

- (IBAction)selectAll:(id)sender
{
    [self.selectDraftButton setSelected:NO];
    [self.selectMineButton setSelected:NO];
    [self.selectAllButton setSelected:YES];
    if (_allPaints) {
        [self reloadView];
    }else{
        [self loadPaintsOnlyMine:NO];
    }
    [self updateActionSheetIndexs];
    
}

- (IBAction)selectMine:(id)sender
{
    [self.selectAllButton setSelected:NO];
    [self.selectDraftButton setSelected:NO];
    [self.selectMineButton setSelected:YES];
    if (_myPaints) {
        [self reloadView];
    }else{
        [self loadPaintsOnlyMine:YES];
    }
    [self updateActionSheetIndexs];
}

- (IBAction)selectDraft:(id)sender {
    [self.selectAllButton setSelected:NO];
    [self.selectMineButton setSelected:NO];
    [self.selectDraftButton setSelected:YES];
    if (_drafts) {
        [self reloadView];
    }else{
        [self loadDrafts];
    }
    [self updateActionSheetIndexs];
}


- (IBAction)deleteAll:(id)sender
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
    if ([self.selectMineButton isSelected]) {
        dialog.tag = DELETE_ALL_MINE;
    } else if([self.selectDraftButton isSelected]){
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


- (void)updateActionSheetIndexs
{
    int index = 0;
    SHARE_AS_GIF = -1;
    if ([LocaleUtils isChina]){
        if (self.selectDraftButton.selected) {
            EDIT  = index++;
        }else{
            EDIT = -1;
        }
        SHARE_AS_PHOTO = index++;
        SHARE_AS_GIF = index++;
        REPLAY = index++;
        DELETE = index++;
        DELETE_ALL = index++;
        DELETE_ALL_MINE = index++;
        DELETE_ALL_DRAFT = index++;
        CANCEL = index++;
    }
    else{
        
        
        if (self.selectDraftButton.selected) {
            EDIT  = 0;
        }else{
            EDIT = -1;
        }
        SHARE_AS_PHOTO = index+1;
        REPLAY = index+2;
        DELETE = index+3;
        DELETE_ALL = index+4;
        DELETE_ALL_MINE = index+5;
        DELETE_ALL_DRAFT = index+6;
        CANCEL = index+7;            
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self setFromWeiXin:NO];
        
        _gifImages = [[NSMutableArray alloc] init];

        
        _myPaintManager = [MyPaintManager defaultManager];
        _allHasMoreData = _myHasMoreData = _drafHaseMoreData = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    
    NSString *allTitle = NSLS(@"kAll");
    NSString *mineTitle = NSLS(@"kMine") ;
    NSString *draftTitle = NSLS(@"kDraft") ;
    
    [self.selectAllButton setTitle:allTitle forState:UIControlStateNormal];
    [self.selectMineButton setTitle:mineTitle forState:UIControlStateNormal];
    [self.selectDraftButton setTitle:draftTitle forState:UIControlStateNormal];
    
    ShareImageManager* imageManager = [ShareImageManager defaultManager];
    
    [self.selectAllButton setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
    [self.selectAllButton setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];
    
    [self.selectMineButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [self.selectMineButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];

    [self.selectDraftButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [self.selectDraftButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];
    

    if (self.isFromWeiXin) {
        [self.clearButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];        
        [self.clearButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
        self.backButton.hidden = YES;
        self.awardCoinTips.hidden = YES;
        self.titleLabel.text = NSLS(@"kShareToWeiXinTitle");
        
        //update the table view frame
        CGFloat x = self.dataTableView.frame.origin.x;
        CGFloat y = self.dataTableView.frame.origin.y;
        CGFloat width = self.dataTableView.frame.size.width;
        CGFloat height = self.dataTableView.frame.size.height;
        CGFloat ny = self.selectAllButton.frame.origin.y  + selectAllButton.frame.size.height * 1.2 ;
        CGFloat nHeight = height + (y - ny);
        
        [self.dataTableView setFrame:CGRectMake(x, ny, width, nHeight)];
        
        
    }else{
        [self.clearButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
        [self.clearButton setTitle:NSLS(@"kClear") forState:UIControlStateNormal];
        self.titleLabel.text = NSLS(@"kShareTitle");
    }

    [self selectAll:self.selectAllButton];
}

- (void)viewDidUnload
{
    [self setClearButton:nil];
    [self setTitleLabel:nil];
    [self setSelectAllButton:nil];
    [self setSelectMineButton:nil];
    [self setAwardCoinTips:nil];
    [self setBackButton:nil];
    [self setSelectDraftButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    if (self.selectDraftButton.selected) {
        _draftOffset = 0;
        [_drafts removeAllObjects];
        [self loadDrafts];
//        [_myPaintManager findAllDraftsFrom:_draftOffset limit:LOAD_PAINT_LIMIT delegate:self];
    }
    [super viewDidAppear:animated];
}

@end
