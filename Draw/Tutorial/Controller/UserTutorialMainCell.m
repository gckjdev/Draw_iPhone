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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#define DEFAUT_IMAGE_NAME @"daguanka"    // TODO　change

- (void)updateCellInfo:(PBUserTutorial*)ut
{
    //圆角
    SET_BUTTON_ROUND_STYLE_YELLOW(self.tutorialStartBtn);
    [self.tutorialStartBtn.titleLabel setFont:AD_FONT(24, 12)];
    SET_VIEW_ROUND_CORNER(self.tutorialImageView);
    SET_VIEW_ROUND_CORNER(self.labelBottomView);
    //contentView background
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
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

- (void)dealloc {
    [_tutorialNameLabel release];
    [_tutorialImageView release];
    [_tutorialDateLabel release];
    [_tutorialStartBtn release];
    [_UIImageViewUpView release];
    [_vagueTopImageView release];
    [_labelBottomView release];
    [super dealloc];
}

@end
