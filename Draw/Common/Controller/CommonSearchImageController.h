//
//  CommonSearchImageController.h
//  Draw
//
//  Created by Kira on 13-6-1.
//
//

#import "CommonTabController.h"
#import "GoogleCustomSearchService.h"

@interface CommonSearchImageController : CommonTabController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, GoogleCustomSearchServiceDelegate>

@property (retain, nonatomic) IBOutlet UISearchBar* searchBar;

@end
