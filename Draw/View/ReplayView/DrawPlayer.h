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

- (IBAction)close:(id)sender;

- (IBAction)changeProcess:(CustomSlider *)sender;
- (IBAction)changeSpeed:(CustomSlider *)sender;
- (IBAction)clickPlayButton:(id)sender;


+ (DrawPlayer *)playerWithReplayObj:(ReplayObject *)obj;
- (void)showInController:(PPViewController *)controller;

- (void)play;
- (void)pause;
- (void)stop;
- (void)start;

@end