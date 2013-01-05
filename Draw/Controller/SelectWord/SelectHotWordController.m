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

#define CONVERT_VIEW_FRAME_TO_TOP_VIEW(v) [[v superview] convertRect:v.frame toView:self.view]

@interface SelectHotWordController ()

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
    [super dealloc];
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
    [_systemWordsCell setWords:[[WordManager defaultManager] randDrawWordList]];
    [_myWordsCell setWords:[[CustomWordManager defaultManager] wordsFromCustomWords]];
    
    _hotWordsCell.delegate = self;
    _systemWordsCell.delegate = self;
    _myWordsCell.delegate = self;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [HotWordManager createTestData];
    [self initWordCells];
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
    [super viewDidUnload];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickAllMyWordsButton:(id)sender {
    SelectCustomWordView *customWordView = [SelectCustomWordView createView:self];
    [customWordView showInView:self.view];
}

- (void)didSelecCustomWord:(NSString *)word
{
    Word *myWord = [Word wordWithText:word level:WordLeveLMedium];
    [OfflineDrawViewController startDraw:myWord fromController:self];
}

- (IBAction)clickDraftButton:(id)sender {
    
}

- (void)didSelectWord:(Word *)word
{
    [OfflineDrawViewController startDraw:word fromController:self];
}

@end
