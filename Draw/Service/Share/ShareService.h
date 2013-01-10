//
//  ShareService.h
//  Draw
//
//  Created by  on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPSNSCommonService.h"

@interface ShareService : NSObject

+ (ShareService*)defaultService;

- (void)shareWithImage:(UIImage*)image drawUserId:(NSString*)drawUserId isDrawByMe:(BOOL)isDrawByMe drawWord:(NSString*)drawWord;
- (UIImage*)synthesisWeiboImage:(UIImage*)srcImage text:(NSString*)text;
- (void)shareImage:(UIImage*)srcImage
              text:(NSString*)text
         waterMark:(NSString*)waterMark
            viaSNS:(int)snsType
      successBlock:(PPSNSSuccessBlock)successBlock
      failureBlock:(PPSNSFailureBlock)failureBlock;
@end
