//
//  WallOpusView.h
//  Draw
//
//  Created by 王 小涛 on 13-2-1.
//
//

#import <UIKit/UIKit.h>
#import "WallOpus.h"

@interface WallOpusView : UIView

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIButton *frameButton;
@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;

+ (id)createViewWithRect:(CGRect)rect pbFrame:(PBFrame *)pbFrame;

@end
