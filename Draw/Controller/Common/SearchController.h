//
//  SearchController.h
//  Draw
//
//  Created by Gamy on 13-10-23.
//
//

#import "CommonTabController.h"

@interface SearchController : CommonTabController<UITextFieldDelegate>


//implemented by subclass.

- (void)loadDataWithKey:(NSString *)key tabID:(NSInteger)tabID;

- (UITableViewCell *)cellForRow:(NSInteger)row;
- (CGFloat)heightForRow:(NSInteger)row;
- (void)didSelectedCellInRow:(NSInteger)row;
- (NSString *)headerTitle;
- (NSString *)searchTips; //used as placeholder.
- (NSString *)historyStoreKey; //default is the class name.
@end

