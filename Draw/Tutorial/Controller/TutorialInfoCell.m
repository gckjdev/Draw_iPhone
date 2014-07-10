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

- (void)updateCellInfo:(PBTutorial*)pbTutorial
{
    NSString *tutorialSortedText = pbTutorial.categoryName;
    UILabel* label =  [[UILabel alloc] initWithFrame:CGRectMake(97, 21, 0, 0)];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    UIFont * tfont = AD_FONT(19, 12);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    [label setTextColor:COLOR_BROWN];
    label.text = tutorialSortedText;
    [self addSubview:label];
    CGSize  actualsize =[tutorialSortedText boundingRectWithSize:label.bounds.size
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:tdic
                                           context:nil].size;
    [label setFrame:CGRectMake(97, 21,actualsize.width, actualsize.height)];
    
    //实现国际化
    if(pbTutorial!=nil){
        self.tutorialSortedLabel.text = tutorialSortedText;
//        [self adaptLabelWidth:self.tutorialSortedLabel WithStringText:tutorialSortedText];
      
        
       
//        [self.tutorialSortedLabel setTextColor:COLOR_BROWN];
//        [self.tutorialSortedLabel setFont:AD_FONT(19, 12)];
//        [self adaptLabelWidth:self.tutorialSortedLabel];
        
        
        self.tutorialDescLabel.text = pbTutorial.desc;
        [self.tutorialDescLabel setTextColor:COLOR_BROWN];
        [self.tutorialDescLabel setFont:AD_FONT(19, 12)];
        
          }
}
-(CGFloat)autoContentViewHeight{
    //tableview自适应高度
    CGRect txtFrame = self.tutorialDescLabel.frame;
    CGFloat  textViewContentHeight =
    txtFrame.size.height =[[NSString stringWithFormat:@"%@\n ",self.tutorialDescLabel.text]
                           boundingRectWithSize:CGSizeMake(txtFrame.size.width, CGFLOAT_MAX)
                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tutorialDescLabel.font,NSFontAttributeName, nil] context:nil].size.height;
    
//    [self setFrame:CGRectMake(0, 0, 768, textViewContentHeight)];
    return textViewContentHeight;
    
    
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
