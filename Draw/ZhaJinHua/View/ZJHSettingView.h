//
//  ZJHSettingView.h
//  Draw
//
//  Created by Kira on 12-11-13.
//
//

#import <UIKit/UIKit.h>
#import "CommonInfoView.h"


@interface ZJHSettingView : CommonInfoView

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *musicImageView;
@property (retain, nonatomic) IBOutlet UIImageView *audioImageView;
@property (retain, nonatomic) IBOutlet UIButton *musicOnButton;
@property (retain, nonatomic) IBOutlet UIButton *musicOffButton;
@property (retain, nonatomic) IBOutlet UIButton *audioOnButton;
@property (retain, nonatomic) IBOutlet UIButton *audioOffButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

+ (id)createZJHSettingView;

@end
