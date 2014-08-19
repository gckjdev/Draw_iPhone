//
//  ShareService.h
//  Draw
//
//  Created by  on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyPaintManager.h"
//#import "PPSNSCommonService.h"

@interface ShareService : NSObject<MyPaintManagerDelegate>

+ (ShareService*)defaultService;

- (void)shareWithImage:(UIImage*)image drawUserId:(NSString*)drawUserId isDrawByMe:(BOOL)isDrawByMe drawWord:(NSString*)drawWord;
- (UIImage*)synthesisImage:(UIImage*)srcImage waterMarkText:(NSString*)text;
- (NSString*)synthesisImageFile:(NSString*)filePath waterMarkText:(NSString*)text;
- (NSString*)synthesisImageWithImage:(UIImage*)sourceImage waterMarkText:(NSString*)text;

- (void)saveGif:(PPViewController*)superController
          draft:(MyPaint*)draft;

- (void)showShareGifDialog:(PPViewController*)superController
                     draft:(MyPaint*)draft;

- (void)shareAsGIF:(PPViewController*)superController
         opusImage:(UIImage*)opusImage
            opusId:(NSString*)opusId
    drawActionList:(NSMutableArray*)drawActionList
            layers:(NSArray*)layers
        canvasSize:(CGSize)canvasSize
          drawWord:(NSString*)drawWord
          drawDesc:(NSString*)drawDesc
        drawUserId:(NSString*)drawUserId
    drawUserGender:(BOOL)drawUserGender
     completeBlock:(dispatch_block_t)completeBlock;


@end
