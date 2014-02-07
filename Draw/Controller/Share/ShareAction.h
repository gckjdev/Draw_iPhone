//
//  ShareAction.h
//  Draw
//
//  Created by  on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "CustomActionSheet.h"
#import "ShareEditController.h"
#import "DrawDataService.h"
#import "MyPaintManager.h"

@class Opus;
@class DrawFeed;

@interface ShareAction : NSObject<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CustomActionSheetDelegate, ShareEditControllerDelegate, DrawDataServiceDelegate, MyPaintManagerDelegate>

@property (nonatomic, retain) PPViewController<UserServiceDelegate>* superViewController;
@property (nonatomic, copy) NSString* drawWord;
@property (nonatomic, copy) NSString* imageFilePath;
@property (nonatomic, assign) BOOL isDrawByMe;
@property (nonatomic, assign) BOOL isGIF;
@property (nonatomic, retain) NSString* drawUserId;
@property (nonatomic, retain) DrawFeed* feed;
@property (nonatomic, retain) UIImage* image;

+ (NSString*)createShareText:(NSString*)word
                        desc:(NSString*)desc
                  opusUserId:(NSString*)opusUserId
                  userGender:(BOOL)userGender
                     snsType:(SnsType)type
                      opusId:(NSString*)opusId;

+ (NSString*)shareTextByDrawFeed:(DrawFeed*)feed snsType:(SnsType)type;
+ (NSString*)shareTextByOpus:(Opus*)opus snsType:(SnsType)type;

+ (NSString*)createFeedImagePath:(DrawFeed*)feed;
+ (NSString*)createOpusImagePath:(Opus*)opus;

- (id)initWithDrawImageFile:(NSString*)imageFilePath
                      isGIF:(BOOL)isGIF
                   drawWord:(NSString*)drawWord
                       isMe:(BOOL)isDrawByMe;

- (id)initWithDrawImageFile:(NSString*)imageFilePath 
                      isGIF:(BOOL)isGIF 
                   drawWord:(NSString*)drawWord 
                 drawUserId:(NSString*)drawUserId;

- (id)initWithFeed:(DrawFeed*)feed
             image:(UIImage*)image;


- (void)displayWithViewController:(PPViewController<UserServiceDelegate>*)superViewController;
- (void)displayWithViewController:(PPViewController<UserServiceDelegate>*)superViewController onView:(UIView*)view;

- (void)saveToLocal;
- (void)saveAlbum;
@end
