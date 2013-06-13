//
//  SearchView.m
//  Draw
//
//  Created by Kira on 13-6-8.
//
//

#import "SearchView.h"
#import "AutocompletionTableView.h"
#import "AutoCreateViewByXib.h"
#import "AutocompletionTableView.h"

@interface SearchView ()

@property (retain, nonatomic) NSMutableDictionary* options;
@property (retain, nonatomic) AutocompletionTableView* autoCompleter;

@end

#define SEARCH_HISTORY @"searchHistory"

@implementation SearchView

AUTO_CREATE_VIEW_BY_XIB(SearchView)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (AutocompletionTableView *)autoCompleter
{
    if (!_autoCompleter)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        [options setValue:[NSNumber numberWithBool:YES] forKey:ACOCaseSensitive];
        [options setValue:nil forKey:ACOUseSourceFont];
        
        _autoCompleter = [[AutocompletionTableView alloc] initWithTextField:self.searchTextField inView:self withOptions:options];
        
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        NSArray* searchHistory = [def objectForKey:SEARCH_HISTORY];
        _autoCompleter.suggestionsDictionary = searchHistory;
    }
    return _autoCompleter;
}

+ (SearchView*)createViewWithDefaultKeywords:(NSArray*)array
                                     options:(NSDictionary*)options
                                     handler:(SearchHandler)handler
{
    SearchView* view = [self createView];
    view.searchHandler = handler;
    [view initViewWithPreTextArray:array];
    view.options = [[[NSMutableDictionary alloc] initWithDictionary:options] autorelease];
    [view.searchTextField addTarget:view.autoCompleter action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    view.searchTextField.delegate = view;
    return view;
}

#define PRE_TEXT_BTN_OFFSET 120130609
#define MAX_PRE_TEXT_BTN    9

- (void)initViewWithPreTextArray:(NSArray*)array
{
    for (int i = 0; i < MAX_PRE_TEXT_BTN
         ; i ++) {
        UIButton* btn = (UIButton*)[self viewWithTag:(PRE_TEXT_BTN_OFFSET+i)];
        if (i < array.count) {
            NSString* title = [array objectAtIndex:i];
            [btn setTitle:title forState:UIControlStateNormal];
            btn.hidden = !(title.length > 0);
        } else {
            btn.hidden = YES;
        }
    }
}

- (IBAction)clickPreTextBtn:(id)sender
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
    [array addObject:self.searchTextField.text];
    [def setObject:array forKey:SEARCH_HISTORY];
    [def synchronize];
    PPDebug(@"<saveSearchHistory> save search history <%@>", self.searchTextField.text);
}

- (IBAction)clickSearch:(id)sender
{
    [self saveSearchHistory];
    EXECUTE_BLOCK(self.searchHandler, self.searchTextField.text, self.options);
    self.searchHandler = nil;
    [self disappear];
}

- (IBAction)clickOptions:(id)sender
{
    CommonSearchImageFilterView* view = [CommonSearchImageFilterView createViewWithFilter:self.options
                                             delegate:self];
    [view showInView:self];
    [self.searchTextField resignFirstResponder];
    
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

- (IBAction)clickCancelBtn:(id)sender
{
    [self.searchTextField resignFirstResponder];
    [self disappear];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_searchTextField release];
    [_autoCompleter release];
    RELEASE_BLOCK(_searchHandler);
    [super dealloc];
}
@end
