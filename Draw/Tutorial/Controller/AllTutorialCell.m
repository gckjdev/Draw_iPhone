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

#define TUTORIAL_IMAGE_HEIGHT       (ISIPAD ? 100 : 45)
@implementation AllTutorialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        SET_VIEW_ROUND_CORNER(self.contentView);
        
        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.tutorialImage
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

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellInfo:(PBTutorial*)pbTutorial
{
    // TODO localize tutorial name
    self.tutorialName.text = pbTutorial.cnName;
    self.tutorialDesc.text = pbTutorial.cnDesc;
    
    UIImage *placeHolderImage = [UIImage imageNamed:@"dialogue@2x"];

    NSString* urlString = @"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"; //pbTutorial.thumbImage;
    [_tutorialImage setImageWithUrl:[NSURL URLWithString:urlString]
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
