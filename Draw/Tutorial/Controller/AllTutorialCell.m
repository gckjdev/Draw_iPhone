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
//"kProTutorialType" = "专业教程";
//"kLeisureTutorialType" = "休闲临摹";
//"kSecCreateTutorialType" = "二次创作";
#define DEFAUT_IMAGE "daguanka"
#define LEISURE_TUTORIAL_TYPE NSLS(@"kLeisureTutorialType")
#define PRO_TUTORIAL_TYPE NSLS(@"kProTutorialType")
#define CREATE_TUTORIAL_TYPE NSLS(@"kSecCreateTutorialType")
- (void)updateCellInfo:(PBTutorial*)pbTutorial
{
    NSArray *tutorialTypeDescList = @[PRO_TUTORIAL_TYPE,
                                      PRO_TUTORIAL_TYPE,
                                      LEISURE_TUTORIAL_TYPE,
                                      CREATE_TUTORIAL_TYPE];
    
    self.tutorialName.font = AD_BOLD_FONT(28, 16);
    self.tutorialName.textColor = COLOR_BROWN;
    
    self.tutorialDesc.font = AD_FONT(22, 11);
    self.tutorialDesc.textColor = COLOR_RED;
    
    self.tutorialType.font = AD_FONT(22, 11);
    self.tutorialType.textColor = COLOR_BROWN;
    
    //实现国际化

    self.tutorialName.text = pbTutorial.name;
    self.tutorialDesc.text = pbTutorial.categoryName;
    
    if(pbTutorial.type>=0 && pbTutorial.type <= tutorialTypeDescList.count-1){
        self.tutorialType.text = [tutorialTypeDescList objectAtIndex:pbTutorial.type];
    }
    
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
    [_tutorialType release];
    [super dealloc];
}
@end
