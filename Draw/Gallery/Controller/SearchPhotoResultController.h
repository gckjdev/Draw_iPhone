//
//  SearchPhotoResultController.h
//  Draw
//
//  Created by Kira on 13-6-17.
//
//

#import "CommonTabController.h"

@interface SearchPhotoResultController : CommonTabController

- (id)initWithKeyword:(NSString*)keyword
              options:(NSDictionary*)options
          resultArray:(NSArray*)array;

@end
