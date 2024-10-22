//
//  UserTutorialMainCell.m
//  Draw
//
//  Created by qqn_pipi on 14-6-30.
//
//

#import "UserTutorialMainCell.h"
#import "TimeUtils.h"
#import "PBTutorial+Extend.h"
#import "UIImageView+Extend.h"
#import "Tutorial.pb.h"
#import "LDProgressView.h"

#define TUTORIAL_IMAGE_HEIGHT       (ISIPAD ? 100 : 45)
@implementation UserTutorialMainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        SET_VIEW_ROUND_CORNER(self);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#define DEFAUT_IMAGE_NAME @"daguanka"
#define PROGRESS_VIEW_HEIGHT (ISIPAD ? 2:2)
- (void)updateCellInfo:(PBUserTutorial*)ut WithRow:(NSInteger)row
{
   
    
    SET_VIEW_ROUND_CORNER(self.tutorialImageView);
//    SET_VIEW_ROUND_CORNER(self.labelBottomView);
   
    self.frame = CGRectMake(15, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
    
    //contentView background
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];

    //自定义label右上角难度
    [_difficultyLabel setFrame:CGRectMake(5, 3, (ISIPAD?200:150),(ISIPAD?50:20))];
    [_difficultyLabel setText:ut.tutorial.categoryName];
    [_difficultyLabel setShadowColor:[UIColor whiteColor]];
    [_difficultyLabel setTextColor:COLOR_BROWN];
    [_difficultyLabel setShadowOffset:CGSizeMake(1, 1)];
    [_difficultyLabel setFont:AD_FONT(18, 12)];
    [_difficultyLabel setBackgroundColor:[UIColor clearColor]];
//    [_difficultyLabel updateOriginX:self.tutorialDateLabel.frame.origin.x];
    
    float progress = [ut progress]*1.0f/100.0f;
    [self setProgressView:row WithProgress:progress];
    
    
    //实现国际化
    [self.tutorialNameLabel setText:ut.tutorial.name];
    [self.tutorialNameLabel setTextColor:COLOR_BROWN];
    [self.tutorialDateLabel setTextColor:COLOR_BROWN];
    
    
    NSDate* createDate = [NSDate dateWithTimeIntervalSince1970:(ut.modifyDate == 0) ? ut.createDate : ut.modifyDate];
    self.tutorialDateLabel.text = dateToTimeLineString(createDate);
    
    
    UIImage *placeHolderImage = [UIImage imageNamed:DEFAUT_IMAGE_NAME];
    [_tutorialImageView setImageWithUrl:[NSURL URLWithString:ut.tutorial.image]
                   placeholderImage:placeHolderImage
                        showLoading:YES
                           animated:YES];
    
    self.alphaView.alpha = 0.15;
    
     [self setSomeCornerRadius];
}

