//
//  DrawViewController.h
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawView.h"
#import "DrawGameService.h"
#import "CommonDialog.h"
#import "PPViewController.h"
#import "UserManager.h"
#import "DrawDataService.h"
#import "DrawConstants.h"
#import "LevelService.h"
#import "DrawToolPanel.h"
#import "MyFriend.h"
#import "UserService.h"
#import "CMPopTipView.h"
#import "DrawToolPanel.h"
#import "PPConfigManager.h"

@class Word;
@class ShareImageManager;
@class MyPaint;
@class Contest;
@class OfflineDrawViewController;
@class OpusDesignTime;
@class PBUserStage;
@class PBUserTutorial;

@protocol OfflineDrawDelegate <NSObject>

@optional
- (void)didControllerClickBack:(OfflineDrawViewController *)controller;
- (void)didController:(OfflineDrawViewController *)controller
     submitActionList:(NSMutableArray*)drawActionList
           canvasSize:(CGSize)size
            drawImage:(UIImage *)drawImage;
- (void)didController:(OfflineDrawViewController *)controller
          submitImage:(UIImage *)image;

@end


@interface OfflineDrawViewController : PPViewController<DrawViewDelegate,CommonDialogDelegate,DrawDataServiceDelegate,LevelServiceDelegate, UserServiceDelegate, DrawLayerManagerDelegate, CMPopTipViewDelegate, DrawToolPanelDelegate> {
    
}

- (IBAction)clickSubmitButton:(id)sender;
- (IBAction)clickDraftButton:(id)sender;
- (IBAction)clickUpPanel:(id)sender;
- (IBAction)clickHelpButton:(id)sender;
- (IBAction)clickLayerButton:(id)sender;
- (void)showCopyPaint;

@property (retain, nonatomic) OpusDesignTime *designTime;       // 画画耗费时间
@property (retain, nonatomic) NSArray *selectedClassList;       // 画画分类
@property (retain, nonatomic) UIImage *bgImage;                 // 画画底部背景图片 CAN REMOVE
@property (retain, nonatomic) NSString *bgImageName;            // 画画背景图片的名称 CAN REMOVE

@property (assign, nonatomic) id<OfflineDrawDelegate> delegate;
@property (retain, nonatomic) Contest *contest;                 // 比赛对象
@property (assign, nonatomic) PPViewController *startController;// 来自哪个控制器

@property (retain, nonatomic) UIImage *submitOpusFinalImage;    // 提交作品的图片（临时）
@property (retain, nonatomic) NSData *submitOpusDrawData;       // 提交作品的数据（临时）

@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;

- (id)initWithTargetType:(TargetType)aTargetType 
                delegate:(id<OfflineDrawDelegate>)aDelegate
         startController:(UIViewController*)startController;

- (id)initWithDraft:(MyPaint *)draft
    startController:(UIViewController*)startController;

//static method
+ (OfflineDrawViewController *)startDrawWithContest:(Contest *)contest
              fromController:(UIViewController*)fromController
            startController:(UIViewController*)startController
                    animated:(BOOL)animated;

+ (OfflineDrawViewController *)startDraw:(Word *)word
                          fromController:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                               targetUid:(NSString *)targetUid;

+ (OfflineDrawViewController *)startDraw:(Word *)word
                          fromController:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                               targetUid:(NSString *)targetUid
                                   photo:(UIImage *)photo
                                animated:(BOOL)animated;

+ (OfflineDrawViewController *)startDraw:(Word *)word
                          fromController:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                               targetUid:(NSString *)targetUid
                                   photo:(UIImage *)photo;

+ (OfflineDrawViewController*)practice:(UIViewController*)startController
                             userStage:(PBUserStage*)userStage
                          userTutorial:(PBUserTutorial*)userTutorial;

+ (OfflineDrawViewController*)conquer:(UIViewController*)startController
                            userStage:(PBUserStage*)userStage
                         userTutorial:(PBUserTutorial*)userTutorial;

+ (OfflineDrawViewController *)startDrawOnPhoto:(UIViewController*)startController
                                        bgImage:(UIImage*)bgImage;

- (id)initWithTargetType:(TargetType)aTargetType
                delegate:(id<OfflineDrawDelegate>)aDelegate
         startController:(UIViewController*)startController
                 Contest:(Contest*)contest
            targetUserId:(NSString*)targetUserId
                 bgImage:(UIImage*)bgImage;

- (void)setPageBGImage:(UIImage *)image;
- (void)saveCopyPaintImage:(UIImage*)image;
- (UIImage*)getCopyPaintImage;
+ (UIImage*)getDefaultCopyPaintImage;

- (NSString*)opusSubject;
- (NSString*)opusDesc;
- (void)setOpusDesc:(NSString *)opusDesc;
- (void)setOpusSubject:(NSString *)opusSubject;
- (void)setTargetUid:(NSString *)targetUid;

+ (OfflineDrawViewController *)startDraw:(UIViewController*)fromController
                         startController:(UIViewController*)startController
                                 bgImage:(UIImage*)bgImage;

@end

