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
//#import "TwoInputFieldView.h"
#import "BBSActionSheet.h"
#import "TwoInputFieldViewStyle2.h"
#import "ShareAction.h"

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

//TODO 将它放进Util包
//判断是否为整形：

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
//    PPDebug(@"%d",[scan scanInt:&val]);
//    PPDebug(@"%d",[scan isAtEnd]);
//    BOOL bb = [scan isAtEnd];
    return ([scan scanInt:&val]) && ([scan isAtEnd]);
}

//判断是否为浮点形：

- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

-(BOOL)accessibilityShareGifEnter:(NSString*)gifFrameCount scaleSize:(NSString*)scaleSize{
    if(![self isPureInt:gifFrameCount]){
        POSTMSG(NSLS(@"kGifIntWarning"));
        PPDebug(@"<showShareGifDialog> gifFrameCount isn't a int");
        return NO;
        
    }
    if(![self isPureFloat:scaleSize]){
        POSTMSG(NSLS(@"kScaleFloatWarning"));
        PPDebug(@"<showShareGifDialog> scaleSize isn't a float");
        return NO;
    }
    
   
    if([gifFrameCount intValue]<0){
        POSTMSG(NSLS(@"kGifCountWarning"));
        PPDebug(@"<showShareGifDialog> gifFrameCount can't less than 0");
        return NO;
    }
    if([scaleSize floatValue]>100||[scaleSize floatValue]<0){
        POSTMSG(NSLS(@"kScaleWarning"));
        PPDebug(@"<showShareGifDialog> scaleSize can't more than 100");
        return NO;
    }

    
    
    return YES;
}

- (void)showShareGifDialog:(PPViewController*)superController
                     draft:(MyPaint*)draft
{
    TwoInputFieldViewStyle2 *inputDialog =[TwoInputFieldViewStyle2 create];
    inputDialog.textFieldTitle1.text = NSLS(@"kPicSum");
    inputDialog.textFieldTitle2.text = NSLS(@"kPicScale");
    inputDialog.textFieldTitle1.font = AD_FONT(20, 13);
    inputDialog.textFieldTitle2.font = AD_FONT(20, 13);
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kShareGifDialogTitle")
                                                    customView:inputDialog
                                                         style:CommonDialogStyleDoubleButtonWithCross];
    
    //导出GIF 的分享功能
    [dialog.cancelButton setTitle:NSLS(@"kShare") forState:UIControlStateNormal];
    [dialog showInView:superController.view];
    
    [dialog setClickCancelBlock:^(TwoInputFieldViewStyle2 *infoView){
        if([self accessibilityShareGifEnter:inputDialog.textField1.text  scaleSize:inputDialog.textField2.text]){
            [self saveGif:superController draft:draft shareOrAlbum:YES gifFrameCount:[inputDialog.textField1.text intValue] scaleSize:[inputDialog.textField2.text floatValue]/100.f];
        }
        
    }];
    
    //导出GIF 的相册功能
    [dialog.oKButton setTitle:NSLS(@"kAlbum") forState:UIControlStateNormal];
    [dialog showInView:superController.view];
    
    [dialog setClickOkBlock:^(TwoInputFieldViewStyle2 *infoView){
        
        if([self accessibilityShareGifEnter:inputDialog.textField1.text  scaleSize:inputDialog.textField2.text]){
            [self saveGif:superController draft:draft shareOrAlbum:NO gifFrameCount:[inputDialog.textField1.text intValue] scaleSize:[inputDialog.textField2.text floatValue]/100.f];
        }
    }];

    
}

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
     completeBlock:(dispatch_block_t)completeBlock
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
    
    //默认值 图片个数30 图片比例50% 时间0.25
    int frameCount = [PPConfigManager getGIFFrameCount];
    float scaleSize = [PPConfigManager getGIFScaleSize];;
    float delayTime = [PPConfigManager getGIFDelayTime];
    
    UIImage* finalImage = opusImage;
    
    NSMutableArray* copyLayers = [NSMutableArray array];
    for (DrawLayer* layer in layers){
        DrawLayer* copyLayer = [DrawLayer layerWithLayer:layer frame:layer.frame];
        [copyLayers addObject:copyLayer];
    }
    
    NSString* shareText = NSLS(@"kShareGIFText");
    
    //后台运行creategif,主线程显示小苹果进程。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void){
                       
                       NSString* fileId = [opusId length] > 0 ? opusId : [NSString GetUUID];
                       NSString* fileName = [NSString stringWithFormat:@"%@.gif", fileId];
                       NSString* tempPath = [[FileUtil getAppTempDir] stringByAppendingPathComponent:fileName];
                       
                       [ShowDrawView createGIF:frameCount
                                     delayTime:delayTime
                                drawActionList:drawActionList
                                       bgImage:nil
                                        layers:copyLayers
                                    canvasSize:canvasSize
                                    finalImage:finalImage
                                    outputPath:tempPath
                                     scaleSize:scaleSize];
                       
                       dispatch_async(dispatch_get_main_queue(),
                                      ^(void){
                                          
                                          [superController unregisterNotificationWithName:NOTIFICATION_GIF_CREATION];
                                          [superController hideActivity];
                                          [superController hideProgressView];
                                          
                                          if ([FileUtil isPathExist:tempPath]){
                                              [self shareSNS:superController.view
                                                    drawWord:drawWord
                                                    drawDesc:drawDesc
                                                  drawUserId:drawUserId
                                                  drawOpusId:opusId
                                              drawUserGender:drawUserGender
                                               imageFilePath:tempPath
                                                   shareText:shareText
                                               completeBlock:completeBlock];
                                          }
                                          else{
                                              POSTMSG(NSLS(@"kCreateGIFFailure"));
                                              EXECUTE_BLOCK(completeBlock);
                                          }
                                          
                                          
                                      });
                       
                   });
    return;
}

