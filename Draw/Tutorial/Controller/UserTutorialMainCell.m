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
    }
    return self;
}

#define DEFAUT_IMAGE_NAME @"daguanka"
#define PROGRESS_VIEW_HEIGHT (ISIPAD ? 2:2)
- (void)updateCellInfo:(PBUserTutorial*)ut WithRow:(NSInteger)row
{
    
    SET_VIEW_ROUND_CORNER(self.tutorialImageView);
    SET_VIEW_ROUND_CORNER(self.labelBottomView);
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
    
    float progress = [ut progress]*1.0f/100.0f;
    [self setProgressView:row WithProgress:progress];
    
    //实现国际化
    [self.tutorialNameLabel setText:ut.tutorial.name];
    
    NSDate* createDate = [NSDate dateWithTimeIntervalSince1970:ut.modifyDate];
    self.tutorialDateLabel.text = dateToTimeLineString(createDate);
    UIImage *placeHolderImage = [UIImage imageNamed:DEFAUT_IMAGE_NAME];
    [_tutorialImageView setImageWithUrl:[NSURL URLWithString:ut.tutorial.image]
                   placeholderImage:placeHolderImage
                        showLoading:YES
                           animated:YES];
}

#define PROGRESS_VIEW_SIZE_WIDTH (ISIPAD ? 360.0f : 160.0f)
#define PROGRESS_VIEW_SIZE_HEIGHT (ISIPAD ? 40.0f : 20.0f)
-(void)setProgressView:(NSInteger)row WithProgress:(float)progress{
    const CGSize progressViewSize = { PROGRESS_VIEW_SIZE_WIDTH, PROGRESS_VIEW_SIZE_HEIGHT};
    //調用THprogressview
    UIView *view = self.progressAndLabelView;
    [view removeAllSubviews];

    //调用LDProgressView
     const CGFloat progressX = fabsf((self.bounds.size.width - progressViewSize.width)/2);
    const CGFloat progressY = fabsf((self.bounds.size.height - progressViewSize.height-(ISIPAD?42:20))/2);
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
        //row == 0 并且progress =0
        if(progress <= 0.0f)
        {
            [self.tutorialStartBtn setTitle:NSLS(@"kStartStage") forState:UIControlStateNormal];
            
        }else{
            
            [self.tutorialStartBtn setTitle:NSLS(@"kContinueStage")forState:UIControlStateNormal];
            [self.progressInfoLabel setHidden:NO];
            NSString * progressString = [NSString stringWithFormat:@"%.0f%%",progress*100];
            [self.progressInfoLabel setText:[NSLS(@"kProgress") stringByAppendingString:progressString]];
            [self.progressInfoLabel setFont:AD_FONT(18, 12)];
            [self.progressInfoLabel setTextColor:COLOR_BROWN];
            
        }
        
    // row>=1時候就是普通情況
    }else{
//        SET_VIEW_ROUND_CORNER(self.tutorialProgressView);
        self.othersProgressInfoLabel.hidden = YES;
        tutorialProgressView.hidden = NO;
        tutorialProgressView.progress = progress;
        self.tutorialStartBtn.hidden = YES;
        
    }
    
    [self addSubview:tutorialProgressView];
    [tutorialProgressView release];
    
    
    
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
    [super dealloc];
}

@end
