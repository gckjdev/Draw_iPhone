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
#import "THProgressView.h"

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
    //圆角
//    SET_BUTTON_ROUND_STYLE_YELLOW(self.tutorialStartBtn);
//    [self.tutorialStartBtn.titleLabel setFont:AD_FONT(24, 12)];
    
   
    
    SET_VIEW_ROUND_CORNER(self.tutorialImageView);
    SET_VIEW_ROUND_CORNER(self.labelBottomView);
    //contentView background
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
   //    [self.tutorialStartBtn setTitle:@"开始" forState:UIControlStateNormal];
    
    
    //自定义label右上角难度
    UILabel *difficultyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 50, 30)];
    [difficultyLabel setText:ut.tutorial.categoryName];
    [difficultyLabel setShadowColor:[UIColor whiteColor]];
    [difficultyLabel setTextColor:COLOR_BROWN];
    [difficultyLabel setShadowOffset:CGSizeMake(1, 1)];
    [difficultyLabel setFont:AD_FONT(18, 12)];
    [difficultyLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:difficultyLabel];
    [difficultyLabel release];
    
    
//    int i = arc4random() % 100;
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

#define PROGRESS_VIEW_SIZE_WIDTH (ISIPAD ? 200.0f : 120.0f)
#define PROGRESS_VIEW_SIZE_HEIGHT (ISIPAD ? 50.0f : 35.0f)
-(void)setProgressView:(NSInteger)row WithProgress:(float)progress{
    const CGSize progressViewSize = { PROGRESS_VIEW_SIZE_WIDTH, PROGRESS_VIEW_SIZE_HEIGHT};
    //調用THprogressview
    UIView *view = self.progressAndLabelView;
    [view removeAllSubviews];
        THProgressView *tutorialProgressView = [[THProgressView alloc]
                                            initWithFrame:
                                                              CGRectMake
                                                             (5.0f,
                                                              0.0f,
                                                              progressViewSize.width,
                                                              progressViewSize.height
                                                             )
                                            
                                            WithProgressLabelFrame:
                                                              CGRectMake
                                                              (10,
                                                              0.0f,
                                                              progressViewSize.width-20,
                                                              progressViewSize.height
                                                              )
                                            ];
    
    tutorialProgressView.borderTintColor = COLOR_ORANGE;
    tutorialProgressView.progressTintColor = COLOR_YELLOW;
    
    
    
    //row == 0 特殊情況
    if(row <= 0){
        UIImage* starButtonBgImage = [[ShareImageManager defaultManager] tutorialStartButtonBgImage];
        [self.tutorialStartBtn setBackgroundImage:starButtonBgImage forState:UIControlStateNormal];
        [self.tutorialStartBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
        [self.tutorialStartBtn.titleLabel setFont:AD_FONT(25, 15)];
        self.tutorialStartBtn.hidden = NO;
        tutorialProgressView.hidden = YES;
        self.othersProgressInfoLabel.hidden = YES;
        if(progress <= 0.0f)
        {
            [self.tutorialStartBtn setTitle:@"开始" forState:UIControlStateNormal];
        }else{
            
            [self.tutorialStartBtn setTitle:@"继续闯关" forState:UIControlStateNormal];
            [self.progressInfoLabel setHidden:NO];
            [self.progressInfoLabel setText:[NSString stringWithFormat:@"%.0f%%完成",100.0f]];
            [self.progressInfoLabel setFont:AD_FONT(18, 12)];
            [self.progressInfoLabel setTextColor:COLOR_BROWN];
            
        }
        
    // row>=1時候就是普通情況
    }else{
//        SET_VIEW_ROUND_CORNER(self.tutorialProgressView);
        self.othersProgressInfoLabel.hidden = YES;
        tutorialProgressView.hidden = NO;
        [tutorialProgressView setProgress:1 animated:YES];
        [tutorialProgressView setProgressLabelColor:COLOR_BROWN];
        [tutorialProgressView setProgressLabelFont:AD_FONT(20, 13)];
        self.tutorialStartBtn.hidden = YES;
        
    }
    
    [view addSubview:tutorialProgressView];
    
    
    
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
    [super dealloc];
}

@end
