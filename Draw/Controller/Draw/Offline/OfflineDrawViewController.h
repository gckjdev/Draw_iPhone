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

@class Word;
@class ShareImageManager;
@class MyPaint;
@class Contest;
@class OfflineDrawViewController;
@class OpusDesignTime;

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

- (IBAction)clickLayerButton:(id)sender;
- (void)showCopyPaint;

@property (retain, nonatomic) Word *word;                       // 画画主题单词 CAN REMOVE
@property (retain, nonatomic) OpusDesignTime *designTime;       // 画画耗费时间
@property (assign, nonatomic) int64_t totalStroke;              // 画画笔画数目 CAN REMOVE
@property (retain, nonatomic) NSArray *selectedClassList;       // 画画分类 CAN REMOVE
@property (retain, nonatomic) NSString *targetUid;              // 画给谁 CAN REMOVE
@property (retain, nonatomic) NSString *opusDesc;               // 画画描述 CAN REMOVE
@property (retain, nonatomic) UIImage *bgImage;                 // 画画底部背景图片 CAN REMOVE
@property (retain, nonatomic) NSString *bgImageName;            // 画画背景图片的名称 CAN REMOVE

@property (assign, nonatomic) id<OfflineDrawDelegate> delegate;
@property (retain, nonatomic) Contest *contest;                 // 比赛对象
@property (assign, nonatomic) UIViewController *startController;// 来自哪个控制器

@property (retain, nonatomic) UIImage *submitOpusFinalImage;    // 提交作品的图片（临时）
@property (retain, nonatomic) NSData *submitOpusDrawData;       // 提交作品的数据（临时）

@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;

- (id)initWithTargetType:(TargetType)aTargetType 
                delegate:(id<OfflineDrawDelegate>)aDelegate;

- (id)initWithWord:(Word *)word 
              lang:(LanguageType)lang;

- (id)initWithDraft:(MyPaint *)draft;

- (id)initWithWord:(Word *)word
              lang:(LanguageType)lang 
         targetUid:(NSString *)targetUid;

- (id)initWithContest:(Contest *)contest;

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
                                   photo:(UIImage *)photo;

- (void)setPageBGImage:(UIImage *)image;
- (void)saveCopyPaintImage:(UIImage*)image;
- (UIImage*)getCopyPaintImage;
+ (UIImage*)getDefaultCopyPaintImage;

@end

