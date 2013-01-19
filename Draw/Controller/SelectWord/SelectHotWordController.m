//
//  SelectHotWordController.m
//  Draw
//
//  Created by 王 小涛 on 13-1-3.
//
//

#import "SelectHotWordController.h"
#import "CustomWordManager.h"
#import "WordManager.h"
#import "HotWordManager.h"
#import "OfflineDrawViewController.h"
#import "UserService.h"
#import "AccountService.h"
#import "Item.h"
#import "CommonMessageCenter.h"
#import "AnalyticsManager.h"

#define CONVERT_VIEW_FRAME_TO_TOP_VIEW(v) [[v superview] convertRect:v.frame toView:self.view]

@interface SelectHotWordController ()
@property (copy, nonatomic) NSString *targetUid;

@end

@implementation SelectHotWordController

- (void)dealloc {
    [_hotWordsCell release];
    [_systemWordsCell release];
    [_myWordsCell release];
    [_hotWordsCellPlaceHolder release];
    [_systemWordsCellPlaceHolder release];
    [_myWordsCellPlaceHolder release];
    [_hotWordsView release];
    [_systemWordsView release];
    [_myWordsView release];
    [_titleLabel release];
    [_draftsBoxButton release];
    [_hotWordsLabel release];
    [_hotWordsNoteLabel release];
    [_systemWordsLabel release];
    [_myWordsLabel release];
    [_targetUid release];
    [super dealloc];
}

- (id)initWithTargetUid:(NSString *)targetUid
{
    self = [super init];
    if (self) {
        self.targetUid = targetUid;
    }
    return self;
}

- (void)initWordCells
{
    self.hotWordsCell = [WordSelectCell createViewWithFrame:_hotWordsCellPlaceHolder.frame];
    self.systemWordsCell = [WordSelectCell createViewWithFrame:_systemWordsCellPlaceHolder.frame];
    self.myWordsCell =  [WordSelectCell createViewWithFrame:_myWordsCellPlaceHolder.frame];
    
    [self.hotWordsView addSubview:_hotWordsCell];
    [self.systemWordsView addSubview:_systemWordsCell];
    [self.myWordsView addSubview:_myWordsCell];
    
    [_hotWordsCell setWords:[[HotWordManager sharedHotWordManager] wordsFromPBHotWords]];
    [_systemWordsCell setWords:[[WordManager defaultManager] randOfflineDrawWordList]];
    [_myWordsCell setWords:[[CustomWordManager defaultManager] wordsFromCustomWords]];
    
    _hotWordsCell.delegate = self;
    _systemWordsCell.delegate = self;
    _myWordsCell.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [HotWordManager createTestData];
    [self initWordCells];
    self.titleLabel.text = NSLS(@"kIWantToDraw...");
    self.hotWordsLabel.text = NSLS(@"kHotWords");
    self.hotWordsNoteLabel.text = NSLS(@"kHotWordsNote");
    self.systemWordsLabel.text = NSLS(@"kSystemWords");
    self.myWordsLabel.text = NSLS(@"kMyWords");

    [self.draftsBoxButton setTitle:NSLS(@"kDraftsBox") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [self setHotWordsCell:nil];
    [self setSystemWordsCell:nil];
    [self setMyWordsCell:nil];
    [self setHotWordsCellPlaceHolder:nil];
    [self setSystemWordsCellPlaceHolder:nil];
    [self setMyWordsCellPlaceHolder:nil];
    [self setHotWordsView:nil];
    [self setSystemWordsView:nil];
    [self setMyWordsView:nil];
    [self setTitleLabel:nil];
    [self setDraftsBoxButton:nil];
    [self setHotWordsLabel:nil];
    [self setHotWordsNoteLabel:nil];
    [self setSystemWordsLabel:nil];
    [self setMyWordsLabel:nil];
    [super viewDidUnload];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickAllMyWordsButton:(id)sender {
    [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_MORE_CUSTOM_WORDS];

    SelectCustomWordView *customWordView = [SelectCustomWordView createView:self];
    [customWordView showInView:self.view];
}

- (void)didSelecCustomWord:(NSString *)word
{
    [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_CUSTOM];
    Word *myWord = [Word cusWordWithText:word];
    [OfflineDrawViewController startDraw:myWord fromController:self targetUid:_targetUid];
}

- (void)didCloseSelectCustomWordView:(SelectCustomWordView *)view
{
    [_myWordsCell setWords:[[CustomWordManager defaultManager] wordsFromCustomWords]];
}

- (IBAction)clickDraftButton:(id)sender {
    [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_LOAD_DRAFTS];
    [DraftsView showInView:self.view delegate:self];
}

- (void)payForHotWord
{
    if ([[AccountService defaultService] consumeItem:ItemTypeTips amount:1] ==  ERROR_ITEM_NOT_ENOUGH) {
        if ([[AccountService defaultService] buyItem:ItemTypeTips itemCount:1 itemCoins:[[Item tips] unitPrice]] == ERROR_COINS_NOT_ENOUGH) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoin") delayTime:1 isHappy:NO];
            return;
        }else {
            [[AccountService defaultService] consumeItem:ItemTypeTips amount:1];
        }
    }
}

- (void)didSelectWord:(Word *)word
{
    if (word == nil) {
        [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_ADD_CUSTOM_WORD];

        InputDialog *inputDialog = [InputDialog dialogWith:NSLS(@"kInputWord") delegate:self];
        inputDialog.targetTextField.placeholder = NSLS(@"kInputWordPlaceholder");
        [inputDialog showInView:self.view];
    }else{
        if (word.wordType == PBWordTypeHot) {
            PPDebug(@"Hot Word Selected!");
            [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_HOT];
            [self payForHotWord];

        }else if (word.wordType == PBWordTypeSystem){
            [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_SYSTEM];
        }else if (word.wordType == PBWordTypeCustom){
            [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_CUSTOM];
        }
        
        [OfflineDrawViewController startDraw:word fromController:self targetUid:_targetUid];
    }
}

- (void)didSelectDraft:(MyPaint *)draft
{
    [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_DRAFT];

    OfflineDrawViewController *vc = [[[OfflineDrawViewController alloc] initWithDraft:draft] autorelease];
    vc.targetUid = _targetUid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - InputDialogDelegate
- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    if ([CustomWordManager isValidWord:targetText]) {
        [[CustomWordManager defaultManager] createCustomWord:targetText];
        [[UserService defaultService] commitWords:targetText viewController:nil];
        [_myWordsCell setWords:[[CustomWordManager defaultManager] wordsFromCustomWords]];
    }
}

@end
