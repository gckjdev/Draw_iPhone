//
//  SearchPhotoResultController.h
//  Draw
//
//  Created by Kira on 13-6-17.
//
//

#import "CommonWaterFlowController.h"

@interface SearchPhotoResultController : CommonWaterFlowController

- (id)initWithKeyword:(NSString*)keyword
              options:(NSDictionary*)options
          resultArray:(NSArray*)array;

@end
