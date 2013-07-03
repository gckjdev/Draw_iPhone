//
//  SearchResultView.h
//  Draw
//
//  Created by Kira on 13-6-5.
//
//

#import <UIKit/UIKit.h>
#import "PSCollectionViewCell.h"

@class ImageSearchResult;

@protocol SearchResultViewDelegate <NSObject>

- (void)didClickSearchResult:(ImageSearchResult*)searchResult;

@end

@interface SearchResultView : PSCollectionViewCell

@property (retain, nonatomic) ImageSearchResult* searchResult;
@property (assign, nonatomic) id<SearchResultViewDelegate>delegate;

- (void)updateWithResult:(ImageSearchResult*)result;
- (void)updateWithUrl:(NSString*)url;
@end
