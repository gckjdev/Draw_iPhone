//
//  SearchView.h
//  Draw
//
//  Created by Kira on 13-6-8.
//
//

#import "CommonInfoView.h"
#import "CommonSearchImageFilterView.h"


typedef void(^SearchHandler)(NSString* searchText, NSDictionary* options);

@interface SearchView : CommonInfoView <CommonSearchImageFilterViewDelegate, UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
@property (copy, nonatomic) SearchHandler searchHandler;

- (IBAction)clickSearch:(id)sender;
- (IBAction)clickOptions:(id)sender;
- (IBAction)clickPreTextBtn:(id)sender;
- (IBAction)clickCancelBtn:(id)sender;

+ (SearchView*)createViewWithDefaultKeywords:(NSArray*)array
                                     options:(NSDictionary*)options
                                     handler:(SearchHandler)handler;

@end