#define PROGRESS_VIEW_SIZE_WIDTH (ISIPAD ? 360.0f : 160.0f)
#define PROGRESS_VIEW_SIZE_HEIGHT (ISIPAD ? 40.0f : 20.0f)
-(void)setProgressView:(NSInteger)row WithProgress:(float)progress{
    const CGSize progressViewSize = { PROGRESS_VIEW_SIZE_WIDTH, PROGRESS_VIEW_SIZE_HEIGHT};
    [self.progressAndLabelView removeAllSubviews];
    //調用THprogressview
    [self.progressInfoLabel setHidden:YES];

   
    
    CGSize mainSize = [UIScreen mainScreen].bounds.size;
    
    //调用LDProgressView
    CGFloat progressX;
    if(ISIPAD){
        progressX = fabsf((self.frame.size.width - progressViewSize.width)/2.0f);
    }
    else{
        progressX = fabsf((mainSize.width - progressViewSize.width-30)/2.0f);
    }
    const CGFloat progressY = fabsf((self.frame.size.height - progressViewSize.height-(ISIPAD?42:20))/2.0f);
    LDProgressView *tutorialProgressView = [[LDProgressView alloc] initWithFrame:
                                                            CGRectMake(progressX,progressY,progressViewSize.width,progressViewSize.height)];
    
    tutorialProgressView.color = [UIColor colorWithRed:0.99f green:0.85f blue:0.33f alpha:1.0f];
    tutorialProgressView.labelTextColor = COLOR_BROWN;
    tutorialProgressView.flat = @YES;
    tutorialProgressView.animate = @YES;
    tutorialProgressView.progressInset = @2;
    tutorialProgressView.showBackgroundInnerShadow = @NO;
    tutorialProgressView.outerStrokeColor = COLOR_WHITE;
    tutorialProgressView.outerStrokeWidth = @2;
    tutorialProgressView.type = LDProgressSolid;
//    [tutorialProgressView updateCenterX:[UIScreen mainScreen].bounds.size.width/2];
    
    //row == 0 特殊情況
    if(row <= 0){
        UIImage* starButtonBgImage = [[ShareImageManager defaultManager] tutorialStartButtonBgImage];
        [self.tutorialStartBtn setBackgroundImage:starButtonBgImage forState:UIControlStateNormal];
        [self.tutorialStartBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
        [self.tutorialStartBtn.titleLabel setFont:AD_FONT(25, 15)];
        self.tutorialStartBtn.hidden = NO;
        tutorialProgressView.hidden = YES;
        self.othersProgressInfoLabel.hidden = YES;
        [self.progressInfoLabel setHidden:YES];
        //row == 0 并且progress =0
        if(progress <= 0.0f)
        {
            [self.tutorialStartBtn setTitle:NSLS(@"kStartStage") forState:UIControlStateNormal];
            [self.progressInfoLabel setHidden:YES];
            
        }else{
            
            [self.tutorialStartBtn setTitle:NSLS(@"kContinueStage")forState:UIControlStateNormal];
            [self.progressInfoLabel setHidden:NO];
            NSString * progressString = [NSString stringWithFormat:@"%.0f%%",progress*100.0f];
            [self.progressInfoLabel setText:[NSLS(@"kProgress") stringByAppendingString:progressString]];
            [self.progressInfoLabel setFont:AD_FONT(18, 12)];
            [self.progressInfoLabel setTextColor:COLOR_WHITE];
            
        }
        
    // row>=1時候就是普通情況
    }else{
//        SET_VIEW_ROUND_CORNER(self.tutorialProgressView);
        self.othersProgressInfoLabel.hidden = YES;
        tutorialProgressView.hidden = NO;
        tutorialProgressView.progress = progress;
        self.tutorialStartBtn.hidden = YES;
        
        
    }
    [self.progressAndLabelView addSubview:tutorialProgressView];
    [tutorialProgressView release];
    
    
    
}
#define CORNER_RADII (ISIPAD ? 15:8)
-(void)setSomeCornerRadius{
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_labelBottomView.bounds byRoundingCorners:  UIRectCornerBottomRight | UIRectCornerBottomLeft cornerRadii:CGSizeMake(CORNER_RADII, CORNER_RADII)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _labelBottomView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    _labelBottomView.layer.mask = maskLayer;
    [maskLayer release];
    
    UIBezierPath *maskPathAlphaView = [UIBezierPath bezierPathWithRoundedRect:_alphaView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(CORNER_RADII, CORNER_RADII)];
    CAShapeLayer *maskLayerAlphaView = [[CAShapeLayer alloc] init];
    maskLayerAlphaView.frame = _alphaView.bounds;
    maskLayerAlphaView.path = maskPathAlphaView.CGPath;
    
    _alphaView.layer.mask = maskLayerAlphaView;
//    _alphaView.bounds = CGRectMake(0, 0,  self.frame.size.width, self.frame.size.height-self.labelBottomView.frame.size.height);
    [maskLayerAlphaView release];
}

- (void)dealloc {
    [_tutorialNameLabel release];
    [_tutorialImageView release];
    [_tutorialDateLabel release];
    [_tutorialStartBtn release];
    [_UIImageViewUpView release];
    [_vagueTopImageView release];
    [_labelBottomView release];
    [_progressInfoLabel release];
    [_othersProgressInfoLabel release];
    [_progressAndLabelView release];
    [_difficultyLabel release];
    [_alphaView release];
    [super dealloc];
}

@end
