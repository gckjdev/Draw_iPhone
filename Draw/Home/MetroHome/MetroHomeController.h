//
//  MetroHomeController.h
//  Draw
//
//  Created by ChaoSo on 14-7-8.
//
//

#import <UIKit/UIKit.h>
#import "StableView.h"
#import "SuperHomeController.h"

@interface MetroHomeController : PPViewController{
    UIButton *LearningViewButton;
    
}
@property (retain, nonatomic) IBOutlet UIView *galleryView;
@property (retain, nonatomic) IBOutlet UIImageView *galleryImageView;
@property (retain, nonatomic) IBOutlet UIView *topView;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *topNameLable;
@property (retain, nonatomic) IBOutlet UIView *topAnnounceView;
@property (retain, nonatomic) IBOutlet UIButton *topAnnounceButton;
@property (retain, nonatomic) IBOutlet UIView *paintingView;
@property (retain, nonatomic) IBOutlet UIButton *paintingViewButton;
@property (retain, nonatomic) IBOutlet UIView *learningView;
@property (retain, nonatomic) IBOutlet UIButton *learningViewButton;
@property (retain, nonatomic) IBOutlet UIView *mainView;
@property (retain, nonatomic) IBOutlet UIView *bottomView;
@property (retain, nonatomic) IBOutlet UIButton *indexButton;
@property (retain, nonatomic) IBOutlet UIButton *documentButton;
@property (retain, nonatomic) IBOutlet UIButton *messageButton;
@property (retain, nonatomic) IBOutlet UIButton *moreButton;


- (UIView *)createShadow:(UIView *)view;
- (IBAction)goToLearning:(id)sender;
- (IBAction)goToBBS:(id)sender;
- (IBAction)goToDraw:(id)sender;
- (IBAction)goToOpus:(id)sender;

@end
