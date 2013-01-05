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


@interface OfflineDrawViewController : PPViewController<DrawViewDelegate,CommonDialogDelegate,DrawDataServiceDelegate,LevelServiceDelegate, DrawToolPanelDelegate> {
    
}

- (IBAction)clickSubmitButton:(id)sender;
- (IBAction)clickDraftButton:(id)sender;



@property (retain, nonatomic) Word *word;

@property (assign, nonatomic) id<OfflineDrawDelegate> delegate;
@property (retain, nonatomic) NSString *targetUid;
@property (retain, nonatomic) Contest *contest;

+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController;

- (id)initWithTargetType:(TargetType)aTargetType 
                delegate:(id<OfflineDrawDelegate>)aDelegate;

- (id)initWithWord:(Word *)word 
              lang:(LanguageType)lang;

- (id)initWithDraft:(MyPaint *)draft;

+ (void)startDraw:(Word *)word 
   fromController:(UIViewController*)fromController 
        targetUid:(NSString *)targetUid;

- (id)initWithWord:(Word *)word
              lang:(LanguageType)lang 
         targetUid:(NSString *)targetUid;

- (id)initWithContest:(Contest *)contest;
+ (void)startDrawWithContest:(Contest *)contest    
              fromController:(UIViewController*)fromController
                    animated:(BOOL)animated;

@end

