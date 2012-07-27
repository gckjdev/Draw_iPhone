//
//  ShareService.m
//  Draw
//
//  Created by  on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareService.h"
#import "SinaSNSService.h"
#import "QQWeiboService.h"
#import "FacebookSNSService.h"
#import "UserManager.h"
#import "StringUtil.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"
#import "PPNetworkRequest.h"

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
    NSString* appNick = @"";
    switch (snsType) {
        case TYPE_SINA:
            appNick = @"@猜猜画画手机版";
            break;
            
        case TYPE_QQ:
            appNick = @"@drawlively";
            break;
            
        default:
            break;
    }       
    
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
        text = [NSString stringWithFormat:NSLS(@"kShareOtherTextAuto"), appNick, drawWord, nick];                
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
                                                                      appId:[ConfigManager appId] 
                                                                     gameId:[ConfigManager gameId]
                                                                   ByUserId:drawUserId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* sinaNick = nil;
            NSString* qqId = nil;
            
            if (output.resultCode == ERROR_SUCCESS) {
                sinaNick = [output.jsonDataDict objectForKey:PARA_SINA_NICKNAME];
                qqId = [output.jsonDataDict objectForKey:PARA_QQ_ID];
            }            
            
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
        });
    });

}

- (void)shareWithImage:(UIImage*)image drawUserId:(NSString*)drawUserId isDrawByMe:(BOOL)isDrawByMe drawWord:(NSString*)drawWord
{
    PPDebug(@"<shareWithImage> word=%@", drawWord);
    
    UIImage* background = [UIImage imageNamed:@"share_bg.png"];
    UIImage* title = [UIImage imageNamed:@"name.png"];
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(48, 90, 224, 25)] autorelease];
    if (isDrawByMe) {
        [label setText:NSLS(@"kGuessWhatIDraw")];
    } else {
        [label setText:NSLS(@"kGuessWhatTheyDraw")];
    }
    
    [label setTextAlignment:UITextAlignmentCenter];
    UIGraphicsBeginImageContext(background.size);  
    
    [background drawInRect:CGRectMake(0, 0, background.size.width, background.size.height)];
    [title drawInRect:CGRectMake(48, 8, 224, 95)];
    [label drawTextInRect:CGRectMake(48, 90, 224, 25)];
    [image drawInRect:CGRectMake(32, 136, 256, 245)];        
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext(); 
    
    NSData* imageData = UIImagePNGRepresentation(resultingImage);
    NSString* path = [NSString stringWithFormat:@"%@/%@.png", NSTemporaryDirectory(), [NSString GetUUID]];
    BOOL result=[imageData writeToFile:path atomically:YES];
    if (!result) {
        PPDebug(@"creat temp image failed");
        return;
    }
    
    [self shareWeiboWithDrawUserId:drawUserId isDrawByMe:isDrawByMe drawWord:drawWord imagePath:path];    
}

@end
