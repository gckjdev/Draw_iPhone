//
//  AllTutorialCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import "AllTutorialCell.h"
#import "Tutorial.pb.h"
#import "UIImageView+Extend.h"
#import "PBTutorial+Extend.h"

#define TUTORIAL_IMAGE_HEIGHT       (ISIPAD ? 100 : 45)
@implementation AllTutorialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        SET_VIEW_ROUND_CORNER(self.contentView);
//        
//        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.tutorialImage
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

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define DEFAUT_IMAGE "dialogue@2x"
- (void)updateCellInfo:(PBTutorial*)pbTutorial
{
    self.tutorialName.font = AD_BOLD_FONT(28, 16);
    self.tutorialName.textColor = COLOR_BROWN;
    
    self.tutorialDesc.font = AD_FONT(22, 11);
    self.tutorialDesc.textColor = COLOR_RED;
    
    //实现国际化
    self.tutorialName.text = pbTutorial.name;
    self.tutorialDesc.text = pbTutorial.desc;
    UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE];

    SET_VIEW_ROUND_CORNER(self.tutorialImage);
    
    [_tutorialImage setImageWithUrl:[NSURL URLWithString:pbTutorial.thumbImage]
                    placeholderImage:placeHolderImage
                    showLoading:YES
                    animated:YES];
}

- (void)dealloc {
    [_tutorialName release];
    [_tutorialDesc release];
    [_tutorialImage release];
    [super dealloc];
}
@end
