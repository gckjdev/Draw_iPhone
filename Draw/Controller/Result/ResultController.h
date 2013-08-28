//
//  ResultController.h
//  Draw
//
//  Created by  on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawGameService.h"
#import "PPViewController.h"
#import "LevelService.h"
#import "DrawDataService.h"
#import "CommonDialog.h"
#import "UserService.h"
#import "CommonTitleView.h"

@class DrawFeed;
@class UseItemScene;

typedef enum {
    OnlineDraw = 0x1,
    OnlineGuess = 0x1 << 1,
    OfflineGuess = 0x1 << 2,
    FeedGuess = 0x1 << 3
} ResultType;

@interface ResultController : PPViewController<DrawGameServiceDelegate, LevelServiceDelegate,DrawDataServiceDelegate, CommonDialogDelegate, UserServiceDelegate>
{
    UIImage * _image;
    NSArray * _paintList;
    NSTimer *continueTimer;
    NSInteger retainCount;
    DrawGameService *drawGameService;
    BOOL _correct;
    BOOL _isMyPaint;
    NSArray *_drawActionList;
    ResultType _resultType;
    
    DrawFeed* _feed;
}
@property (retain, nonatomic) IBOutlet UIButton *upButton;
@property (retain, nonatomic) IBOutlet UIButton *downButton;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;

@property (retain, nonatomic) NSString *wordText;
@property (retain, nonatomic) NSString *drawUserId;
@property (retain, nonatomic) NSString *drawUserNickName;
@property (assign, nonatomic) NSInteger score;

@property (retain, nonatomic) IBOutlet UILabel *wordLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
@property (retain, nonatomic) IBOutlet UIImageView *whitePaper;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) NSArray *drawActionList;
@property (retain, nonatomic) UIView  *adView;
@property (retain, nonatomic) IBOutlet UILabel *experienceLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *upLabel;
@property (retain, nonatomic) IBOutlet UILabel *downLabel;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;

- (IBAction)clickUpButton:(id)sender;
- (IBAction)clickDownButton:(id)sender;
- (IBAction)clickContinueButton:(id)sender;
- (IBAction)clickSaveButton:(id)sender;
- (IBAction)clickExitButton:(id)sender;


@property (retain, nonatomic) IBOutlet UIImageView *drawImage;
@property (retain, nonatomic) UseItemScene  *useItemScene;

- (id)initWithImage:(UIImage *)image 
         drawUserId:(NSString *)drawUserId
   drawUserNickName:(NSString *)drawUserNickName
           wordText:(NSString *)aWordText 
              score:(NSInteger)aScore 
            correct:(BOOL)correct 
          isMyPaint:(BOOL)isMyPaint 
     drawActionList:(NSArray *)drawActionList;

- (id)initWithImage:(UIImage *)image 
         drawUserId:(NSString *)drawUserId
   drawUserNickName:(NSString *)drawUserNickName
           wordText:(NSString *)aWordText 
              score:(NSInteger)aScore 
            correct:(BOOL)correct 
          isMyPaint:(BOOL)isMyPaint 
     drawActionList:(NSArray *)drawActionList 
               feed:(Feed*)feed;

- (id)initWithImage:(UIImage *)image
         drawUserId:(NSString *)drawUserId
   drawUserNickName:(NSString *)drawUserNickName
           wordText:(NSString *)aWordText
              score:(NSInteger)aScore
            correct:(BOOL)correct
          isMyPaint:(BOOL)isMyPaint
     drawActionList:(NSArray *)drawActionList
              scene:(UseItemScene*)scene;

- (id)initWithImage:(UIImage *)image
         drawUserId:(NSString *)drawUserId
   drawUserNickName:(NSString *)drawUserNickName
           wordText:(NSString *)aWordText
              score:(NSInteger)aScore
            correct:(BOOL)correct
          isMyPaint:(BOOL)isMyPaint
     drawActionList:(NSArray *)drawActionList
               feed:(DrawFeed*)feed
              scene:(UseItemScene*)scene;


@end
