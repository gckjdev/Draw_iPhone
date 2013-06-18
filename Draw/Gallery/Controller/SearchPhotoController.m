//
//  SearchPhotoController.m
//  Draw
//
//  Created by Kira on 13-6-17.
//
//

#import "SearchPhotoController.h"
#import "AutocompletionTableView.h"
#import "CommonSearchImageFilterView.h"
#import "GoogleCustomSearchService.h"
#import "GoogleCustomSearchNetworkConstants.h"
#import "SearchPhotoResultController.h"
#import "PPSmartUpdateData.h"
#import "GalleryController.h"

#define SEARCH_HISTORY @"searchHistory"

@interface SearchPhotoController () <CommonSearchImageFilterViewDelegate, GoogleCustomSearchServiceDelegate>

@property (retain, nonatomic) NSMutableDictionary* options;
@property (retain, nonatomic) AutocompletionTableView* autoCompleter;

@property (retain, nonatomic) NSArray* keywords;
@property (retain, nonatomic) PPSmartUpdateData* smartData;

- (IBAction)clickGallery:(id)sender;

@end

@implementation SearchPhotoController

- (void)dealloc {
    [_searchTextField release];
    [_autoCompleter release];
    [_smartData release];
    [_keywords release];
    [super dealloc];
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
    [super viewDidLoad];
    
    [self updateKeywords];
    
    self.options = [[[NSMutableDictionary alloc] init] autorelease];
    [self.searchTextField addTarget:self.autoCompleter action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    self.searchTextField.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
}


- (void)updateKeywords
{
    NSString* smartDataFile = ([LocaleUtils isChinese]?[GameApp keywordSmartDataCn]:[GameApp keywordSmartDataEn]);
    self.smartData = [[[PPSmartUpdateData alloc] initWithName:smartDataFile type:SMART_UPDATE_DATA_TYPE_TXT bundlePath:smartDataFile initDataVersion:@"1.0"] autorelease];
    
    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        [self loadKeywords];
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        [self loadKeywords];
    }];
}

- (void)loadKeywords
{
    NSError* err;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString* fileStr = [NSString stringWithContentsOfFile:_smartData.dataFilePath encoding:enc error:&err];
    self.keywords = [fileStr componentsSeparatedByString:@"$"];
    [self initKeywords:self.keywords];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (AutocompletionTableView *)autoCompleter
{
    if (!_autoCompleter)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        [options setValue:[NSNumber numberWithBool:YES] forKey:ACOCaseSensitive];
        [options setValue:nil forKey:ACOUseSourceFont];
        
        _autoCompleter = [[AutocompletionTableView alloc] initWithTextField:self.searchTextField inView:self.view withOptions:options];
        
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        NSArray* searchHistory = [def objectForKey:SEARCH_HISTORY];
        _autoCompleter.suggestionsDictionary = searchHistory;
    }
    return _autoCompleter;
}

//+ (SearchView*)createViewWithDefaultKeywords:(NSArray*)array
//                                     options:(NSDictionary*)options
//                                     handler:(SearchHandler)handler
//{
//    SearchView* view = [self createView];
//    view.searchHandler = handler;
//    [view initViewWithPreTextArray:array];
//    view.options = [[[NSMutableDictionary alloc] initWithDictionary:options] autorelease];
//    [view.searchTextField addTarget:view.autoCompleter action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
//    view.searchTextField.delegate = view;
//    return view;
//}

#define PRE_TEXT_BTN_OFFSET 120130609
#define MAX_PRE_TEXT_BTN    9

- (void)initKeywords:(NSArray*)array
{
    for (int i = 0; i < MAX_PRE_TEXT_BTN
         ; i ++) {
        UIButton* btn = (UIButton*)[self.view viewWithTag:(PRE_TEXT_BTN_OFFSET+i)];
        if (i < array.count) {
            NSString* title = [array objectAtIndex:i];
            [btn setTitle:title forState:UIControlStateNormal];
            btn.hidden = !(title.length > 0);
        } else {
            btn.hidden = YES;
        }
    }
}

- (IBAction)clickKeywordBtn:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    [self.searchTextField setText:[btn titleForState:UIControlStateNormal]];
    [self clickSearch:nil];
}

- (void)saveSearchHistory
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSArray* history = [def objectForKey:SEARCH_HISTORY];
    NSMutableArray* array = [NSMutableArray arrayWithArray:history];
    if (![array containsObject:self.searchTextField.text]) {
        [array addObject:self.searchTextField.text];
        [def setObject:array forKey:SEARCH_HISTORY];
        [def synchronize];
        PPDebug(@"<saveSearchHistory> save search history <%@>", self.searchTextField.text);
    }
    
}

- (IBAction)clickSearch:(id)sender
{
//    [self saveSearchHistory];
//    EXECUTE_BLOCK(self.searchHandler, self.searchTextField.text, self.options);
//    self.searchHandler = nil;
//    [self disappear];
    
    //TODO:enter search result
    
    [[GoogleCustomSearchService defaultService] searchImageBytext:self.searchTextField.text imageSize:CGSizeMake(0, 0) imageType:nil startPage:0 paramDict:self.options delegate:self];
    [self showActivityWithText:NSLS(@"kSearching")];
    
}

- (IBAction)clickOptions:(id)sender
{
    CommonSearchImageFilterView* view = [CommonSearchImageFilterView createViewWithFilter:self.options
                                                                                 delegate:self];
    [view showInView:self.view];
    [self.searchTextField resignFirstResponder];
    
}

- (IBAction)clickGallery:(id)sender
{
    GalleryController* vc = [[[GalleryController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - commonSearchImageFilterViewDelegate

- (void)didConfirmFilter:(NSDictionary *)filter
{
    [self.options removeAllObjects];
    [self.options setDictionary:filter];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self clickSearch:nil];
        return YES;
    }
    return NO;
}

#pragma google custom service delegate

- (void)didSearchImageResultList:(NSMutableArray*)array
                      resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == OLD_G_ERROR_SUCCESS) {
        SearchPhotoResultController* vc = [[[SearchPhotoResultController alloc] initWithKeyword:self.searchTextField.text options:self.options resultArray:array] autorelease];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
