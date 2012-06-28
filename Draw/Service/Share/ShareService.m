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

@implementation ShareService

static ShareService* _defaultService;

+ (ShareService*)defaultService
{
    if (_defaultService == nil){
        _defaultService = [[ShareService alloc] init];
    }
    
    return _defaultService;
}

- (void)shareWithImage:(UIImage*)image isDrawByMe:(BOOL)isDrawByMe drawWord:(NSString*)drawWord
{
    PPDebug(@"<shareWithImage> word=%@", drawWord);
    
    NSString* text = @"";
    if (isDrawByMe){
        text = [NSString stringWithFormat:NSLS(@"kShareMeText"), drawWord];            
    }
    else{
        text = [NSString stringWithFormat:NSLS(@"kShareOtherText"), drawWord];
    }
    
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

    if ([[UserManager defaultManager] hasBindQQWeibo]){
        [[QQWeiboService defaultService] publishWeibo:text
                                        imageFilePath:path 
                                             delegate:nil];        
    }

    if ([[UserManager defaultManager] hasBindSinaWeibo]){
        [[SinaSNSService defaultService] publishWeibo:text 
                                        imageFilePath:path 
                                             delegate:nil];
    }

    if ([[UserManager defaultManager] hasBindFacebook]){
        [[FacebookSNSService defaultService] publishWeibo:text
                                            imageFilePath:path 
                                                 delegate:nil];                
    }
    
}

@end
