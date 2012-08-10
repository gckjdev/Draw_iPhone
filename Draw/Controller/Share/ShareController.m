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
    
    MyPaint *_selectedPaint;
    
    NSMutableArray *_gifImages;
    
    NSInteger _allOffset;
    NSInteger _myOffset;
    
    MyPaintManager *_myPaintManager;
    
    BOOL _allHasMoreData;
    BOOL _myHasMoreData;

}
@property (retain, nonatomic) IBOutlet MyPaint *selectedPaint;
- (void)loadPaintsOnlyMine:(BOOL)onlyMine;
- (NSArray *)paints;
- (void)reloadView;
@end

@implementation ShareController
@synthesize selectMineButton;
@synthesize selectAllButton;
@synthesize clearButton;
@synthesize titleLabel;
@synthesize shareAction = _shareAction;
@synthesize awardCoinTips;
@synthesize selectedPaint = _selectedPaint;

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
    PPRelease(awardCoinTips);
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


- (void)loadPaintsOnlyMine:(BOOL)onlyMine
{
    [self showActivityWithText:NSLS(@"kLoading")];
    if (onlyMine) {
        [_myPaintManager findMyPaintsFrom:_myOffset limit:LOAD_PAINT_LIMIT delegate:self];
    } else {
        [_myPaintManager findAllPaintsFrom:_allOffset limit:LOAD_PAINT_LIMIT delegate:self];
    }    
}

#pragma mark - Share Cell Delegate
- (void)didSelectPaint:(MyPaint *)paint
{
    self.selectedPaint = paint;
    UIActionSheet* tips = nil;
    
    if ([LocaleUtils isChina]){
        tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                                      delegate:self 
                                             cancelButtonTitle:NSLS(@"kCancel") 
                                        destructiveButtonTitle:NSLS(@"kShareAsPhoto") 
                                             otherButtonTitles:NSLS(@"kShareAsGif"),
                                                    NSLS(@"kReplay"), NSLS(@"kDelete"), NSLS(@"kDeleteAll"), nil];
    }
    else{
        tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                           delegate:self 
                                  cancelButtonTitle:NSLS(@"kCancel") 
                             destructiveButtonTitle:NSLS(@"kShareAsPhoto") 
                                  otherButtonTitles:NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
        
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
    }
    
}


#pragma mark - Common Dialog Delegate
- (void)clickOk:(CommonDialog *)dialog
{
    BOOL result = NO;
    if (dialog.tag == DELETE){
        MyPaint* currentPaint = self.selectedPaint;
        if (currentPaint == nil) {
            return;
        }

        if (currentPaint.drawByMe.boolValue) {
            _myOffset --;
            [_myPaints removeObject:currentPaint];
        }       
        if ([_allPaints containsObject:currentPaint]) {
            _allOffset --;
            [_allPaints removeObject:currentPaint];
        }
        result = [[MyPaintManager defaultManager] deleteMyPaint:currentPaint];
        self.selectedPaint = nil;
    }
    else if (dialog.tag == DELETE_ALL){
        _allOffset = 0;
        _myOffset = 0;
        [_allPaints removeAllObjects];
        [_myPaints removeAllObjects];
        result = [[MyPaintManager defaultManager] deleteAllPaints:NO];
        [self loadPaintsOnlyMine:NO];
        
    } else if (dialog.tag == DELETE_ALL_MINE) {
        _allOffset = 0;
        _myOffset = 0;
        [_allPaints removeAllObjects];
        [_myPaints removeAllObjects];
        result = [[MyPaintManager defaultManager] deleteAllPaints:YES];
        [self loadPaintsOnlyMine:NO];
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
    PPDebug(@"total paints is %d", self.paints.count);
    
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
    }else{
        return _myPaints;
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
        PPDebug(@"<ShareController> scroll to end");
        if (self.selectAllButton.selected && _allHasMoreData) {
            [self loadPaintsOnlyMine:NO];            
        PPDebug(@"<ShareController> scroll to end, load more all data");
        }else if(self.selectMineButton.selected && _myHasMoreData){
            [self loadPaintsOnlyMine:YES];            
        PPDebug(@"<ShareController> scroll to end, load more my data");
        }
    }
}

- (IBAction)selectAll:(id)sender
{
    [self.selectAllButton setSelected:YES];
    [self.selectMineButton setSelected:NO];
    if (_allPaints) {
        [self reloadView];
    }else{
        [self loadPaintsOnlyMine:NO];
    }
}

- (IBAction)selectMine:(id)sender
{
    [self.selectAllButton setSelected:NO];
    [self.selectMineButton setSelected:YES];
    if (_myPaints) {
        [self reloadView];
    }else{
        [self loadPaintsOnlyMine:YES];
    }
}

- (IBAction)deleteAll:(id)sender
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAttention") 
                                                       message:NSLS(@"kDeleteAllWarning") 
                                                         style:CommonDialogStyleDoubleButton 
                                                      delegate:self];
    if ([self.selectMineButton isSelected]) {
        dialog.tag = DELETE_ALL_MINE;
    } else {
        dialog.tag = DELETE_ALL;
    }
    [dialog showInView:self.view];
    
}

-(IBAction)clickBackButton:(id)sender
{
    self.shareAction = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _gifImages = [[NSMutableArray alloc] init];

        if ([LocaleUtils isChina]){
            int index = 0;
            SHARE_AS_PHOTO = index++;
            SHARE_AS_GIF = index++;
            REPLAY = index++;
            DELETE = index++;
            DELETE_ALL = index++;
            DELETE_ALL_MINE = index++;
            CANCEL = index++;
        }
        else{
            int index = 0;
            SHARE_AS_PHOTO = index++;
            REPLAY = index++;
            DELETE = index++;
            DELETE_ALL = index++;
            DELETE_ALL_MINE = index++;
            CANCEL = index++;            
        }
        
        _myPaintManager = [MyPaintManager defaultManager];
        _allHasMoreData = _myHasMoreData = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    
    NSString *allTitle = NSLS(@"kAll");
    NSString *mineTitle = NSLS(@"kMine") ;
    ShareImageManager* imageManager = [ShareImageManager defaultManager];
    [self.selectAllButton setTitle:allTitle forState:UIControlStateNormal];
    [self.selectMineButton setTitle:mineTitle forState:UIControlStateNormal];
    [self.selectAllButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [self.selectAllButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
    [self.selectMineButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [self.selectMineButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];
    [self.clearButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    [self.clearButton setTitle:NSLS(@"kClear") forState:UIControlStateNormal];

    [self selectAll:self.selectAllButton];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLS(@"kShareTitle");
    
}

- (void)viewDidUnload
{
    [self setClearButton:nil];
    [self setTitleLabel:nil];
    [self setSelectAllButton:nil];
    [self setSelectMineButton:nil];
    [self setAwardCoinTips:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end
