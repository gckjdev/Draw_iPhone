//
//  UserTutorialMainCell.m
//  Draw
//
//  Created by qqn_pipi on 14-6-30.
//
//

#import "UserTutorialMainCell.h"

#define TUTORIAL_IMAGE_HEIGHT       (ISIPAD ? 100 : 45)

@implementation UserTutorialMainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        SET_VIEW_ROUND_CORNER(self.contentView);
        
        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.tutorialImageView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:nil
                                                                     multiplier:1.0
                                                                       constant:TUTORIAL_IMAGE_HEIGHT];
        
        [self.contentView addConstraint:constraint];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_tutorialNameLabel release];
    [_tutorialImageView release];
    [super dealloc];
}
@end
