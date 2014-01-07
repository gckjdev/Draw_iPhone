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

- (UITableViewCell *)cellForData:(id)data;
- (CGFloat)heightForData:(id)data;
- (void)didSelectedCellWithData:(id)data;
- (NSString *)headerTitle;
- (NSString *)searchTips; //used as placeholder.
- (NSString *)historyStoreKey; //default is the class name.
- (BOOL)isTitleViewTransparentStyle;


@end

