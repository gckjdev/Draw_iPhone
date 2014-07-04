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
        
//        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.tutorialImageView
//                                                                      attribute:NSLayoutAttributeBottom
//                                                                      relatedBy:NSLayoutRelationEqual
//                                                                         toItem:nil
//                                                                      attribute:nil
//                                                                     multiplier:1.0
//                                                                       constant:TUTORIAL_IMAGE_HEIGHT];
//        
//        [self.contentView addConstraint:constraint];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellInfo:(PBUserTutorial*)ut
{
    SET_BUTTON_ROUND_STYLE_ORANGE(self.tutorialStartBtn);
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self.tutorialNameLabel setText:ut.tutorial.name];    // TODO 国际化
    NSDate* createDate = [NSDate dateWithTimeIntervalSince1970:ut.createDate];
    self.tutorialDateLabel.text = dateToLocaleString(createDate);
    
    UIImage *placeHolderImage = [UIImage imageNamed:@"dialogue@2x"];
//    _tutorialImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_tutorialImageView setImageWithUrl:[NSURL URLWithString:ut.tutorial.image]
                   placeholderImage:placeHolderImage
                        showLoading:YES
                           animated:YES];
    
    SET_VIEW_ROUND_CORNER(self.tutorialImageView);

}

- (void)dealloc {
    [_tutorialNameLabel release];
    [_tutorialImageView release];
    [_tutorialDateLabel release];
    [_tutorialStartBtn release];
    [_UIImageViewUpView release];
    [super dealloc];
}

@end
