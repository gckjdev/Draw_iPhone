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
#import "PPConfigManager.h"
#import "PPNetworkRequest.h"
#import "PPSNSConstants.h"
//#import "PPSNSIntegerationService.h"
#import "GameSNSService.h"
#import "UIImageExt.h"
#import "RoundLineLabel.h"
#import "WordManager.h"
#import "Word.h"
#import "ShowDrawView.h"
#import "MyPaint.h"
#import "FileUtil.h"
#import "MyPaintManager.h"

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
          drawUserSNSNick:(NSString*)drawUserSNSNick
               isDrawByMe:(BOOL)isDrawByMe 
                 drawWord:(NSString*)drawWord
           drawUserGender:(BOOL)gender
{
//    NSString* snsOfficialNick = [GameSNSService snsOfficialNick:snsType];
//    NSArray* wordArray = [[WordManager defaultManager] randDrawWordList];
//    NSMutableArray* array2 = [NSMutableArray arrayWithArray:wordArray];
//    [array2 insertObject:[Word wordWithText:drawWord level:0] atIndex:(rand()%3)];
    NSString* heStr = gender?NSLS(@"kHim"):NSLS(@"kHer");
    NSString* appNick = [GameSNSService snsOfficialNick:snsType];
    if (appNick == nil)
        appNick = @"";
    
    if (drawWord == nil)
        drawWord = @"";
    
    NSString* text = @"";
    if (isDrawByMe){
        text = [NSString stringWithFormat:NSLS(@"kShareMyOpusWithoutDescriptionText"),  appNick, drawWord, [PPConfigManager getSNSShareSubject], [PPConfigManager getAppItuneLink]];
    }
    else{
        NSString* nick = nil;
        if (drawUserSNSNick && [drawUserSNSNick length] > 0){
            nick = [NSString stringWithFormat:@"@%@", drawUserSNSNick];
        }
        else{
            nick = drawUserNickName;
        }
        text = [NSString stringWithFormat:NSLS(@"kShareOtherOpusWithoutDescriptionText"), heStr, appNick, drawWord, [PPConfigManager getSNSShareSubject], [PPConfigManager getAppItuneLink]];
        text = [text stringByAppendingFormat:NSLS(@"kPaintVia"), nick];
    }
//    text = [NSString stringWithFormat:NSLS(@"kWeiboShareMessage"), snsOfficialNick, ((Word*)[array2 objectAtIndex:0]).text, ((Word*)[array2 objectAtIndex:1]).text, ((Word*)[array2 objectAtIndex:2]).text, ((Word*)[array2 objectAtIndex:3]).text];
    
    PPDebug(@"Share Weibo Text=%@, user nick = %@, sns nick = %@", text, drawUserNickName, drawUserSNSNick);
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
                                                                      appId:[PPConfigManager appId]
                                                                     gameId:[PPConfigManager gameId]
                                                                   ByUserId:drawUserId];
        
//        CommonNetworkOutput* output = [GameNetworkRequest getUserSimpleInfo:SERVER_URL
//                                                                      appId:[PPConfigManager appId] 
//                                                                     gameId:[PPConfigManager gameId]
//                                                                   ByUserId:drawUserId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* nickName = nil;
            NSString* sinaNick = nil;
            NSString* qqId = nil;
            BOOL gender = YES;
            
            if (output.resultCode == ERROR_SUCCESS) {
                sinaNick = [output.jsonDataDict objectForKey:PARA_SINA_NICKNAME];
                qqId = [output.jsonDataDict objectForKey:PARA_QQ_ID];
                nickName = [output.jsonDataDict objectForKey:PARA_NICKNAME];
                NSString* genderStr = [output.jsonDataDict objectForKey:PARA_GENDER];
                gender = [@"m" isEqualToString:genderStr];
            }
            
            NSString* textForQQ = [self getWeiboText:TYPE_QQ drawUserNickName:nickName drawUserSNSNick:qqId isDrawByMe:isDrawByMe drawWord:drawWord drawUserGender:gender];

            [[GameSNSService defaultService] publishWeiboAtBackground:TYPE_QQ
                                                                 text:textForQQ
                                                        imageFilePath:imagePath
                                                           awardCoins:[PPConfigManager getShareWeiboReward]
                                                       successMessage:NSLS(@"kShareWeiboSucc")
                                                       failureMessage:NSLS(@"kShareWeiboFailure")];
            
            NSString* textForSina = [self getWeiboText:TYPE_SINA drawUserNickName:nickName drawUserSNSNick:sinaNick isDrawByMe:isDrawByMe drawWord:drawWord drawUserGender:gender];
            [[GameSNSService defaultService] publishWeiboAtBackground:TYPE_SINA
                                                                 text:textForSina
                                                        imageFilePath:imagePath
                                                           awardCoins:[PPConfigManager getShareWeiboReward]
                                                       successMessage:NSLS(@"kShareWeiboSucc")
                                                       failureMessage:NSLS(@"kShareWeiboFailure")];
            
            
            NSString* textForFacebook = [self getWeiboText:TYPE_FACEBOOK drawUserNickName:nickName drawUserSNSNick:nil isDrawByMe:isDrawByMe drawWord:drawWord drawUserGender:gender];
            [[GameSNSService defaultService] publishWeiboAtBackground:TYPE_FACEBOOK
                                                                 text:textForFacebook
                                                        imageFilePath:imagePath
                                                           awardCoins:[PPConfigManager getShareWeiboReward]
                                                       successMessage:NSLS(@"kShareWeiboSucc")
                                                       failureMessage:NSLS(@"kShareWeiboFailure")];
            

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
    UIImage* resultingImage = [self synthesisImage:image waterMarkText:[PPConfigManager getShareImageWaterMark]];
    
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
    
    if (labelFontSize > 25){
        labelFontSize = 25;
    }
    
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
    
    CGContextRestoreGState(ref);

    // draw text
    [label drawTextInRect:CGRectMake(0, srcImage.size.height+SHADOW_WIDTH*2, srcImage.size.width, labelHeight)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    return resultingImage;
}

