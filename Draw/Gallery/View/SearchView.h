//
//  SearchView.h
//  Draw
//
//  Created by Kira on 13-6-8.
//
//

#import "CommonInfoView.h"

typedef void(^SearchHandler)(NSString* searchText, NSDictionary* options);

@interface SearchView : CommonInfoView
@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
@property (copy, nonatomic) SearchHandler searchHandler;

@end
