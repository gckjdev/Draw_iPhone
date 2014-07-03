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
@synthesize delegate;
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
        
        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.tutorialDescInfo
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

- (IBAction)clickAddBtn:(id)sender {
    
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入新数据" message:nil delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"添加", nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alert textFieldAtIndex:0].placeholder = @"请输入新数据";
//    [alert show];
//    [alert release];
    [delegate clickButton];
    
}

- (void)updateCellInfo:(PBTutorial*)pbTutorial
{
    self.tutorialDesc.text = pbTutorial.name;
    self.tutorialDescInfo.text = pbTutorial.desc;
}


- (void)dealloc {
    
    
    [_tutorialDesc release];
    [_tutorialDescInfo release];
    [_tutorialAddBtn release];
    [super dealloc];
}
@end
