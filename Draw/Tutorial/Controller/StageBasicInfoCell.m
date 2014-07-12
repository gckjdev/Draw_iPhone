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
    }
    return self;
}


#define DEFAUT_IMAGE "xiaoguanka"
-(void)updateStageCellInfo:(PBStage*)pbStage WithRow:(NSInteger)row{
    
    //设置stageBasicInfo
    self.stageBasicInfoName.font = AD_BOLD_FONT(25, 13);
    self.stageBasicInfoName.textColor = COLOR_BROWN;
    
    self.stageBasicInfoDesc.font = AD_FONT(20, 10);
    self.stageBasicInfoDesc.textColor = COLOR_GRAY_TEXT;
    
    self.stageBasicInfoNum.font = AD_BOLD_FONT(50, 26);
    self.stageBasicInfoNum.textColor = COLOR_GRAY_AVATAR;
    
    //名字/描述国际化
    self.stageBasicInfoName.text = pbStage.name;
    self.stageBasicInfoDesc.text = pbStage.desc;
    self.stageBasicInfoNum.text = [NSString stringWithFormat:@"%d", row+1];
    UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE];
    
    
    [_stageBasicInfoImageView setImageWithUrl:[NSURL URLWithString:pbStage.thumbImage]
                   placeholderImage:placeHolderImage
                        showLoading:YES
                           animated:YES];

    
    
    
}


- (void)dealloc {
    [_stageBasicInfoNum release];
    [_stageBasicInfoImageView release];
    [_stageBasicInfoName release];
    [_stageBasicInfoDesc release];
    [super dealloc];
}
@end
