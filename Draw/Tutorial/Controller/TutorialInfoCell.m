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
    }
    return self;
}


//label 的 自适应长度
-(void)setAutoWithAndHeightLabel:(NSString *)text WithLabel:(UILabel *)label WithX:(CGFloat)x WithY:(CGFloat)y{
    //高度和宽度

    CGSize size =CGSizeMake(230,80);
    UIFont * tfont = AD_FONT(19, 12);
    [label setFont:tfont];
    //ios6 method
//    [label setLineBreakMode:UILineBreakModeWordWrap];
    [label setNumberOfLines:0];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize =[text boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:tdic
                              context:nil].size;
    
    [label setTextColor:COLOR_BROWN];
    
    [label setFrame:CGRectMake(x, y,actualsize.width, actualsize.height)];
    [label setText:text];
}

#define CATEGORY_NAME_X (ISIPAD ? 97:60)
#define CATEGORY_NAME_Y (ISIPAD ? 21:20)
#define DESC_X (ISIPAD ? 97:60)
#define DESC_Y (ISIPAD ? 65:47)
- (void)updateCellInfo:(PBTutorial*)pbTutorial
{
    //实现国际化
    if(pbTutorial!=nil){
        
        NSString *tutorialCategoryText = pbTutorial.categoryName;
        NSString *tutorialDescText = pbTutorial.desc;
    
        [self setAutoWithAndHeightLabel:tutorialCategoryText WithLabel:self.tutorialSortedLabel WithX:CATEGORY_NAME_X WithY:CATEGORY_NAME_Y];
        [self setAutoWithAndHeightLabel:tutorialDescText WithLabel:self.tutorialDescLabel WithX:DESC_X WithY:DESC_Y];
        
        [self.tutorialDescNameLabel setFont:AD_FONT(19, 12)];
        [self.tutorialSortedNameLabel setFont:AD_FONT(19, 12)];

        
    }
}

#define SCREEN_WIDTH (ISIPAD ? 768 : 320)
-(CGFloat)autoContentViewHeight{
    //tableview自适应高度
    CGRect txtFrame = self.tutorialDescLabel.frame;
    CGFloat  textViewContentHeight =
    txtFrame.size.height =[[NSString stringWithFormat:@"%@\n ",self.tutorialDescLabel.text]
                           boundingRectWithSize:CGSizeMake(txtFrame.size.width, CGFLOAT_MAX)
                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tutorialDescLabel.font,NSFontAttributeName, nil] context:nil].size.height;
    
    CGRect labelFrame = self.tutorialSortedLabel.frame;
    CGFloat labelContentHeight =
    txtFrame.size.height =[[NSString stringWithFormat:@"%@\n ",self.tutorialDescLabel.text]
                                                       boundingRectWithSize:CGSizeMake(labelFrame.size.width, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tutorialSortedLabel.font,NSFontAttributeName, nil] context:nil].size.height;
    CGFloat tableviewCellHeight = labelContentHeight + textViewContentHeight+(ISIPAD ? 0:25);
    
//    [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableviewCellHeight)];
    return tableviewCellHeight;
    
    
}

-(void) adaptLabelWidth:(UILabel *)label WithStringText:(NSString *)text{
    
   
    UIFont * tfont = [UIFont systemFontOfSize:14];
    [label setFont:tfont];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize =[text boundingRectWithSize:label.bounds.size
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:tdic
                         context:nil].size;
     [label setFrame:CGRectMake(82, 21,actualsize.width, actualsize.height)];

}

- (void)dealloc {
    [_tutorialSortedLabel release];
    [_tutorialDescLabel release];
    [_tutorialSortedNameLabel release];
    [_tutorialDescNameLabel release];
    [super dealloc];
}
@end
