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

@interface ReplayObject : NSObject
{
    
}

+ (id)obj;

@property(nonatomic, assign) BOOL *isNewVersion;
@property(nonatomic, assign) CGSize canvasSize;

@property(nonatomic, retain) NSMutableArray *actionList;
@property(nonatomic, retain) UIImage *bgImage;
@property(nonatomic, retain) NSArray *layers;



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
                               end:(NSUInteger)end;
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
          startIndex:(int)startIndex
            endIndex:(int)endIndex;

@end
