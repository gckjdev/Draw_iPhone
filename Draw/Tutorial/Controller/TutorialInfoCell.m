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
        NSString *tutorialSortedText = @"新手级aaaaaaaaaaaaaaaaaa";
    UILabel* label =  [[UILabel alloc] initWithFrame:CGRectMake(97, 21, 0, 0)];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    UIFont * tfont = AD_FONT(19, 12);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
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