//YES为share NO为Album
- (void)saveGif:(PPViewController*)superController
          draft:(MyPaint*)draft
   shareOrAlbum:(BOOL)shareOrAlbum
  gifFrameCount:(int)gifFrameCount
      scaleSize:(float)scaleSize
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
    
    //默认值 图片个数30 图片比例50% 时间0.25
    int _gifFrameCount = 30;
    if (gifFrameCount!=0){
        _gifFrameCount = gifFrameCount;
    }
    float _scaleSize = 0.5f;
    if (scaleSize!=0){
        _scaleSize = scaleSize;
    }
    float delayTime = [PPConfigManager getGIFDelayTime];
   
    UIImage* finalImage = draft.paintImage;
    
    //后台运行creategif,主线程显示小苹果进程。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void){
                       
                       NSString* fileId = [draft.draftId length] > 0 ? draft.draftId : [NSString GetUUID];
                       NSString* fileName = [NSString stringWithFormat:@"%@.gif", fileId];
                       NSString* tempPath = [[FileUtil getAppTempDir] stringByAppendingPathComponent:fileName];
                       
                       [ShowDrawView createGIF:_gifFrameCount
                                     delayTime:delayTime
                                drawActionList:draft.drawActionList
                                       bgImage:nil
                                        layers:draft.layers
                                    canvasSize:draft.canvasSize
                                    finalImage:finalImage
                                    outputPath:tempPath
                                     scaleSize:_scaleSize];
                       
                       dispatch_async(dispatch_get_main_queue(),
                                      ^(void){
                                          
                                          
                                          [superController unregisterNotificationWithName:NOTIFICATION_GIF_CREATION];
                                          [superController hideActivity];
                                          [superController hideProgressView];
                                          
                                          if ([FileUtil isPathExist:tempPath]){
                                              if(shareOrAlbum){
                                                  [self shareSNS:superController.view
                                                        drawWord:draft.drawWord
                                                        drawDesc:draft.opusDesc
                                                      drawUserId:draft.drawUserId
                                                      drawOpusId:draft.opusId
                                                  drawUserGender:[[UserManager defaultManager] boolGender]
                                                   imageFilePath:tempPath
                                                       shareText:nil
                                                   completeBlock:nil];
                                              }
                                              else{
                                                  [self saveAlbumWithPath:tempPath];
                                              }
                                          }
                                          else{
                                              POSTMSG(NSLS(@"kCreateGIFFailure"));
                                          }
                                          
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

#pragma mark - shareDialog TODO Util
//- (NSString*)createShareText
//{
//    NSString* shareText = [NSString stringWithFormat:NSLS(@"kConquerDrawShareText"),
//                           [PPConfigManager shareAppName],
//                           self.score,
//                           self.userStage.defeatCount];
//    PPDebug(@"<createShareText> text=%@", shareText);
//    return shareText;
//}

#define TITLE_SHARE_WEIXIN_FRIEND   NSLS(@"kConquerDrawShareWeixinFriend")
#define TITLE_SHARE_WEIXIN_TIMELINE NSLS(@"kConquerDrawSharekWeixinTimeline")
#define TITLE_SHARE_SINA_WEIBO      NSLS(@"kConquerDrawShareSinaWeibo")
#define TITLE_SHARE_QQ_WEIBO        NSLS(@"kConquerDrawShareQQWeibo")
#define ADD_HEIGHT                  (ISIPAD ? 26 : 13)
- (void)shareSNS:(UIView*)superView
        drawWord:(NSString*)drawWord
        drawDesc:(NSString*)drawDesc
      drawUserId:(NSString*)drawUserId
      drawOpusId:(NSString*)drawOpusId
  drawUserGender:(BOOL)drawUserGender
   imageFilePath:(NSString*)imageFilePath
       shareText:(NSString*)shareText
   completeBlock:(dispatch_block_t)completeBlock
{
    
    NSString* _imageFilePath = imageFilePath;
    
//    if ([imageFilePath length] == 0){
//        POSTMSG(NSLS(@"kCreateImageShareFail"));
//        return;
//    }
    
    NSArray *titles = @[TITLE_SHARE_WEIXIN_FRIEND,
                        TITLE_SHARE_WEIXIN_TIMELINE,
                        TITLE_SHARE_SINA_WEIBO,
                        TITLE_SHARE_QQ_WEIBO];
    
    BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:titles callback:^(NSInteger index) {
        NSString *t = titles[index];
        if ([t isEqualToString:TITLE_SHARE_WEIXIN_FRIEND]) {
            
            NSString* _text = [ShareAction createShareText:drawWord
                                                     desc:drawDesc
                                               opusUserId:drawUserId
                                               userGender:drawUserGender
                                                  snsType:TYPE_WEIXIN_SESSION
                                                   opusId:drawOpusId
                                                     isGIF:YES];
            
            if ([shareText length] > 0){
                _text = shareText;
            }
            
            [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_SESSION
                                                     text:_text
                                            imageFilePath:_imageFilePath
                                                   inView:superView
                                               awardCoins:[PPConfigManager getShareWeiboReward]
                                           successMessage:NSLS(@"kShareWeiboSucc")
                                           failureMessage:NSLS(@"kShareWeiboFailure")];
            
        }else if([t isEqualToString:TITLE_SHARE_WEIXIN_TIMELINE]){
            
            NSString* _text = [ShareAction createShareText:drawWord
                                                      desc:drawDesc
                                                opusUserId:drawUserId
                                                userGender:drawUserGender
                                                   snsType:TYPE_WEIXIN_TIMELINE
                                                    opusId:drawOpusId
                                                     isGIF:YES];
            
            if ([shareText length] > 0){
                _text = shareText;
            }
            
            [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_TIMELINE
                                                     text:_text
                                            imageFilePath:_imageFilePath
                                                   inView:superView
                                               awardCoins:[PPConfigManager getShareWeiboReward]
                                           successMessage:NSLS(@"kShareWeiboSucc")
                                           failureMessage:NSLS(@"kShareWeiboFailure")];
            
        }
        else if([t isEqualToString:TITLE_SHARE_SINA_WEIBO]){
            
            NSString* _text = [ShareAction createShareText:drawWord
                                                      desc:drawDesc
                                                opusUserId:drawUserId
                                                userGender:drawUserGender
                                                   snsType:TYPE_SINA
                                                    opusId:drawOpusId
                                                     isGIF:YES];
            
            if ([shareText length] > 0){
                _text = shareText;
            }

            [[GameSNSService defaultService] publishWeibo:TYPE_SINA
                                                     text:_text
                                            imageFilePath:_imageFilePath
                                                   inView:superView
                                               awardCoins:[PPConfigManager getShareWeiboReward]
                                           successMessage:NSLS(@"kShareWeiboSucc")
                                           failureMessage:NSLS(@"kShareWeiboFailure")];
            
            
        }
        else if([t isEqualToString:TITLE_SHARE_QQ_WEIBO]){
            
            NSString* _text = [ShareAction createShareText:drawWord
                                                      desc:drawDesc
                                                opusUserId:drawUserId
                                                userGender:drawUserGender
                                                   snsType:TYPE_QQ
                                                    opusId:drawOpusId
                                                     isGIF:YES];
            
            if ([shareText length] > 0){
                _text = shareText;
            }
            
            [[GameSNSService defaultService] publishWeibo:TYPE_QQ
                                                     text:_text
                                            imageFilePath:_imageFilePath
                                                   inView:superView
                                               awardCoins:[PPConfigManager getShareWeiboReward]
                                           successMessage:NSLS(@"kShareWeiboSucc")
                                           failureMessage:NSLS(@"kShareWeiboFailure")];
            
        }
        
        EXECUTE_BLOCK(completeBlock);
    }];
    [sheet showInView:superView showAtPoint:superView.center animated:YES];
    [sheet release];
}


@end
