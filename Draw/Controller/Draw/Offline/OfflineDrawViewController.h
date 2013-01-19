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
#import "CommonItemInfoView.h"

@class Word;
@class ShareImageManager;
@class MyPaint;
@class Contest;
@class OfflineDrawViewController;

@protocol OfflineDrawDelegate <NSObject>

@optional
- (void)didControllerClickBack:(OfflineDrawViewController *)controller;
- (void)didController:(OfflineDrawViewController *)controller
     submitActionList:(NSMutableArray*)drawActionList
            drawImage:(UIImage *)drawImage;

@end


@interface OfflineDrawViewController : PPViewController<DrawViewDelegate,CommonDialogDelegate,DrawDataServiceDelegate,LevelServiceDelegate, DrawToolPanelDelegate, CommonItemInfoViewDelegate> {
    
}

- (IBAction)clickSubmitButton:(id)sender;
- (IBAction)clickDraftButton:(id)sender;



@property (retain, nonatomic) Word *word;

@property (assign, nonatomic) id<OfflineDrawDelegate> delegate;
@property (retain, nonatomic) NSString *targetUid;
@property (retain, nonatomic) Contest *contest;
@property (assign, nonatomic) UIViewController *startController;

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

/*
+ (OfflineDrawViewController *)startDraw:(Word *)word fromController:(UIViewController*)fromController;

+ (OfflineDrawViewController *)startDraw:(Word *)word
   fromController:(UIViewController*)fromController
        targetUid:(NSString *)targetUid;
*/
@end

