//
//  TaskInfoCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import "StageBasicInfoCell.h"

@implementation StageBasicInfoCell
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
        
        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.taskImage
                                                                      attribute: NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:nil
                                                                     multiplier:1.0
                                                                       constant:Task_IMAGE_HEIGHT];
        
        [self.contentView addConstraint:constraint];
        
    }
    return self;
}
- (void)dealloc {
    [_taskNumber release];
    [_taskImage release];
    [_taskName release];
    [_taskDesc release];
    [super dealloc];
}
@end
