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

//typedef enum {
//    OnlineGuess = 0,
//    OnlineDraw = 1,
//    OfflineGuess =2,
//    FeedGuess =3
//} ResultType;
@interface ResultController : PPViewController<DrawGameServiceDelegate, LevelServiceDelegate,DrawDataServiceDelegate>
{
    UIImage * _image;
    NSArray * _paintList;
    NSTimer *continueTimer;
    NSInteger retainCount;
    DrawGameService *drawGameService;
    BOOL _correct;
    BOOL _isMyPaint;
    NSArray *_drawActionList;
}
@property (retain, nonatomic) IBOutlet UIButton *upButton;
@property (retain, nonatomic) IBOutlet UIButton *downButton;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *exitButton;
@property (retain, nonatomic) NSString *wordText;
@property (retain, nonatomic) NSString *drawUserId;
@property (retain, nonatomic) NSString *drawUserNickName;
@property (assign, nonatomic) NSInteger score;
//@property (assign, nonatomic) ResultType resultType;
@property (retain, nonatomic) IBOutlet UILabel *wordLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
@property (retain, nonatomic) IBOutlet UIImageView *whitePaper;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) NSArray *drawActionList;

- (IBAction)clickUpButton:(id)sender;
- (IBAction)clickDownButton:(id)sender;
- (IBAction)clickContinueButton:(id)sender;
- (IBAction)clickSaveButton:(id)sender;
- (IBAction)clickExitButton:(id)sender;


@property (retain, nonatomic) IBOutlet UIImageView *drawImage;

- (id)initWithImage:(UIImage *)image 
         drawUserId:(NSString *)drawUserId
   drawUserNickName:(NSString *)drawUserNickName
           wordText:(NSString *)aWordText 
              score:(NSInteger)aScore 
            correct:(BOOL)correct 
          isMyPaint:(BOOL)isMyPaint 
     drawActionList:(NSArray *)drawActionList;

//- (void)saveActionList:(NSArray *)actionList;
//- (void)didFinishAPaint:(NSArray *)drawAction;
@end
