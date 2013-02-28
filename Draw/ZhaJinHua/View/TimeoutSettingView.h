//
//  TimeoutSettingView.h
//  Draw
//®
//  Created by 王 小涛 on 13-2-27.
//
//

#import <UIKit/UIKit.h>
#import "ZhaJinHua.pb.h"

@protocol TimeoutSettingViewDelegate <NSObject>

- (void)didSelectTimeoutAction:(PBZJHUserAction)action;

@end

@interface TimeoutSettingView : UIView

@property (retain, nonatomic) IBOutlet UIButton *foldActionButton;
@property (assign, nonatomic) id<TimeoutSettingViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *betOrCompareActionButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *foldNoteLabel;
@property (retain, nonatomic) IBOutlet UILabel *betOrCompareNotelabel;

+ (id)createTimeoutSettingView;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end