- (NSString*)synthesisImageWithImage:(UIImage*)sourceImage waterMarkText:(NSString*)text
{
    NSString* path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [NSString GetUUID]];
    UIImage* image = sourceImage;
    if ([text length] > 0){
        image = [self synthesisImage:sourceImage waterMarkText:text];
    }
    
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

- (void)saveGif:(PPViewController*)superController
          draft:(MyPaint*)draft
{
    [superController showActivityWithText:NSLS(@"kSaving")];
    
    [superController registerNotificationWithName:NOTIFICATION_GIF_CREATION usingBlock:^(NSNotification *note) {
        float progress = [[[note userInfo] objectForKey:KEY_DATA_PARSING_PROGRESS] floatValue];
        //        PPDebug(@"handle data parsing notification, progress = %f", progress);
        NSString* progressText = @"";
        if (progress == 1.0f){
            progress = 0.99f;
            progressText = [NSString stringWithFormat:NSLS(@"kCreateGIFProgress"), (int)(progress*100)];
        }
        else{
            progressText = [NSString stringWithFormat:NSLS(@"kCreateGIFProgress"), (int)(progress*100)];
        }
        [superController showProgressViewWithMessage:progressText progress:progress];
    }];
    
    int gifFrameCount = 30;
    float delayTime = 0.25f;
    float scaleSize = 0.5f;
    UIImage* finalImage = draft.paintImage;
    
    //后台运行creategif,主线程显示小苹果进程。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void){
                       
                       NSString* fileName = [NSString stringWithFormat:@"%@.gif", [NSString GetUUID]];
                       NSString* tempPath = [[FileUtil getAppTempDir] stringByAppendingPathComponent:fileName];
                       
                       [ShowDrawView createGIF:gifFrameCount
                                     delayTime:delayTime
                                drawActionList:draft.drawActionList
                                       bgImage:nil
                                        layers:draft.layers
                                    canvasSize:draft.canvasSize
                                    finalImage:finalImage
                                    outputPath:tempPath
                                     scaleSize:scaleSize];
                       
                       // TODO remove file after generation
                       //                       [FileUtil removeFile:tempPath];
                       
                       dispatch_async(dispatch_get_main_queue(),
                                      ^(void){
                                          [superController unregisterNotificationWithName:NOTIFICATION_GIF_CREATION];
                                          [superController hideActivity];
                                          [superController hideProgressView];
                                          
                                          [self saveAlbumWithPath:tempPath];
                                      });
                       
                   });
    return;
}

- (void)saveAlbumWithPath:(NSString*)path
{
//    [superController showActivityWithText:NSLS(@"kSaving")];
    [[MyPaintManager defaultManager] savePhoto:path delegate:self];
}

#pragma mark - MyPaintManager delegate

- (void)didSaveToAlbumSuccess:(BOOL)succ
{
//    [self hideActivity];
    if (succ) {
        POSTMSG(NSLS(@"kSaveToAlbumSuccess"));
    }
}

@end
