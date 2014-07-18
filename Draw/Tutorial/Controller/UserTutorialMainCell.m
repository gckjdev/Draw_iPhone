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
#define PROGRESS_VIEW_HEIGHT (ISIPAD ? 20:10)
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
    
    
    
    UILabel *difficultyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 50, 30)];
    [difficultyLabel setText:ut.tutorial.categoryName];
    [difficultyLabel setShadowColor:[UIColor whiteColor]];
    [difficultyLabel setTextColor:COLOR_BROWN];
    [difficultyLabel setShadowOffset:CGSizeMake(1, 1)];
    [difficultyLabel setFont:AD_FONT(18, 12)];
    [self addSubview:difficultyLabel];
    [difficultyLabel release];
    
    
    int i = arc4random() % 100;
    float progress = i/100.0;

    [self setProgressView:row WithProgress:progress];
    
    //实现国际化
    [self.tutorialNameLabel setText:ut.tutorial.name];
    
    NSDate* createDate = [NSDate dateWithTimeIntervalSince1970:ut.createDate];
    self.tutorialDateLabel.text = dateToTimeLineString(createDate);
    UIImage *placeHolderImage = [UIImage imageNamed:DEFAUT_IMAGE_NAME];
    [_tutorialImageView setImageWithUrl:[NSURL URLWithString:ut.tutorial.image]
                   placeholderImage:placeHolderImage
                        showLoading:YES
                           animated:YES];
}

-(void)setProgressView:(NSInteger)row WithProgress:(float)progress{
    
    if(row <= 0){
        UIImage* starButtonBgImage = [[ShareImageManager defaultManager] tutorialStartButtonBgImage];
        [self.tutorialStartBtn setBackgroundImage:starButtonBgImage forState:UIControlStateNormal];
        [self.tutorialStartBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
        [self.tutorialStartBtn.titleLabel setFont:AD_FONT(25, 15)];
        self.tutorialStartBtn.hidden = NO;
        self.tutorialProgressView.hidden = YES;
        if(progress <= 0.0f)
        {
            [self.tutorialStartBtn setTitle:@"开始" forState:UIControlStateNormal];
        }else{
            
            [self.tutorialStartBtn setTitle:@"继续闯关" forState:UIControlStateNormal];
            [self.progressInfoLabel setHidden:NO];
            [self.progressInfoLabel setText:[NSString stringWithFormat:@"%.0f%%完成",progress*100]];
            [self.progressInfoLabel setFont:AD_FONT(18, 12)];
            [self.progressInfoLabel setTextColor:COLOR_BROWN];
            
        }
        
        
    }else{
        CGAffineTransform transform = CGAffineTransformMakeScale(PROGRESS_VIEW_HEIGHT, PROGRESS_VIEW_HEIGHT);
        self.tutorialProgressView.transform = transform;
        self.tutorialProgressView.progress = progress;
        [self.tutorialProgressView setProgressTintColor:COLOR_YELLOW];
        self.tutorialProgressView.layer.cornerRadius = 0.9;
        self.tutorialProgressView.layer.masksToBounds = YES;
//        SET_VIEW_ROUND_CORNER(self.tutorialProgressView);
        [self.othersProgressInfoLabel setText:[NSString stringWithFormat:@"已完成%.0f%%",progress*100]];
        [self.othersProgressInfoLabel setFont:AD_FONT(18, 12)];
        [self.othersProgressInfoLabel setTextColor:COLOR_BROWN];
        self.othersProgressInfoLabel.hidden = NO;
        self.tutorialProgressView.hidden = NO;
        self.tutorialStartBtn.hidden = YES;
        
    }
    
    
    
    
}


- (void)dealloc {
    [_tutorialNameLabel release];
    [_tutorialImageView release];
    [_tutorialDateLabel release];
    [_tutorialStartBtn release];
    [_UIImageViewUpView release];
    [_vagueTopImageView release];
    [_labelBottomView release];
    [_tutorialProgressView release];
    [_progressInfoLabel release];
    [_othersProgressInfoLabel release];
    [super dealloc];
}

@end
