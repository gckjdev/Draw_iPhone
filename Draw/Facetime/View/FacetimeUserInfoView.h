//
//  FacetimeUserInfoView.h
//  Draw
//
//  Created by Orange on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FacetimeUserInfoView;
@class PBGameUser;

@protocol FacetimeUserInfoViewDelegate <NSObject>

- (void)clickStartChat:(FacetimeUserInfoView*)view;
- (void)clickChange:(FacetimeUserInfoView*)view;

@end

@interface FacetimeUserInfoView : UIView {
    CFTimeInterval _runInAnimTime;
}
@property (retain, nonatomic) IBOutlet UIImageView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *genderLabel;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet UILabel *followStatusLabel;
@property (retain, nonatomic) IBOutlet UIButton *followButton;
@property (retain, nonatomic) IBOutlet UIButton *startFacetimeButton;
@property (retain, nonatomic) IBOutlet UIButton *changeButton;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIImageView *contentBackgroundImageView;
@property (assign, nonatomic) id<FacetimeUserInfoViewDelegate> delegate;

+ (FacetimeUserInfoView*)createUserInfoView;
- (void)showInViewController:(UIViewController*)superController 
                      inTime:(CFTimeInterval)timeInterval;
- (void)showFacetimeUser:(PBGameUser*)user 
        inViewController:(UIViewController<FacetimeUserInfoViewDelegate>*)superController 
                  inTime:(CFTimeInterval)timeInterval;

@end
