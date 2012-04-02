//
//  MyPaintManager.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPaintManager : NSObject

+ (MyPaintManager*)defaultManager;
- (BOOL)createMyPaintWithImage:(NSString*)image
                          data:(NSData*)data
                    drawUserId:(NSString*)drawUserId
              drawUserNickName:(NSString*)drawUserNickName
                      drawByMe:(BOOL)drawByMe;


- (NSArray*)findOnlyMyPaints;
- (NSArray*)findAllPaints;
- (BOOL)deleteAllPaintsAtIndex:(NSInteger)index;
- (BOOL)deleteOnlyMyPaintsAtIndex:(NSInteger)index;

@end
