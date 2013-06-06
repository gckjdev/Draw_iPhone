//
//  CommonSearchImageController.h
//  Draw
//
//  Created by Kira on 13-6-1.
//
//

#import "CommonTabController.h"
#import "GoogleCustomSearchService.h"
#import "MWPhotoBrowser.h"
#import "SearchResultView.h"
#import "CommonSearchImageFilterView.h"

@interface CommonSearchImageController : CommonTabController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, GoogleCustomSearchServiceDelegate, MWPhotoBrowserDelegate, SearchResultViewDelegate, CommonSearchImageFilterViewDelegate>

@property (retain, nonatomic) IBOutlet UISearchBar* searchBar;

- (IBAction)clickFilter:(id)sender;

@end
