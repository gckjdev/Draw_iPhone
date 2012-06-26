//
//  CommonUserInfoView.h
//  Draw
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Friend;

@interface CommonUserInfoView : UIView

+ (void)showUser:(Friend*)afriend 
      infoInView:(UIViewController*)superController;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIButton *mask;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIImageView *snsTagImageView;
@property (retain, nonatomic) IBOutlet UILabel *genderLabel;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet UILabel *playWithUserLabel;
@property (retain, nonatomic) IBOutlet UILabel *chatToUserLabel;
@property (retain, nonatomic) IBOutlet UIButton *drawToUserButton;
@property (retain, nonatomic) IBOutlet UIButton *exploreUserFeedButton;
@property (retain, nonatomic) IBOutlet UIButton *chatToUserButton;
@property (retain, nonatomic) IBOutlet UIButton *followUserButton;

@end
