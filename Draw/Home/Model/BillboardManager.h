//
//  BillboardManager.h
//  Draw
//
//  Created by ChaoSo on 14-7-16.
//
//

#import <Foundation/Foundation.h>
#import "StorageManager.h"

@class PPSmartUpdateData;

@interface BillboardManager : NSObject

@property (nonatomic, retain) PPSmartUpdateData* smartData;
@property (nonatomic, retain) StorageManager* imageManager;
@property (nonatomic, retain) NSMutableArray* bbList;

+ (BillboardManager*)defaultManager;
- (void)autoUpdate;
- (UIImage*)getImage:(NSString*)url;

@end
