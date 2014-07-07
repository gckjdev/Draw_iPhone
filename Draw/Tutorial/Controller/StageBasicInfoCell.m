//
//  TaskInfoCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-1.
//
//

#import "StageBasicInfoCell.h"
#import "UIImageView+Extend.h"

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
        
//        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.taskImage
//                                                                      attribute: NSLayoutAttributeBottom
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

// TODO 方法命名
// TODO 变量命名

#define DEFAUT_IMAGE "dialogue@2x"
-(void)updateStageCellInfo:(PBStage*)pbStage WithRow:(NSInteger)row{
    
    self.taskName.font = AD_BOLD_FONT(25, 13);
    self.taskName.textColor = COLOR_BROWN;
    
    self.taskDesc.font = AD_FONT(20, 10);
    self.taskDesc.textColor = COLOR_GRAY_TEXT;
    
    self.taskNumber.font = AD_BOLD_FONT(50, 26);
    self.taskNumber.textColor = COLOR_GRAY_AVATAR;
    
    // TODO 名字/描述国际化
    self.taskName.text = pbStage.cnName;
    self.taskDesc.text = pbStage.cnDesc;
    self.taskNumber.text = [NSString stringWithFormat:@"%d", row+1];
    UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE];
    
    
    [_taskImage setImageWithUrl:[NSURL URLWithString:pbStage.thumbImage]
                   placeholderImage:placeHolderImage
                        showLoading:YES
                           animated:YES];

    
    
    
}


- (void)dealloc {
    [_taskNumber release];
    [_taskImage release];
    [_taskName release];
    [_taskDesc release];
    [super dealloc];
}
@end
