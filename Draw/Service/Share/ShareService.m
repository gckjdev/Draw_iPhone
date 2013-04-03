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
#import "RoundLineLabel.h"
#import "WordManager.h"
#import "Word.h"

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
//    NSString* snsOfficialNick = [GameSNSService snsOfficialNick:snsType];
    NSArray* wordArray = [[WordManager defaultManager] randDrawWordList];
    NSMutableArray* array2 = [NSMutableArray arrayWithArray:wordArray];
    [array2 insertObject:[Word wordWithText:drawWord level:0] atIndex:(rand()%3)];
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
//    text = [NSString stringWithFormat:NSLS(@"kWeiboShareMessage"), snsOfficialNick, ((Word*)[array2 objectAtIndex:0]).text, ((Word*)[array2 objectAtIndex:1]).text, ((Word*)[array2 objectAtIndex:2]).text, ((Word*)[array2 objectAtIndex:3]).text];
    
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
    UIImage* resultingImage = [self synthesisImage:image waterMarkText:[ConfigManager getShareImageWaterMark]];
    
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
#define SHADOW_BLUR  10

- (UIImage*)synthesisImage:(UIImage*)srcImage waterMarkText:(NSString*)text
{
    if (text == nil) {
        return srcImage;
    }
    float labelHeight = srcImage.size.height*0.05;
    int labelFontSize = (int)labelHeight;
    UIColor* imageShadowColor = [UIColor colorWithRed:112/255.0 green:109/255.0 blue:109/255.0 alpha:1.0];
//    UIColor* labelShadowColor = [UIColor colorWithRed:108/255.0 green:107/255.0 blue:107/255.0 alpha:1.0];
    
    RoundLineLabel* label = [[[RoundLineLabel alloc] initWithFrame:CGRectMake(0, 0, srcImage.size.width + shadow*2, labelHeight)] autorelease];
    [label setText:text];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setMinimumFontSize:3];
    [label setTextColor:[UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0]];
    
    [label setFont:[UIFont boldSystemFontOfSize:labelFontSize]];
    [label setTextAlignment:UITextAlignmentCenter];
    
    UIGraphicsBeginImageContext(CGSizeMake(srcImage.size.width+SHADOW_WIDTH*2, srcImage.size.height + SHADOW_WIDTH*3 + labelHeight));

    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ref);    

   
    
    //line of left
    CGContextSetShadowWithColor(ref, CGSizeMake(-SHADOW_WIDTH, 0), SHADOW_BLUR, imageShadowColor.CGColor);
    //right line
    CGContextSetShadowWithColor(ref, CGSizeMake(SHADOW_WIDTH, 0), SHADOW_BLUR, imageShadowColor.CGColor);
    CGContextSetShadowWithColor(ref, CGSizeMake(0, SHADOW_WIDTH), SHADOW_BLUR, imageShadowColor.CGColor);

    // draw image with shadow
    CGRect rect = CGRectMake(SHADOW_WIDTH, 0, srcImage.size.width, srcImage.size.height);
    [srcImage drawInRect:rect];
    
//    [label drawTextInRect:CGRectMake(0, srcImage.size.height+SHADOW_WIDTH*2, srcImage.size.width, labelHeight)];
    [label drawTextInRect:CGRectMake(0, srcImage.size.height+SHADOW_WIDTH*2, srcImage.size.width, labelHeight)];
    

    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(ref);
    return resultingImage;
}

- (NSString*)synthesisImageWithImage:(UIImage*)sourceImage waterMarkText:(NSString*)text
{
    NSString* path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [NSString GetUUID]];
    UIImage* image = [self synthesisImage:sourceImage waterMarkText:text];
    BOOL result=[[image data] writeToFile:path atomically:YES];
    if (result) {
        return path;
    }
    return nil;
}

- (NSString*)synthesisImageFile:(NSString*)filePath waterMarkText:(NSString*)text
{
    NSString* path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [NSString GetUUID]];
    UIImage* image = [self synthesisImage:[UIImage imageWithContentsOfFile:filePath] waterMarkText:text];
    BOOL result=[[image data] writeToFile:path atomically:YES];
    if (result) {
        return path;
    }
    return nil;
}

@end
