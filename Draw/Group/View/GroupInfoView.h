//
//  GroupInfoView.h
//  Draw
//
//  Created by Gamy on 13-11-19.
//
//

#import <UIKit/UIKit.h>

@class GroupInfoView;
@protocol GroupInfoViewDelegate <NSObject>

@optional
- (void)groupInfoView:(GroupInfoView *)infoView didClickCustomButton:(UIButton *)button;

@end

@class PBGroup;
@interface GroupInfoView : UIView
@property (retain, nonatomic) PBGroup *group;
@property (assign, nonatomic) id<GroupInfoViewDelegate>delegate;

+ (id)infoViewWithGroup:(PBGroup *)group;
+ (CGFloat)getViewHeight;
- (void)setCustomButton:(UIButton *)button;
- (UIButton *)customButton;

@end