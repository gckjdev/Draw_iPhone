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

@interface SearchView ()

@property NSMutableDictionary* options;

@end

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

+ (SearchView*)createViewWithPreTextArray:(NSArray*)array
                                  handler:(SearchHandler)handler
{
    SearchView* view = [self createView];
    view.searchHandler = handler;
    [view initViewWithPreTextArray:array];
    return view;
}

- (void)initViewWithPreTextArray:(NSArray*)array
{
    
}

- (IBAction)clickSearch:(id)sender
{
    EXECUTE_BLOCK(self.searchHandler, self.searchTextField.text, self.options);
}

- (IBAction)clickOptions:(id)sender
{
    
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
    RELEASE_BLOCK(_searchHandler);
    [super dealloc];
}
@end
