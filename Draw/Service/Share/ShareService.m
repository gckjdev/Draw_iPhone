//
//  ShareService.m
//  Draw
//
//  Created by  on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareService.h"
#import "UserManager.h"
#import "StringUtil.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"
#import "PPNetworkRequest.h"
#import "PPSNSConstants.h"
#import "PPSNSIntegerationService.h"
#import "GameSNSService.h"
#import "UIImageExt.h"

@implementation ShareService

static ShareService* _defaultService;

+ (ShareService*)defaultService
{
    if (_defaultService == nil){
        _defaultService = [[ShareService alloc] init];
    }
    
    return _defaultService;
}


- (NSString*)getWeiboText:(int)snsType 
         drawUserNickName:(NSString*)drawUserNickName 
               isDrawByMe:(BOOL)isDrawByMe 
                 drawWord:(NSString*)drawWord
{
    NSString* appNick = [GameSNSService snsOfficialNick:snsType];    
    if (appNick == nil)
        appNick = @"";
    
    if (drawUserNickName == nil)
        drawUserNickName = @"";     
    
    if (drawWord == nil)
        drawWord = @"";
    
    NSString* text = @"";
    if (isDrawByMe){
        text = [NSString stringWithFormat:NSLS(@"kShareMeTextAuto"), appNick, drawWord];
    }
    else{
        NSString* nick = nil;
        if ([drawUserNickName length] > 0){
            nick = [NSString stringWithFormat:@"@%@", drawUserNickName];
        }
        else{
            nick = @"";
        }
        text = [NSString stringWithFormat:NSLS(@"kShareOtherTextAuto"), appNick, nick];
    }                
    
    PPDebug(@"Share Weibo Text=%@", text); 
    return text;
}

- (void)shareWeiboWithDrawUserId:(NSString*)drawUserId         
                      isDrawByMe:(BOOL)isDrawByMe 
                        drawWord:(NSString*)drawWord         
                       imagePath:(NSString*)imagePath
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    if (queue == NULL){
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    if (queue == NULL){
        PPDebug(@"<Warning> Share Weibo But Queue is NULL");
        return;
    }
    
    dispatch_async(queue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getUserSimpleInfo:SERVER_URL
                                                                     userId:[[UserManager defaultManager] userId]
                                                                      appId:[ConfigManager appId]
                                                                     gameId:[ConfigManager gameId]
                                                                   ByUserId:drawUserId];
        
//        CommonNetworkOutput* output = [GameNetworkRequest getUserSimpleInfo:SERVER_URL
//                                                                      appId:[ConfigManager appId] 
//                                                                     gameId:[ConfigManager gameId]
//                                                                   ByUserId:drawUserId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* sinaNick = nil;
            NSString* qqId = nil;
            
            if (output.resultCode == ERROR_SUCCESS) {
                sinaNick = [output.jsonDataDict objectForKey:PARA_SINA_NICKNAME];
                qqId = [output.jsonDataDict objectForKey:PARA_QQ_ID];
            }
            
            NSString* textForQQ = [self getWeiboText:TYPE_QQ drawUserNickName:qqId isDrawByMe:isDrawByMe drawWord:drawWord];
            [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] publishWeibo:textForQQ imageFilePath:imagePath successBlock:NULL failureBlock:NULL];
            
            NSString* textForSina = [self getWeiboText:TYPE_SINA drawUserNickName:sinaNick isDrawByMe:isDrawByMe drawWord:drawWord];
            [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] publishWeibo:textForSina imageFilePath:imagePath successBlock:NULL failureBlock:NULL];
            
            NSString* textForFacebook = [self getWeiboText:TYPE_FACEBOOK drawUserNickName:@"" isDrawByMe:isDrawByMe drawWord:drawWord];
            [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] publishWeibo:textForFacebook imageFilePath:imagePath successBlock:NULL failureBlock:NULL];

            /*
            if ([[UserManager defaultManager] hasBindQQWeibo]){
                NSString* textForQQ = [self getWeiboText:TYPE_QQ drawUserNickName:qqId isDrawByMe:isDrawByMe drawWord:drawWord];
                [[QQWeiboService defaultService] publishWeibo:textForQQ
                                                imageFilePath:imagePath 
                                                     delegate:nil];        
            }
            
            if ([[UserManager defaultManager] hasBindSinaWeibo] && [[SinaSNSService defaultService] isAuthorizeExpired] == NO){
                NSString* textForSina = [self getWeiboText:TYPE_SINA drawUserNickName:sinaNick isDrawByMe:isDrawByMe drawWord:drawWord];
                [[SinaSNSService defaultService] publishWeibo:textForSina
                                                imageFilePath:imagePath 
                                                     delegate:nil];
            }
            
            if ([[UserManager defaultManager] hasBindFacebook] && [[FacebookSNSService defaultService] isAuthorizeExpired] == NO){
                NSString* textForFacebook = [self getWeiboText:TYPE_FACEBOOK drawUserNickName:@"" isDrawByMe:isDrawByMe drawWord:drawWord];
                [[FacebookSNSService defaultService] publishWeibo:textForFacebook
                                                    imageFilePath:imagePath 
                                                         delegate:nil];                
            }
             */
        });
    });

}

