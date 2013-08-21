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
#import "CommonMessageCenter.h"
#import "AnalyticsManager.h"
#import "UserGameItemService.h"
#import "UserGameItemManager.h"
#import "GameItemManager.h"
#import "PBGameItem+Extend.h"
#import "BuyItemView.h"
#import "BalanceNotEnoughAlertView.h"
#import "CommonTitleView.h"

#define CONVERT_VIEW_FRAME_TO_TOP_VIEW(v) [[v superview] convertRect:v.frame toView:self.view]
#define DIALOG_TAG_INPUT_WORD_VIEW 102

@interface SelectHotWordController ()
@property (copy, nonatomic) NSString *targetUid;

@end

@implementation SelectHotWordController

- (void)dealloc {
    PPDebug(@"%@ dealloc", self);
    PPRelease(_hotWordsCell);
    PPRelease(_systemWordsCell);
    PPRelease(_myWordsCell);
    PPRelease(_hotWordsCellPlaceHolder);
    PPRelease(_systemWordsCellPlaceHolder);
    PPRelease(_myWordsCellPlaceHolder);
    PPRelease(_hotWordsView);
    PPRelease(_systemWordsView);
    PPRelease(_myWordsView);
    PPRelease(_hotWordsLabel);
    PPRelease(_hotWordsNoteLabel);
    PPRelease(_systemWordsLabel);
    PPRelease(_myWordsLabel); 
    PPRelease(_targetUid);
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
    [self initWordCells];
    
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTitle:NSLS(@"kIWantToDraw...")];
    [titleView setRightButtonTitle:NSLS(@"kDraftsBox")];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [titleView setRightButtonSelector:@selector(clickDraftButton:)];
    [titleView setTarget:self];

    self.hotWordsLabel.text = NSLS(@"kHotWords");
    self.hotWordsNoteLabel.text = NSLS(@"kHotWordsNote");
    self.systemWordsLabel.text = NSLS(@"kSystemWords");
    self.myWordsLabel.text = NSLS(@"kMyWords");
    
    if (isLittleGeeAPP()) {
        [self didSelectWord:[Word cusWordWithText:@""]];
    }
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
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMyWords") customView:customWordView style:CommonDialogStyleCross];
    [dialog showInView:self.view];
    dialog.delegate = self;
}

- (void)didSelecCustomWord:(NSString *)word
{
    [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_CUSTOM];
    Word *myWord = [Word cusWordWithText:word];
    [OfflineDrawViewController startDraw:myWord fromController:self startController:self.superController targetUid:_targetUid];
}



- (IBAction)clickDraftButton:(id)sender {
    [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_LOAD_DRAFTS];
    
    DraftsView *view = [DraftsView createWithdelegate:self];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kDraftsBox") customView:view style:CommonDialogStyleCross];
    [dialog showInView:self.view];
}

- (void)payForHotWord:(Word *)word
{    
    __block typeof (self) bself = self;
    [[UserGameItemService defaultService] consumeItem:ItemTypeTips count:1 forceBuy:YES handler:^(int resultCode, int itemId, BOOL isBuy) {
        if (resultCode == ERROR_SUCCESS) {
            [OfflineDrawViewController startDraw:word fromController:bself startController:bself.superController targetUid:bself.targetUid ];
        }else if (resultCode == ERROR_BALANCE_NOT_ENOUGH) {
            [BalanceNotEnoughAlertView showInController:self];
        }else if (resultCode == ERROR_USERID_NOT_FOUND){
            [[UserService defaultService] checkAndAskLogin:self.view];
        }
        else
        {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNetworkFailure") delayTime:1 isHappy:NO];
        }
    }];
}

- (void)didSelectWord:(Word *)word
{
    if (word == nil) {
        [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_ADD_CUSTOM_WORD];

        CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kInputWord") delegate:self];
        dialog.tag = DIALOG_TAG_INPUT_WORD_VIEW;
        dialog.inputTextField.placeholder = NSLS(@"kInputWordPlaceholder");
        [dialog showInView:self.view];
    }else{
        if (word.wordType == PBWordTypeHot) {
            PPDebug(@"Hot Word Selected!");
            [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_HOT];

        }else if (word.wordType == PBWordTypeSystem){
            [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_SYSTEM];
        }else if (word.wordType == PBWordTypeCustom){
            [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_CUSTOM];
        }
        
        
        if (word.wordType == PBWordTypeHot) {
            [self payForHotWord:word];
        }else{
            [OfflineDrawViewController startDraw:word fromController:self startController:self.superController targetUid:_targetUid];
        }
        
    }
}

- (void)didSelectDraft:(MyPaint *)draft
{
    [[AnalyticsManager sharedAnalyticsManager] reportSelectWord:SELECT_WORD_CLICK_TYPE_DRAFT];

    OfflineDrawViewController *vc = [[[OfflineDrawViewController alloc] initWithDraft:draft] autorelease];
    vc.targetUid = _targetUid;
    vc.startController = self.superController;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - InputDialogDelegate
- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView
{
    if (dialog.tag == DIALOG_TAG_INPUT_WORD_VIEW) {
        UITextField *tf = (UITextField *)infoView;
        if ([CustomWordManager isValidWord:tf.text]) {
            [[CustomWordManager defaultManager] createCustomWord:tf.text];
            [[UserService defaultService] commitWords:tf.text viewController:nil];
            [_myWordsCell setWords:[[CustomWordManager defaultManager] wordsFromCustomWords]];
        }
    }
}

- (void)didClickCancel:(CommonDialog *)dialog{

    [_myWordsCell setWords:[[CustomWordManager defaultManager] wordsFromCustomWords]];
}

- (void)didClickClose:(CommonDialog *)dialog{
    
    [_myWordsCell setWords:[[CustomWordManager defaultManager] wordsFromCustomWords]];
}

@end
