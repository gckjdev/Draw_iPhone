//
//  RoomTitleView.h
//  Draw
//
//  Created by 王 小涛 on 12-11-16.
//
//

#import <UIKit/UIKit.h>
#import "FXLabel.h"

@interface RoomTitleView : UIView

@property (retain, nonatomic) IBOutlet FXLabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;

+ (void)showRoomTitle:(NSString *)title
               inView:(UIView *)view;

@end