- (void)shareWithImage:(UIImage*)image drawUserId:(NSString*)drawUserId isDrawByMe:(BOOL)isDrawByMe drawWord:(NSString*)drawWord
{
//    PPDebug(@"<shareWithImage> word=%@", drawWord);
//    
//    UIImage* background = [UIImage imageNamed:@"share_bg.png"];
//    UIImage* title = [UIImage imageNamed:@"name.png"];
//    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(48, 90, 224, 25)] autorelease];
//    if (isDrawByMe) {
//        [label setText:NSLS(@"kGuessWhatIDraw")];
//    } else {
//        [label setText:NSLS(@"kGuessWhatTheyDraw")];
//    }
//    
//    [label setTextAlignment:UITextAlignmentCenter];
//    UIGraphicsBeginImageContext(background.size);  
//    
//    [background drawInRect:CGRectMake(0, 0, background.size.width, background.size.height)];
//    [title drawInRect:CGRectMake(48, 8, 224, 95)];
//    [label drawTextInRect:CGRectMake(48, 90, 224, 25)];
//    [image drawInRect:CGRectMake(32, 136, 256, 245)];        
//    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage* resultingImage = [self synthesisWeiboImage:image text:@"@猜猜画画"];
    
    NSData* imageData = UIImagePNGRepresentation(resultingImage);
    NSString* path = [NSString stringWithFormat:@"%@/%@.png", NSTemporaryDirectory(), [NSString GetUUID]];
    BOOL result=[imageData writeToFile:path atomically:YES];
    if (!result) {
        PPDebug(@"creat temp image failed");
        return;
    }
    
    [self shareWeiboWithDrawUserId:drawUserId isDrawByMe:isDrawByMe drawWord:drawWord imagePath:path];    
}

#define SHADOW_WIDTH 5
#define SHADOW_BLUR  5

- (UIImage*)synthesisWeiboImage:(UIImage*)srcImage text:(NSString*)text
{
    float labelHeight = srcImage.size.height*0.07;
    int labelFontSize = (int)labelHeight;
    
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, srcImage.size.width + shadow*2, labelHeight)] autorelease];
    [label setText:text];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setMinimumFontSize:3];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    
    [label setFont:[UIFont boldSystemFontOfSize:labelFontSize]];
    [label setTextAlignment:UITextAlignmentCenter];
    
    UIGraphicsBeginImageContext(CGSizeMake(srcImage.size.width+SHADOW_WIDTH*2, srcImage.size.height + SHADOW_WIDTH + labelHeight));

    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ref, CGSizeMake(0, SHADOW_WIDTH), SHADOW_BLUR, [UIColor blackColor].CGColor);
    
    CGRect rect = CGRectMake(SHADOW_WIDTH, 0, srcImage.size.width, srcImage.size.height);
    [srcImage drawInRect:rect];
    
    //line of left
    CGContextSetShadow(ref, CGSizeMake(-SHADOW_WIDTH, 0), SHADOW_BLUR);

    //right line
    CGContextSetShadow(ref, CGSizeMake(SHADOW_WIDTH, 0), SHADOW_BLUR);

    CGContextSaveGState(ref);
    
    [label drawTextInRect:CGRectMake(0, srcImage.size.height+SHADOW_WIDTH, srcImage.size.width, labelHeight)];

    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(ref);
    return resultingImage;
}

- (void)shareImage:(UIImage*)srcImage
              text:(NSString*)text
         waterMark:(NSString*)waterMark
            viaSNS:(int)snsType
      successBlock:(PPSNSSuccessBlock)successBlock
      failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];

    NSString* path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [NSString GetUUID]];
    UIImage* image = [[ShareService defaultService] synthesisWeiboImage:srcImage text:waterMark];
    BOOL result=[[image data] writeToFile:path atomically:YES];
    if (result) {
        [snsService publishWeibo:text imageFilePath:path successBlock:successBlock failureBlock:failureBlock];
    } else {
        PPDebug(@"<ShareService> Save image to tempory file failed!");
    }

    return;
}

@end
