//
//  MatchingFacetimeUserView.h
//  Draw
//
//  Created by Orange on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MatchingFacetimeUserView;

@protocol MatchingFacetimeUserViewDelegate <NSObject>
@optional
- (void)clickCancelButton:(MatchingFacetimeUserView*)view;

@end

@interface MatchingFacetimeUserView : UIView {
    CFTimeInterval _runInAnimTime;
}
@property (retain, nonatomic) IBOutlet UIImageView *avatarView;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UILabel *matchingLabel;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIImageView *contentViewBackgroundImageView;
@property (assign, nonatomic) id<MatchingFacetimeUserViewDelegate> delegate;

+ (MatchingFacetimeUserView*)createUserInfoView;
- (void)showInViewController:(UIViewController*)superController 
                      inTime:(CFTimeInterval)timeInterval;

@end


