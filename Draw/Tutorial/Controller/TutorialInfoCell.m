//
//  TutorialInfoCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import "TutorialInfoCell.h"
#import "PBTutorial+Extend.h"

@implementation TutorialInfoCell
#define Task_IMAGE_HEIGHT       (ISIPAD ? 100 : 45)
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        SET_VIEW_ROUND_CORNER(self.contentView);
        
//        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.tutorialDescInfo
//                                         attribute: NSLayoutAttributeBottom
//                                                                      relatedBy:NSLayoutRelationEqual
//                                                                         toItem:nil
//                                                                      attribute:nil
//                                                                     multiplier:1.0
//                                                                       constant:Task_IMAGE_HEIGHT];
//        
//        [self.contentView addConstraint:constraint];
        
    }
    return self;
}


- (void)updateCellInfo:(PBTutorial*)pbTutorial
{
    //实现国际化
    if(pbTutorial!=nil){
        self.tutorialDesc.text = pbTutorial.name;
        self.tutorialDescInfo.text = pbTutorial.desc;
    }
}


- (void)dealloc {
    
    
    [_tutorialDesc release];
    [_tutorialDescInfo release];
    [_tutorialAddBtn release];
    [super dealloc];
}
@end
