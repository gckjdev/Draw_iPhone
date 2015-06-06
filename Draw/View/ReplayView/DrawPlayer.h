//
//  DrawPlayer.h
//  Draw
//
//  Created by Gamy on 13-8-30.
//
//

#import <UIKit/UIKit.h>
#import "CustomSlider.h"
#import "ShowDrawView.h"
#import "ScreenCaptureView.h"

@class Draw;
@class DrawFeed;

@interface ReplayObject : NSObject
{
    
}

+ (id)obj;
+ (id)objectWithActionList:(NSMutableArray*)actionList
              drawDataVersion:(int)drawDataVersion
                canvasSize:(CGSize)canvasSize
                    layers:(NSArray*)layers;

//@property(nonatomic, assign) BOOL isNewVersion;

@property(nonatomic, assign) int drawDataVersion;
@property(nonatomic, assign) CGSize canvasSize;

@property(nonatomic, retain) NSMutableArray *actionList;
@property(nonatomic, retain) UIImage *bgImage;
@property(nonatomic, retain) UIImage *finalImage;
@property(nonatomic, retain) NSArray *layers;

@property(nonatomic, retain) NSString *opusUserId;
@property(nonatomic, retain) NSString *opusUserNick;
@property(nonatomic, assign) BOOL opusUserGender;
@property(nonatomic, retain) NSString *opusId;
@property(nonatomic, retain) NSString *opusWord;
@property(nonatomic, retain) NSString *opusDesc;

- (BOOL)isLatestDrawVersion;
- (BOOL)isOldPlayVersion;

@end


@interface DrawPlayer : UIView<ShowDrawViewDelegate>

@property (retain, nonatomic) ShowDrawView *showView;
@property (retain, nonatomic) ReplayObject *replayObj;
@property (retain, nonatomic) IBOutlet UIView *playPanel;
@property (retain, nonatomic) IBOutlet CustomSlider *playSlider;
@property (retain, nonatomic) IBOutlet CustomSlider *speedSlider;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UILabel *indexLabel;


@property (assign, nonatomic) NSUInteger begin;
@property (assign, nonatomic) NSUInteger end;

- (IBAction)close:(id)sender;

- (IBAction)changeProcess:(CustomSlider *)sender;
- (IBAction)changeSpeed:(CustomSlider *)sender;
- (IBAction)clickPlayButton:(id)sender;

//+ (DrawPlayer *)playerWithGifViewInSize:(CGSize)canvasSize;//TODO
+ (DrawPlayer *)playerWithReplayObj:(ReplayObject *)obj;
+ (DrawPlayer*)playerWithReplayObj:(ReplayObject *)obj
                             begin:(NSUInteger)begin
                               end:(NSUInteger)end
                       bgImageName:(NSString*)bgImageName;

+ (DrawPlayer*)playerWithSingleLayer:(NSInteger)num
                              RepObj:(ReplayObject*)obj;

+ (void) createImageOfLayer:(NSInteger)num
                     RepObj:(ReplayObject*)obj;


- (void)showInController:(PPViewController *)controller;
//- (void)showGifInController:(PPViewController *)controller;

- (void)play;
- (void)pause;
- (void)stop;
- (void)start;

+ (void)playDrawData:(NSData**)drawData
                draw:(Draw**)retDraw
      viewController:(PPViewController*)viewController
             bgImage:(UIImage*)bgImage
         bgImageName:(NSString*)bgImageName
          startIndex:(int)startIndex
            endIndex:(int)endIndex
           drawImage:(UIImage*)drawImage;

+ (UIImage*)createImageByDrawData:(NSData**)drawData
                             draw:(Draw**)retDraw
                   viewController:(PPViewController*)viewController
                          bgImage:(UIImage*)bgImage
                      bgImageName:(NSString*)bgImageName
                       startIndex:(int)startIndex
                         endIndex:(int)endIndex;

+ (UIImage*)createImageWithReplayObj:(ReplayObject *)obj
                               begin:(NSUInteger)begin
                                 end:(NSUInteger)end
                         bgImageName:(NSString*)bgImageName
                             bgColor:(UIColor*)bgColor;


@end
