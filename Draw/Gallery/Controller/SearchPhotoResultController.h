//
//  SearchPhotoResultController.h
//  Draw
//
//  Created by Kira on 13-6-17.
//
//

#import "CommonWaterFlowController.h"

@class PBUserPhoto;

@protocol SearchPhotoResultControllerDelegate <NSObject>

- (void)didAddUserPhoto:(PBUserPhoto*)photo;

@end

@interface SearchPhotoResultController : CommonWaterFlowController

- (id)initWithKeyword:(NSString*)keyword
              options:(NSDictionary*)options
          resultArray:(NSArray*)array
             delegate:(id<SearchPhotoResultControllerDelegate>)delegate;

@end
